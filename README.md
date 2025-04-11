# Instagram Post Extractor

This project provides an AWS Lambda function, exposed via API Gateway, designed to extract information from public Instagram posts.

## Features

*   Accepts an Instagram post URL.
*   Fetches the post's metadata (specifically the `og:title`).
*   Uses AWS Bedrock (Language Model) to attempt to extract address-like text from the title.
*   Returns a JSON response containing Google Maps links for any extracted addresses.

## Deployment

The infrastructure (Lambda, API Gateway, CloudWatch Logs) is managed using Terraform. The Lambda function code needs to be packaged into a zip file and uploaded to S3 for deployment (see `INSTALL.md` for packaging steps).
