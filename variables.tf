#VSCALE VARIABLES
variable "vscale_token" {
  type        = "string"
  description = "Insert your token from Vscale"
}

variable "vscale_servers" {
  type = "list"
}

variable "vscale_make_from" {
  type        = "string"
  description = "Choice image"
}

variable "ssh_key_skensel" {
  type        = "string"
  description = "Insert ssh key"
}

#AWS variables

variable "amz_53_zone_id" {
  type        = "string"
  description = "Insert ID zone DNS"
}
