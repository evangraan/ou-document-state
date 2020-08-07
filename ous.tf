variable "ou_ids" {
  type        = list
  description = "The list of OU S3 folders to create"
  default     = ["ou001", "ou002", "ou003"]
}

variable "ou_states" {
  type        = list
  description = "The od an OU document"
  default     = ["new", "resubmitted", "pending", "rejected", "approved"]	
}

