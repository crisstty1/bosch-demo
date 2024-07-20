# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = var.environment
    Terraform   = upper("true")
  }

  enable_dns_hostnames = true
}

# Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

# Create route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name      = "demo_public_rtb"
    Terraform = "true"
  }
}

# Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "demo_igw"
  }
}

# Creates a PEM (and OpenSSH) formatted private key
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

# Generates a local file with the given content
resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "MyAWSKey.pem"
}

# Provides an EC2 key pair resource
resource "aws_key_pair" "generated" {
  key_name   = "MyAWSKey"
  public_key = tls_private_key.generated.public_key_openssh
}

# Creates ssh SG
resource "aws_security_group" "ingress-ssh" {
  name   = "allow-all-ssh"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "Allow all ssh traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creates ping SG
resource "aws_security_group" "vpc-ping" {
  name        = "vpc-ping"
  vpc_id      = aws_vpc.vpc.id
  description = "ICMP for Ping Access"
  ingress {
    description = "Allow inbound ICMP Traffic"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Image filtering for VM
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Build EC2 instance in Public Subnet
resource "aws_instance" "server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  count                       = var.instance_count
  subnet_id                   = aws_subnet.public_subnets["public_subnet_1"].id
  security_groups             = [aws_security_group.vpc-ping.id, aws_security_group.ingress-ssh.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated.key_name
  connection {
    user        = "ubuntu"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.public_ip
  }

  # change permissions to MyAWSKey.pem
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
  }
  # copy MyAWSKey.pem to VMs
  provisioner "file" {
    source      = "MyAWSKey.pem"
    destination = "/home/ubuntu/MyAWSKey.pem"
  }
  # copy change_admin_pass.sh to VMs
  provisioner "file" {
    source      = "change_admin_pass.sh"
    destination = "/home/ubuntu/change_admin_pass.sh"
  }
  # run commands on remote VMs
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/change_admin_pass.sh",
      "sh /home/ubuntu/change_admin_pass.sh",
    ]
  }

  tags = {
    Name = "Ubuntu-${count.index + 1}"
  }
}

# data resource collecting output of ping.sh which is based on input arguments passed with query block
data "external" "ping" {
  program = ["/usr/bin/bash", "test.sh"]
  query = {
    nr_instances = var.instance_count
    public_ip_addr_1  = aws_instance.server[0].public_ip
    public_ip_addr_2  = aws_instance.server[1].public_ip
    public_ip_addr_3  = aws_instance.server[2].public_ip
    private_ip_addr_1 = aws_instance.server[0].private_ip
    private_ip_addr_2 = aws_instance.server[1].private_ip
    private_ip_addr_3 = aws_instance.server[2].private_ip
    private_key_file  = "MyAWSKey.pem"
  }
}

