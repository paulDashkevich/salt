output "external_ip_address" {
  value = ah_cloud_server.pcm.*.ips.0.ip_address
}

output "internal_ip0" {
  value = ah_private_network_connection.lan1.*.ip_address
}