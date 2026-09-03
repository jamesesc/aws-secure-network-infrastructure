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

