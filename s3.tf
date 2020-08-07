
locals {
	folders = "${setproduct(var.ou_ids, var.ou_states)}"
}

resource "aws_s3_bucket_object" "documents-folder" {
    bucket = "ou-document-state"
    acl    = "private"
    key    = "documents/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "documents-states" {
    count  = length(var.ou_ids) * length(var.ou_states)
    bucket = "ou-document-state"
    acl    = "private"
    key    = "documents/${element(local.folders, count.index)[0]}/${element(local.folders, count.index)[1]}/"
    source = "/dev/null"
}

