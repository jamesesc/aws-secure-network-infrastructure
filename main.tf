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

# Creating our internet gateway
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id  = aws_vpc.main.id

    tags = {
        Name = "internet_gateway_main"
    }
}

# Creating our public subnet
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"

    availability_zone = "us-west-2a"

    map_public_ip_on_launch = true
    
    tags = {
        Name = "public-subnet"
    }
}


# Creating our private subnet
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"

    availability_zone = "us-west-2a"
    
    tags = {
        Name = "private-subnet"
    }
}