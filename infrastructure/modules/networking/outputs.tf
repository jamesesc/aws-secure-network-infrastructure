output "public_subnet_id" {
    value = aws_subnet.public_subnet.id
    description = "The ID of the public subnet"
}

output "private_subnet_id" {
    value = aws_subnet.private_subnet.id
    description = "The ID of the private subnet"
}

output "public_allowed_traffic_id" {
    value = aws_security_group.allowed_traffic_public.id
    description = "The security group for the allowed traffic in the public subnet"
}

output "private_allowed_traffic_id" {
    value = aws_security_group.allowed_traffic_private.id
    description = "The security group for the allowed traffic in the private subnet"
}