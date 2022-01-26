terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.32.0"
    }
  }
}

## Hetzner's API token
provider "hcloud" { token = var.hcloud_token } 
 
## Selecting a SSH public key via selector on "ssh" key; unique selector expected
data "hcloud_ssh_keys" "by_selector" { with_selector = "ssh=${var.labels.ssh}" }
## Selecting the network via selector on "net" key; unique selector expected
data "hcloud_network" "by_selector" { with_selector = "net=${var.labels.net}" }
## Selecting the snapshot via selector on "snap" key; unique selector expected
data "hcloud_image" "by_selector" { with_selector = "snap=${var.labels.snap}" }

## Locals; using first element for each selector-based query
locals {
  ssh_publickey = element(data.hcloud_ssh_keys.by_selector.ssh_keys.*, 0)
  network       = element(data.hcloud_network.by_selector.*, 0)
  snapshot      = element(data.hcloud_image.by_selector.*, 0)
}

output "selected_ssh_public_key" { 
  value = var.debug_output ? jsonencode(local.ssh_publickey) : local.ssh_publickey.name 
}
output "selected_network" { 
  value = var.debug_output ? jsonencode(local.network) : local.network.name 
}
output "selected_snapshot_image" { 
  value = var.debug_output ? jsonencode(local.snapshot) : local.snapshot.description 
}

# Creating instance from snapshot image ...
resource "hcloud_server" "instance" {

  name        = var.instance["hostname"]
  server_type = var.instance["type"]
  image       = local.snapshot.id
  location    = var.instance["location"]
  ssh_keys    = [ local.ssh_publickey.id ]
  
  network { network_id = local.network.id }

# The instance depends on already existing resources in Hetzner Cloud 
  depends_on   = [
    data.hcloud_ssh_keys.by_selector,
    data.hcloud_network.by_selector,
    data.hcloud_image.by_selector
  ]
}
