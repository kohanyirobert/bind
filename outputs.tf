output "ns1_ip" {
  description = "Public IP address for NS1"
  value       = google_compute_address.ns1.address
}

output "ns2_ip" {
  description = "Public IP address for NS2"
  value       = google_compute_address.ns2.address
}
