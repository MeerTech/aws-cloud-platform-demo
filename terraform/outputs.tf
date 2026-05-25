output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "alb_sg_id" {
  value = module.security.alb_sg_id
}

output "app_sg_id" {
  value = module.security.app_sg_id
}

output "ec2_instance_profile_name" {
  value = module.security.ec2_instance_profile_name
}

output "instance_id" {
  value = module.compute.instance_id
}

output "instance_private_ip" {
  value = module.compute.instance_private_ip
}

output "app_bucket_name" {
  value = module.storage.bucket_name
}

output "kms_key_id" {
  value = module.storage.kms_key_id
}
