resource "google_compute_firewall" "allow-dns-query" {
  name      = "allow-dns-query"
  network   = "default"
  direction = "INGRESS"

  target_tags = [
    "dns",
  ]

  source_ranges = [
    "0.0.0.0/0",
  ]

  allow {
    protocol = "udp"
    ports = [
      "53",
    ]
  }
}

resource "google_compute_firewall" "allow-dns-zone-transfer" {
  count     = var.master ? 1 : 0
  name      = "allow-dns-zone-transfer"
  network   = "default"
  direction = "INGRESS"

  target_tags = [
    "ns1",
  ]

  source_ranges = [
    "${var.ns2_ip}/32",
  ]

  allow {
    protocol = "tcp"
    ports = [
      "53",
    ]
  }
}

resource "google_compute_firewall" "allow-mosh" {
  name      = "allow-mosh"
  network   = "default"
  direction = "INGRESS"

  target_tags = [
    "mosh",
  ]

  source_ranges = [
    "0.0.0.0/0",
  ]

  allow {
    protocol = "udp"
    ports = [
      "60000-60010",
    ]
  }
}

resource "google_compute_instance" "ns" {
  name         = var.name
  machine_type = "f1-micro"
  zone         = var.zone

  metadata = {
    ssh-keys       = "${var.user}:${file(var.public_key_path)}"
    startup-script = templatefile("${path.module}/startup.sh.tpl", {
      domain = var.domain
      master = var.master
      ns1_ip = var.ns1_ip
      ns2_ip = var.ns2_ip
    })
  }

  tags = [
    var.master ? "ns1" : "ns2",
    "dns",
    "mosh",
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
      nat_ip = var.master ? var.ns1_ip : var.ns2_ip
    }
  }
}
