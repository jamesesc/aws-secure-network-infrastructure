# Terraform auth connection/configuation for our AWS account
provider "aws" {
    region     = "us-west-2"
}

# Creating our main VPC
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "main"
    }
}