terraform {
  required_version = ">= 0.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.5.0"
    }
  }

  backend "gcs" {
    credentials = "ns1_credentials.json"
  }
}

provider "google" {
  alias       = "ns1"
  project     = var.ns1_project
  region      = var.ns1_region
  zone        = var.ns1_zone
  credentials = var.ns1_credentials_json_path
}

provider "google" {
  alias       = "ns2"
  project     = var.ns2_project
  region      = var.ns2_region
  zone        = var.ns2_zone
  credentials = var.ns2_credentials_json_path
}

resource "google_compute_address" "ns1" {
  provider     = google.ns1
  name         = "ns"
  address_type = "EXTERNAL"
}

resource "google_compute_address" "ns2" {
  provider     = google.ns2
  name         = "ns"
  address_type = "EXTERNAL"
}

module "ns1" {
  source          = "./modules/ns"
  master          = true
  ns1_ip          = google_compute_address.ns1.address
  ns2_ip          = google_compute_address.ns2.address
  name            = "ns1"
  zone            = var.ns1_zone
  user            = var.user
  public_key_path = var.public_key_path
  domain          = var.domain

  ns1_ns2_key_name = var.ns1_ns2_key_name
  ns1_ns2_key_path = var.ns1_ns2_key_path
  ddns_key_name    = var.ddns_key_name
  ddns_key_path    = var.ddns_key_path

  providers = {
    google = google.ns1
  }
}

module "ns2" {
  source          = "./modules/ns"
  master          = false
  ns1_ip          = google_compute_address.ns1.address
  ns2_ip          = google_compute_address.ns2.address
  name            = "ns2"
  zone            = var.ns2_zone
  user            = var.user
  public_key_path = var.public_key_path
  domain          = var.domain

  ns1_ns2_key_name = var.ns1_ns2_key_name
  ns1_ns2_key_path = var.ns1_ns2_key_path
  ddns_key_name    = var.ddns_key_name
  ddns_key_path    = var.ddns_key_path

  providers = {
    google = google.ns2
  }
}
