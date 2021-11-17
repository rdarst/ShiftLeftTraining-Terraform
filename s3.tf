resource "aws_s3_bucket" "s3_test_bucket" {
  bucket = "my-test-bucket"
  acl    = "public"

  tags = {
    Name        = "My public S3 bucket"
    Environment = "Dev"
  }
}
