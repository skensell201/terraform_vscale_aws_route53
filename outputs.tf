output "IP_VPS1" {
  value       = "${vscale_scalet.task6[0].public_address}"
  description = "Public IP adress of VPS1"
}

output "RECORDS_VPS1" {
  value       = "${aws_route53_record.records1.name}"
  description = "Records of VPS1"
}

output "IP_VPS2" {
  value       = "${vscale_scalet.task6[1].public_address}"
  description = "Public IP adress of VPS2"
}

output "RECORDS_VPS2" {
  value       = "${aws_route53_record.records2.name}"
  description = "Records of VPS2"
}
