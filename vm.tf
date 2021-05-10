resource "ah_cloud_server" "pcm" {
  backups    = false
  count      = 1
  name       = "node_${count.index}"
  datacenter = var.ah_dc
  image      = var.ah_image_type
  product    = var.ah_machine_type
  ssh_keys   = [var.ah_fp]
}

resource "ah_private_network" "lan1" {
  ip_range = "10.1.0.0/27"
  name     = "LAN1"
  depends_on = [
  ah_cloud_server.pcm
]
}

resource "ah_private_network_connection" "lan1" {
  count              = 1
  cloud_server_id    = ah_cloud_server.pcm[count.index].id
  private_network_id = ah_private_network.lan1.id
  ip_address         = "10.1.0.1${count.index}"
  depends_on = [
  ah_private_network.lan1
  ]
}