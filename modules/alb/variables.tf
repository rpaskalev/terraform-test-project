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
 variable "user_data_app1" {
   description = "userdate file for app1"
   default = null
 }

  variable "user_data_app2" {
   description = "userdate file for app2"
   default = null
 }