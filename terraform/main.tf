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

module "security-groups" {
  source         = "./modules/security-groups"
  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.repository_name
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}