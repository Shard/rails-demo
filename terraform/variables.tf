# AWS Deployment Region
variable "aws_region" {
  default = "ap-southeast-2"
}

# Domain Name
# The domain name that a certificate will be requested for and will expect a CNAME
# record pointing to the resulting ALB endpoint
variable "public_domain" {
  default = "rails-demo.82dk.net"
}
