terraform {
  backend "s3" {
    bucket = "tf-k8s-academy"
    key    = "tf-k8s-academy/terraform.tfstate"
    region = "us-east-1"
  }
}
