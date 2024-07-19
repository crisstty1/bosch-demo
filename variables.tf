variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type      = string
  default   = "10.0.0.0/16"
  sensitive = true
}

variable "vpc_name" {
  type    = string
  default = "demo_vpc"
}

variable "environment" {
  description = "Environment for deployment"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_count" {
  description = "The number of instances"
  type        = number
  default     = 3
}

variable "public_subnets" {
  description = "keys and values used for setting up the subnets"
  default = {
    "public_subnet_1" = 0
    "public_subnet_2" = 1
    "public_subnet_3" = 2
    "public_subnet_4" = 3
    "public_subnet_5" = 4
    "public_subnet_6" = 5
  }
}
