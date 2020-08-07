# Organizational units - call these "sites" and "ods codes"

resource "aws_iam_group" "ous" {
  for_each = var.ou_ids
  name  = "ou_${each.value}"
  path = "/ous/"
}

resource "aws_iam_policy" "ous-group-policy-id" {
  for_each    = var.ou_ids
  name        = "ous-group-policy-${each.value}"
  description = "Permissions for ous group"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",

      "Resource": "arn:aws:s3:::ou-document-state/documents/${each.value}"
    }   
  ]
}
  POLICY
}

resource "aws_iam_group_policy_attachment" "ous-group-policy-attach" {
  for_each = var.ou_ids
  group  = "ou_${each.value}"
  policy_arn = "arn:aws:iam::477493894311:policy/ous-group-policy-${each.value}"
}

# API gateway and lambda
resource "aws_iam_role" "role" {
  name = "test-lambda-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["apigateway.amazonaws.com","lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }   
  ]
}
POLICY
}

data "aws_iam_policy_document" "lambda-role-logging" {
  statement {
      actions = [
        "logs:*",
      ]

      resources = [
        "arn:aws:logs:::*",
      ]      
  }
}

data "aws_iam_policy_document" "lambda-role-bucket" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::ou-document-state",
    ]
  }
}

data "aws_iam_policy_document" "lambda-role-documents" {
  statement {
    sid     = "StorageManagement"
    effect  = "Allow"
    actions = [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:GetBucketLocation",
        "s3:AbortMultipartUpload"
    ]

    resources = [
      "arn:aws:s3:::ou-document-state/documents/*",
    ]
  }  
}

resource "aws_iam_policy" "lambda-role-logging-policy-id" {
  name        = "lambda-role-logging-policy"
  description = "Allow lambda to log"
  policy = data.aws_iam_policy_document.lambda-role-logging.json
}

resource "aws_iam_policy" "lambda-role-bucket-policy-id" {
  name        = "lambda-role-bucket-policy"
  description = "Allow lambda to access the documents bucket"
  policy = data.aws_iam_policy_document.lambda-role-bucket.json
}

resource "aws_iam_policy" "lambda-role-documents-policy-id" {
  name        = "lambda-role-documents-policy"
  description = "Allow lambda to manage documents"
  policy = data.aws_iam_policy_document.lambda-role-documents.json
}

resource "aws_iam_role_policy_attachment" "lambda-role-logging-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.lambda-role-logging-policy-id.arn
}

resource "aws_iam_role_policy_attachment" "lambda-role-bucket-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.lambda-role-bucket-policy-id.arn
}

resource "aws_iam_role_policy_attachment" "lambda-role-documents-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.lambda-role-documents-policy-id.arn
}

resource "aws_api_gateway_deployment" "integration" {
  depends_on = [aws_api_gateway_integration.integration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "test"

  lifecycle {
    create_before_destroy = true
  }
}