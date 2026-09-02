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

# Creating secuirty rule for egress traffic to the public subnet
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

# Attaching the public ssh key to our AWS to our EC2 instance
resource "aws_key_pair" "ec2_access_key" {
    key_name = "access_key"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOubr3w9Fo7q1u2Ijj2CciI6yqUoPavOHjkE41I0Pwkl first-cloud-project"
}

# Filtering and storing our EC2 AMI data reference
data "aws_ami" "ec2_ami" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "architecture"
        values = ["arm64"]
    }

    filter {
        name   = "name"
        values = ["al2023-ami-*kernel-6.18*arm64"]
    }
}

# Creating our private ec2
resource "aws_instance" "private_ec2" {
    ami = data.aws_ami.ec2_ami.id
    instance_type = "t4g.micro"
    subnet_id = aws_subnet.private.id
    vpc_security_group_ids = [aws_security_group.allowed_traffic_private.id]
    associate_public_ip_address = false
    
    key_name = aws_key_pair.ec2_access_key.key_name

    tags = {
        Name = "private-EC2"
    }
}

# Creating our public EC2
resource "aws_instance" "public_ec2" {
    ami = data.aws_ami.ec2_ami.id
    instance_type = "t4g.micro"
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.allowed_traffic.id]
    associate_public_ip_address = true

    key_name = aws_key_pair.ec2_access_key.key_name

    tags = {
        Name = "public-EC2"
    }
}

# Creating the S3 bucket for this VPC
resource "aws_s3_bucket" "my_bucket" {
    bucket = "my-first-ever-s3-bucket-cloud-project-2026"

    tags = {
        Name = "My bucket"
        Environment = "Dev"
    }
}

# Modern apporach to securely manage S3 buckets for controls
resource "aws_s3_bucket_ownership_controls" "my_bucket_ownership_controls" {
    bucket = aws_s3_bucket.my_bucket.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

# Block the public access to our S3 Bucket
resource "aws_s3_bucket_public_access_block" "my_bucket_public_access_block" {
    bucket = aws_s3_bucket.my_bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# Handles the S3 bucket access control list (aka ACL) 
resource "aws_s3_bucket_acl" "my_bucket_acl" {
    depends_on = [aws_s3_bucket_ownership_controls.my_bucket_ownership_controls]
    
    bucket = aws_s3_bucket.my_bucket.id
    acl = "private"
}

# Handles the S3 bucket versioning
resource "aws_s3_bucket_versioning" "s3_versioning" {
    bucket = aws_s3_bucket.my_bucket.id

    versioning_configuration {
        status = "Enabled"
    }
}

# Handles the S3 security
resource "aws_kms_key" "s3_kms_key" {
    description = "this key is used to encrypt the S3 bucket objects"
    deletion_window_in_days = 10
}

# Handles the S3 bucket server side encryption config
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
    bucket = aws_s3_bucket.my_bucket.id

    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id = aws_kms_key.s3_kms_key.arn
            sse_algorithm = "aws:kms"
        }
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