output "lighthouse" {
  value = linode_instance.lighthouse.ip_address
}

output "edge-redirector-1" {
  value = linode_instance.edge-redirector-1.ip_address
}

output "edge-redirector-2" {
  value = linode_instance.edge-redirector-2.ip_address
}

output "internal-redirector-1" {
  value = linode_instance.internal-redirector-1.ip_address
}

output "internal-redirector-2" {
  value = linode_instance.internal-redirector-2.ip_address
}

output "team-server" {
  value = linode_instance.team-server.ip_address
}
