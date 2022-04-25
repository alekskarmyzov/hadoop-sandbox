include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=3.13.0"
}

inputs = {
    name = "akarmyzov-hadoop-sandbox"
    cidr = "10.10.0.0/16"

    azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
    public_subnets  = ["10.10.0.0/24", "10.10.2.0/24", "10.10.4.0/24"]
    
    enable_nat_gateway = false
    enable_vpn_gateway = false

    tags = {
        Terraform = "true"
        Project = "Hadoop Sandbox"
        Owner = "akarmyzov"
    }
}

