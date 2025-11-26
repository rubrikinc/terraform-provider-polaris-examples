output "result" {
  description = "Result of the random prefix."
  value       = format("%s_%s", var.prefix, random_string.suffix.result)
}
