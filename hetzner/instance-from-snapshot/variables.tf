### Customization

## Output debug toggle
variable "debug_output" {
  type    = bool
  default = false
}

## Hetzner's API token
variable "hcloud_token" {
  type      = string
  sensitive = true
  default   = "" # Add token here
}

## Labels 
variable "labels" {
  type = map
  default = { # Edit values
    ssh  = "label-matching-existing-ssh-public-key", 
    net  = "label-matching-existing-network",
    snap = "label-matching-existing-snapshot-image"
  }
}

## Instance traits
variable "instance" {
  type = object({
    hostname   = string
    type       = string
    location   = string
  })
  default = {  # Instance image is chosen using the snapshot label-selector
    hostname   = "hostname-here" # Edit
    type       = "cpx41"         # Edit
    location   = "fsn1"          # Edit
  }
}
