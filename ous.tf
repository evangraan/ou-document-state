# Use a map instead of a list as in this example.
# Terraform only knows the first and last nodes in lists
# As a result, if an item in the middle of the list is removed,
# terraform deletes all resources in AWS in the list and recreates the 
# resources, now with the item removed.
# As maps are keyed however, when an entry in a map is deleted, terraform
# only deletes the resources for that one entry. This is preferable even
# though the syntax is more verbose

#variable "ou_ids" {
#  type        = list
#  description = "The list of OU S3 folders to create"
#  default     = ["ou001", "ou002", "ou003"]
#}

variable "ou_ids" {
    type       = map
    description = "The list of OU S3 folders to create"

default = {
        ou001 = "ou001"
        ou002 = "ou002"
        ou003 = "ou003"
    }
}

variable "ou_states" {
  type        = list
  description = "The od an OU document"
  default     = ["new", "resubmitted", "pending", "rejected", "approved"]	
}

