terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.53"
        }
    }

    # backend "s3" {
    #     bucket = "my-first-ever-s3-bucket-cloud-project-2026"
    #     key = "cloud-project-2026/terraform.tfstate"
    #     region = "us-west-2"
    #     use_lockfile = true
    # }
    
    required_version = ">= 1.10"
}