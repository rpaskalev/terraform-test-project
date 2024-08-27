module "s3" {
  source      = "../../modules/s3"
  bucket_name = "ferdows-test-bucket-2024"
  environment = var.environment
}