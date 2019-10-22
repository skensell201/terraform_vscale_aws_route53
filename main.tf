provider "vscale" {
  token = "${var.vscale_token}"
}

provider "aws" {
  region                  = "us-east-2"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
}

resource "vscale_scalet" "task6" {
  count     = "${length(var.vscale_servers)}"
  name      = "${element(var.vscale_servers, count.index)}"
  make_from = "${var.vscale_make_from}"
  rplan     = "medium"
  location  = "spb0"
  ssh_keys  = ["${vscale_ssh_key.mykey.id}"]
}


resource "vscale_ssh_key" "mykey" {
  name = "skensel_taks6"
  key  = "${var.ssh_key_skensel}"
}

resource "aws_route53_record" "records1" {
  zone_id = "${var.amz_53_zone_id}"
  name    = "${var.vscale_servers[0]}"
  type    = "A"
  ttl     = "300"
  records = ["${vscale_scalet.task6[0].public_address}"]
}

resource "aws_route53_record" "records2" {
  zone_id = "${var.amz_53_zone_id}"
  name    = "${var.vscale_servers[1]}"
  type    = "A"
  ttl     = "300"
  records = ["${vscale_scalet.task6[1].public_address}"]
}
