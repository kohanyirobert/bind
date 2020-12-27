variable "ns1_credentials_json_path" {
  description = "Path to credentials JSON for NS1"
  type        = string
}

variable "ns2_credentials_json_path" {
  description = "Path to credentials JSON for NS2"
  type        = string
}

variable "ns1_project" {
  description = "Project ID for NS1"
  type        = string
}

variable "ns2_project" {
  description = "Project ID for NS2"
  type        = string
}

variable "ns1_region" {
  description = "Region name for NS1"
  type        = string
}

variable "ns2_region" {
  description = "Region name for NS1"
  type        = string
}

variable "ns1_zone" {
  description = "Zone name for NS1"
  type        = string
}

variable "ns2_zone" {
  description = "Zone name for NS2"
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
