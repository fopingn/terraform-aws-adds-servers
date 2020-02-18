output "public_ip" {
  value = [module.adds-servers.*.public_ip]
}

output "public_subnets" {
  value = module.vpc_adds-servers.public_subnets
}
