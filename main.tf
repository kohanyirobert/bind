terraform {
  required_version = "0.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }

  backend "gcs" {}
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_firewall" "allow-dns" {
  name      = "allow-dns"
  network   = "default"
  direction = "INGRESS"

  target_tags = [
    "dns"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]

  allow {
    protocol = "udp"
    ports = [
      "53"
    ]
  }
}

resource "google_compute_instance" "bind" {
  name         = "bind"
  machine_type = "f1-micro"
  zone         = var.zone

  metadata = {
    ssh-keys       = "${var.user}:${file(var.public_key_path)}"
    startup-script = file("startup.sh")
    duckdns_token  = var.duckdns_token
    duckdns_domain = var.duckdns_domain
  }

  tags = [
    "dns"
  ]

  boot_disk {
    initialize_params {
      image = "debian-10-buster-v20201112"
      type  = "pd-standard"
      size  = 10
    }
  }

  network_interface {
    network = "default"

    access_config {
      network_tier = "STANDARD"
    }
  }
}

output "ip" {
  value = google_compute_instance.bind.network_interface[0].access_config[0].nat_ip
}
