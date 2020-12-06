variable "project" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Region name"
  type        = string
}

variable "zone" {
  description = "Zone name"
  type        = string
}

variable "user" {
  description = "Unix user"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public SSH key of the user"
  type        = string
}

variable "duckdns_token" {
  description = "DuckDNS token used for DDNS"
  type        = string
}

variable "duckdns_domain" {
  description = "DuckDNS subdomain name used in DDNS"
  type        = string
}