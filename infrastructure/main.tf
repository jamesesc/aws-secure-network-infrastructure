# Terraform auth connection/configuation for our AWS account
provider "aws" {
    region     = "us-west-2"
}


module "networking" {
    source = "./modules/networking"
    my_ip = var.my_ip
    vpc_ip_block =  var.vpc_ip_block
    public_subnet_cidr = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
}

module "storage" {
    source = "./modules/storage"
    bucket_name = var.bucket_name
}

module "compute" {
    source = "./modules/compute"
    ssh_key_name = var.ssh_key_name
    public_key_path = var.public_key_path
    ec2_instance_type = var.ec2_instance_type

    # Importing Network data to compute
    public_subnet_id = module.networking.public_subnet_id
    private_subnet_id = module.networking.private_subnet_id
    public_allowed_traffic = module.networking.public_allowed_traffic_id
    private_allowed_traffic = module.networking.private_allowed_traffic_id
}