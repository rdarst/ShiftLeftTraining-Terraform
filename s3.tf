resource "aws_s3_bucket" "b" {
  bucket = "my-test-bucket"
  acl    = "public"

  tags = {
    Name        = "My public S3 bucket"
    Environment = "Dev"
  }
}
