# Attaching the public ssh key to our AWS so we can connect to our EC2 instance
resource "aws_key_pair" "ec2_access_key" {
    key_name = var.ssh_key_name
    public_key = file(var.public_key_path)
}

# Filtering and storing our EC2 AMI data reference
data "aws_ami" "amazon_os_image" {
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
    ami = data.aws_ami.amazon_os_image.id
    instance_type = var.ec2_instance_type 

    # SUBNET_ID, Work on that
    subnet_id = var.private_subnet_id 

    # SECURITY GROUP, EXPORT
    vpc_security_group_ids = [var.private_allowed_traffic]
    associate_public_ip_address = false
    
    key_name = aws_key_pair.ec2_access_key.key_name

    tags = {
        Name = "private-EC2"
    }
}

# Creating our public EC2
resource "aws_instance" "public_ec2" {
    ami = data.aws_ami.amazon_os_image.id
    instance_type = var.ec2_instance_type 
    
    # Export variable
    subnet_id = var.public_subnet_id
    # Export Variable 
    vpc_security_group_ids = [var.public_allowed_traffic]
    associate_public_ip_address = true

    key_name = aws_key_pair.ec2_access_key.key_name

    tags = {
        Name = "public-EC2"
    }
}