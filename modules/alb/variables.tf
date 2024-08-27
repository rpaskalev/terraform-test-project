variable "environment" {
  default = ""
}

variable "vpc_security_group" {
  default = []
}

variable "vpc_id" {
  default = ""
}

variable "alb-subnets" {
  type = list
  default = [] 
}

variable "asg_vpc_zone_identifier" {
  type = list
  default = []
}

variable "instance_type" {
  default = "t2.micro"
}

# variable "key_name" {
#   type    = string
#   default = "project-ssh-keypair"
# }
