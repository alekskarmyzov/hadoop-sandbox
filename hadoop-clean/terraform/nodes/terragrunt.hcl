include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}//modules/nodes"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
    owner = "akarmyzov"
    project = "Hadoop Sandbox"
    ami = "ami-0d527b8c289b4af7f"
    ssh_key_name = "akarmyzov-euc1"
    vpc_id = dependency.network.outputs.vpc_id
    subnet_ids = dependency.network.outputs.public_subnets
    data_nodes_count = 2
    hosted_zone_id = "Z05974502KISPIQK1IOY"
}