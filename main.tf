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

# Creating our route table to our public-subnet
resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }

    tags = {
        Name = "internet_gateway_route_table"
    }
}

# Creating our route table assocation to our public subnet
resource "aws_route_table_association" "route_public_subnet" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.route_table.id
}

# Creating our security group for our public subnet
resource "aws_security_group" "allowed_traffic" {
    name = "security_allowed_traffic"
    description = "Controlling the inbound and outbound traffic to the public subnet"
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "security_allowed_traffic"
    }
}

# Creating security rule for ingress traffic to the public subnet
resource "aws_vpc_security_group_ingress_rule" "allowed_traffic_ingress" {
    security_group_id = aws_security_group.allowed_traffic.id
    cidr_ipv4 = "${var.my_ip}/32"
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allowed_traffic_egress" {
    security_group_id = aws_security_group.allowed_traffic.id
    cidr_ipv4 = "0.0.0.0/0"   
    ip_protocol = "-1"
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