# bosch-demo
Bosch demo terraform infra 

Terraform code defined in main.tf was used to build an AWS infrastructure made of: 1 VPC, 1IGW, 6 public subnets (us-east-1 region has only 6 AZs), a public RT, 2 SGs used for allowing ssh and ping connections, 3 AWS instances and 2 data block types. Also a pem key was created for connecting to instances with ssh.
In variables.tf variables are defined and default values assigned. Variables are: aws_region, vpc_cidr, vpc_name, environment, instance_type and public_subnets.
"prod.tfvars" file is used to assign other values to infrastructure. Ex: you want to create prod infrastructure in another region.
"output.tf" contains one variable named ping_test which shows the result of multiple pings between instances.

This solution is creating 3 AWS instances on which admin password is changed automatically. For this change_admin_pass.sh script is copied to VMs and ran remotely on VMs. Password is generated remotely on each host, so each host will have a different one. Password is stored remotely in a password.txt file, so its' value is not present either in Terraform config files, or in state file.
Instances are able to ping each other using private IPs since they are created in same VPC and specific SGs were created and assigned to them:
- SSH security group which allows all inbound traffic on TCP protocol port 22 and allows all egress traffic;
- Ping security group which allows all inbound traffic on ICMP protocol port -1 and allows all egress traffic.
The resource type for 1st data block is "aws_ami" and is used to filter an ubuntu image to be used for instances. Instances are of type "t2.micro" by default.
A "local-exec" provisioner was used to change permissions to pem file, a "file" provisioner was used to copy pem file and change_admin_pass.sh script to VMs.
The resource type for 2nd data block is "external" and is used to take ping.sh program as a data source. "query" argument is used to define a map of strings variables to be passed to the ping.sh script. Inside ping.sh script "eval" command is used to translate variables defined in "query" section into variables which can be consumed by bash. "result_1", "result_2", "result_3" variables are defined in script and every one contains ping result after ssh-ing to VMs. Ping is done towards private IPs of VMs to test connectivity inside VPC.

Example usage of prod.vars file in a new workspace:
terraform workspace new <workspace_name>
terraform workspace select <workspace_name>
terraform init
terraform validate
terraform plan
terraform apply -var-file="prod.vars" -auto-approve

Delete infra from workspace:
terraform destroy -var-file="prod.vars" -auto-approve

Delete workspace:
terraform workspace delete prod