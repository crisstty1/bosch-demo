aws_region     = "us-west-1"
vpc_cidr       = "10.0.0.0/16"
vpc_name       = "prod_vpc"
environment    = "prod"
instance_type  = "t2.micro"
instance_count = 3
public_subnets = { "public_subnet_1" = 0, "public_subnet_2" = 1 }