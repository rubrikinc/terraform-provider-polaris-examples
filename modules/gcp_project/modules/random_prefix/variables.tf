variable "prefix" {
  description = "Fixed prefix for the random prefix."
  type        = string
}

variable "length" {
  description = "Length of the generated random suffix of the random prefix."
  type        = number
  default     = 8
}
