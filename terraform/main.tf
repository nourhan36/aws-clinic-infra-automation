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
  my_ip_cidr     = var.my_ip_cidr
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.repository_name
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "launch_template" {
  source                = "./modules/launch-template"
  project_name          = var.project_name
  security_group_id     = module.security-groups.app_sg_id
  instance_profile_name = module.iam.instance_profile_name
  instance_type         = var.instance_type
  ami_id                = var.ami_id
}

module "alb" {
  source            = "./modules/alb"
  security_group_id = module.security-groups.alb_sg_id
  subnet_ids        = module.vpc.public_subnet_ids
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
}

module "asg" {
  source             = "./modules/asg"
  project_name       = var.project_name
  private_subnet_ids = module.vpc.private_app_subnet_ids
  launch_template_id = module.launch_template.launch_template_id
  target_group_arn   = module.alb.target_group_arn
}

module "rds" {
  source                = "./modules/rds"
  project_name          = var.project_name
  subnet_ids            = module.vpc.private_rds_subnet_ids
  rds_security_group_id = module.security-groups.rds_sg_id
  db_username           = var.db_username
  db_password           = var.db_password
}

module "cloudwatch" {
  source                  = "./modules/cloudwatch"
  project_name            = var.project_name
  asg_name                = module.asg.asg_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  rds_identifier          = module.rds.rds_identifier

  alarm_actions = []

  tags = var.tags
}

module "bastion" {
  source = "./modules/bastion"

  project_name          = var.project_name
  ami_id                = var.ami_id
  instance_type         = var.bastion_instance_type
  public_subnet_id      = module.vpc.public_subnet_ids[0]
  bastion_sg_id         = module.security-groups.bastion_sg_id
  key_name              = var.key_name
  instance_profile_name = module.iam.bastion_instance_profile_name
}