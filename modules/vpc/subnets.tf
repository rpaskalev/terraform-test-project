resource "aws_subnet" "my_subnet_1" {
  vpc_id            = var.vpc_id 
  cidr_block        = var.subnet_1_cidr
  availability_zone = var.availability_zone_1
  map_public_ip_on_launch = true

    tags = {
    Name  =   "${var.environment}-project-public-subnet1"
    Environment = var.environment
  }
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id            = var.vpc_id 
  cidr_block        = var.subnet_2_cidr
  availability_zone = var.availability_zone_2
  map_public_ip_on_launch = true

    tags = {
    Environment = var.environment
    Name  =   "${var.environment}-project-public-subnet2"
  }
}