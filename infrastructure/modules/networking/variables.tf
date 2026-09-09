variable "my_ip" {
    description = "My ip address"
    type = string
}

variable "vpc_ip_block" {
    description = "The CIDR block for the VPC"
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