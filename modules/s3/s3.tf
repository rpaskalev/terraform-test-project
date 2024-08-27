
locals {
  force_destroy = true
  bucket_name = "${var.bucket_name}-${var.environment}"
}

resource "aws_s3_bucket" "iqies_my_first_resourse" {
  bucket = local.bucket_name
  force_destroy = local.force_destroy
}



