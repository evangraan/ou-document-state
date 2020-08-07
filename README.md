# Introduction
This repository presents a terra-form driven infrastructure solution to uploading a file in a client organizational unit context to S3 and maintaining state for it (new, accepted, rejected, pending, resubmitted)

## Workflow:
- An OU is created by adding it to the list of OUs
- Terraform will then create an IAM group for the OU
- Each OU gets its own group policy with sufficient S3 permissions only to that OU's folder
- A user is registered in Cognito
- The user is assigned to an OU role
- The user uses an SPA which uses an API gateway endpoint to upload a file to an OU folder
- A lambda receives the request and authorizes the user's IAM role and OU membership
- The lambda examines an S3 bucket and creates an OU directory structure if it does not exist
- The lambda places the file in the S3 bucket and OU folder if authorization succeeds
- The lambda presents an error if authorization fails
- The lambda presents an error if the file already exists in the OU directory in the S3 bucket
- The file is initially placed in a "s3://bucket/OU/new" folder
- A validation lambda moves the file to either approved, rejected or pending
- A lambda can only be re-submitted if it is in pending
- If a file is in pending and is uploaded, it is deleted from pending and placed in resubmitted
- If a file is in resubmitted when rejected, the file is moved to rejected and may not be uploaded again.
- A deletion lambda deletes the file
- A list request lists all files in the OU directory, given a state filter (new, pending, rejected, accepted, resubmitted)

## What is not included
- This repo does not include any lambda code to perform the state transitions

## Provisioning
- The top-level bucket must be created manually? (fails no such bucket when trying to create s3 bucket resource?)
- Add new sites by adding their OU identifier to the ou-roles list in ous.tf
- If desired, enable logging at the API gateway top-level with a AmazonAPIGatewayPushToCloudWatchLogs enabled role

```
terraform init
terraform apply
```

