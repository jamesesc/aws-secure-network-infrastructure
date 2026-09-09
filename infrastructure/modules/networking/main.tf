# Creating our main VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_ip_block 
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

data "aws_availability_zones" "avilable" {
    state = "available"
}

# Creating our public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr

    availability_zone = data.aws_availability_zones.avilable.names[0] 

    map_public_ip_on_launch = true
    
    tags = {
        Name = "public-subnet"
    }
}

# Creating our private subnet
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr 

    availability_zone = data.aws_availability_zones.avilable.names[0] 
    
    tags = {
        Name = "private-subnet"
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
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.route_table.id
}

# Creating our security group for our public subnet
resource "aws_security_group" "allowed_traffic_public" {
    name = "security_allowed_traffic"
    description = "Controlling the inbound and outbound traffic to the public subnet"
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "security_allowed_traffic"
    }
}

# Creating security rule for ingress traffic to the public subnet
resource "aws_vpc_security_group_ingress_rule" "allowed_traffic_ingress" {
    security_group_id = aws_security_group.allowed_traffic_public.id
    cidr_ipv4 = "${var.my_ip}/32"
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
}

# Creating secuirty rule for egress traffic to the public subnet
resource "aws_vpc_security_group_egress_rule" "allowed_traffic_egress" {
    security_group_id = aws_security_group.allowed_traffic_public.id
    cidr_ipv4 = "0.0.0.0/0"   
    ip_protocol = "-1"
}

# Creating our security group for our private  
resource "aws_security_group" "allowed_traffic_private" {
    name = "allowed_traffic_private"
    description = "Controlling the inbound and outbound traffic to the private subnet"
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "allowed_traffic_private"
    }
}

# Creating security rule for ingress traffic to the private subnet (only within the VPC allowed)
resource "aws_vpc_security_group_ingress_rule" "allowed_traffic_private_ingress" {
    security_group_id = aws_security_group.allowed_traffic_private.id
    cidr_ipv4 = "10.0.0.0/16"
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
}

# Creating security rule for egress traffic to the private subnet (allowed to the internet (oubound))
resource "aws_vpc_security_group_egress_rule" "allowed_traffic_private_egress" {
    security_group_id = aws_security_group.allowed_traffic_private.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}