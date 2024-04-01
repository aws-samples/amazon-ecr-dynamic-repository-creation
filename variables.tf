variable "SCAN_TYPE" {
  type        = string
  description = "Registry scan type `BASIC` or `ENHANCED`"
}
variable "SCAN_FREQUENCY" {
  type        = string
  description = "Registry scan frequency SCAN_ON_PUSH, CONTINUOUS_SCAN, or MANUAL"
}

variable "IMAGE_TAG_MUTABILITY" {
  type        = string
  description = "ECR repo image tag mutability setting set on every repo Lambda creates. One of `MUTABLE` or `IMMUTABLE`."
}

variable "REPO_TAGS" {
  type        = map(string)
  description = "ECR repo tags added to every repo Lambda creates."
}

variable "REPO_SCAN_ON_PUSH" {
  type        = bool
  description = "Toggles Scan on push on repos Lambda creates."
}