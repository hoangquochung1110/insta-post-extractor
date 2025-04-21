# Instagram Post Extractor

This project provides an AWS Lambda function, exposed via API Gateway, designed to extract information from public Instagram posts.

## Features

*   Accepts an Instagram post URL.
*   Fetches the post's metadata (specifically the `og:title`).
*   Uses AWS Bedrock (Language Model) to attempt to extract address-like text from the title.
*   Returns a JSON response containing Google Maps links for any extracted addresses.

## Deployment

The infrastructure (Lambda, API Gateway, CloudWatch Logs) is managed using Terraform. The Lambda function code needs to be packaged into a zip file and uploaded to S3 for deployment (see `INSTALL.md` for packaging steps).

## Local Testing

### Prerequisites

- Docker (required to run AWS SAM locally)
- AWS SAM CLI

### Running tests

Use the provided Makefile to execute the local test suite:

```bash
make test
```

This command will spin up an AWS SAM container via Docker and run the positive and negative test cases defined in `tests/events`.
