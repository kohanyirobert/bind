variable "name" {
  description = "Name to use for hostname"
  type        = string
}

variable "master" {
  description = "Whether the instance is a master NS or not"
  type        = bool
}

variable "ns1_ip" {
  description = "Public IP address of NS1 (used by NS2)"
  type        = string
}

variable "ns2_ip" {
  description = "Public IP address of NS2 (used by NS1)"
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

variable "domain" {
  description = "Domain name to manage"
  type        = string
}
