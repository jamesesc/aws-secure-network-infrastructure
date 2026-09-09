variable "ssh_key_name" {
    description = "The SSH key named used to access the EC2 instance"
    type = string
    default = "ssh_access_key"
}

# Compute Module
variable "public_key_path" {
    description = "The Path to the public key file"
    type = string
    default = "~/.ssh/id_ed25519.pub"
}

variable "ec2_instance_type" {
    description = "Variable the decides the private ec2 instance type"
    type = string
    default = "t4g.micro"
}


# Network Module
variable "vpc_ip_block" {
    description = "THe CIDR block for the VPC"
    type = string
}

variable "my_ip" {
    description = "My IP address"
    type = string
}

variable "public_subnet_cidr" {
    description = "The public subnet cidir block"
    type = string
}

variable "private_subnet_cidr" {
    description = "The private subnet cidr block"
    type = string
}



# Storage
variable "bucket_name" {
    description = "My bucket name"
    type = string
}