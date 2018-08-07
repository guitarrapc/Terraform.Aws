# any output you want to path with remote_state

# cloudtrail
output "cloudtrail_name" {
  value = "${aws_cloudtrail.this.name}"
}