variable "owner" {
  type = string
}

variable "project" {
  type = string
}

variable "ami" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list
}

variable "data_nodes_count" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}