output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.app_data.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.app_data.arn
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.s3.arn
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.s3.key_id
}
