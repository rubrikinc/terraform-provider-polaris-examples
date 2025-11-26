resource "random_string" "suffix" {
  length  = var.length
  special = false
}
