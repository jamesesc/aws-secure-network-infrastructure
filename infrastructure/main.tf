# Terraform auth connection/configuation for our AWS account
provider "aws" {
    region     = "us-west-2"
}


module "networking" {
    source = "./modules/networking"
}

module "storage" {
    source = "./modules/storage"
}

module "compute" {
    source = "./modules/compute"
}