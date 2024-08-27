module "alb" {
  source                  = "../../modules/alb"
  environment             = var.environment
  vpc_id                  = module.subnets.vpc_id
  vpc_security_group      = [module.security_group.standard_sg]
  asg_vpc_zone_identifier = [module.subnets.subnet_1_id, module.subnets.subnet_2_id]
  instance_type           = "t2.micro"
  alb-subnets             = [module.subnets.subnet_1_id, module.subnets.subnet_2_id]
}
