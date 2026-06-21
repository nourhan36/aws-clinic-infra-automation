module "vpc" {
  # VPC
  source         = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  project_name   = var.project_name

  # Availability Zones
  availability_zones = var.availability_zones

  # Public Subnets
  public_subnet_cidrs = var.public_subnet_cidrs

  # Private Subnets 
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_rds_subnet_cidrs = var.private_rds_subnet_cidrs

}