output "public_ip" {
  description = "List of public IP addresses assigned to the instances"
  value       = module.adds-servers.*.public_ip
}
output "public_subnets" {
  description = "list of public subnets associated to the instance"
  value       = module.vpc_adds-servers.public_subnets
}

output "private_ip" {
  description = "The private IP addresses assigned to the instances"
  value       = module.adds-servers.private_ip
}

output "primary_network_interface_id" {
  description = "List of IDs of the primary network interface of instances"
  value       = module.adds-servers.*.primary_network_interface_id
}
