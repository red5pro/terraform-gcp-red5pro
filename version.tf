terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.14.0"
    }
  }
}

provider "google" {
  region      = var.google_region
  credentials = file("/PATH/TO/application_default_credentials.json")
}