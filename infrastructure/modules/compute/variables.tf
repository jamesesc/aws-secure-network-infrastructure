# From Root
variable "ssh_key_name" {
    description = "The SSH key named used to access the EC2 instances"
    type = string
    default = "ssh_access_key"
}

variable "public_key_path" {
    description = "The path to the public key file"
    type = string
    default = "~/.ssh/id_ed25519.pub"
}

variable "ec2_instance_type" {
    description = "Variable the decides the private ec2 instance type"
    type = string
    default = "t4g.micro"
}

# From Network Module
variable "public_subnet_id" {
    type = string
}

variable "private_subnet_id" {
    type = string
}

variable "public_allowed_traffic" {
    type = string
}

variable "private_allowed_traffic" {
    type = string
}
