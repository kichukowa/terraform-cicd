terraform {
  backend "gcs" {
    bucket = "tf-cicd-state"
    prefix = "terraform/state"
  }
}