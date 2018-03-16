# Serverless Secured Image/Video Gallery Website

password protected Image/Video Gallery built ontop of AWS Services

> this Project started as a simple Terraform Port of [AWSPics](https://github.com/jpsim/AWSPics), so most ideas comes from there.

## Whats inside

* AWS Cloudfront (delivers the website)
* AWS Certificate Manager (ssl all the things)
* AWS S3 (for storing original images/videos, the encoded/resized ones, the final static website)
* AWS Transcoder Service (transcode videos into a web usable format)
* AWS Lambda (handling login, triggering video encoding, resizing images, building the static website)
* AWS Cognito (for user management)
* AWS KMS (encrypt what could be encrypted, cloudfront cant read from encrypted buckets :( )
* AWS Cloudwatch (trigger the website build every hour, collect all the logs)

## Differences to AWSPics

* Terraform instead of Cloudformation (for obvious reasons ;) )
* AWS Cognito for User Management instead of `.htaccess`
* Video Support
* Image Sourcesets
* [GatsbyJS](https://www.gatsbyjs.org/) for static Site Generation
* Album Post through simple Markdown File and `frontmatter`

## Prerequisites

1.
Docker for building the lambda functions

2.
a certificate for your `domain` or `certdomain` should already exists (in `us-east-1` for cloudfront)

3.
the encrypted cloudfront private key

> TODO automate, for now the key is created in the stack, so you have to run the stack twice with the generated hash

Create CloudFront Key Pair, take note of the key pair ID and download the private key: https://console.aws.amazon.com/iam/home?region=us-east-1#/security_credential.

Encrypt the CloudFront private key:

```
aws kms encrypt --key-id $KMS_KEY_ID --plaintext "$(cat pk-*.pem)" \
                --query CiphertextBlob --output text
```

put this encrypted key into the variable `encrypted_cloudfront_private_key`
put the key_pair ID into `cloudfront_key_pair`

> thats needed to generate signed cloudfront cookies

4.
a user in your [AWS Cognito User Pool](https://eu-central-1.console.aws.amazon.com/cognito/home?region=eu-central-1#) after the stack is initially completed

> so your users can login

## Usage

```tf
//terraform.tfvars

domain = "testing.digitalkaoz.net"
region = "eu-central-1"
certdomain = "digitalkaoz.net" #only if your domain is a subdomain
cloudfront_key_pair = "XYZ"
encrypted_cloudfront_private_key = "XYZ"
website_config = {
    title = "website title"
    subline = "sub headline"
    short_code = "the websites short name"
    author = "the author"
}
```

```tf
//main.tf

provider "aws" {
  region  = "eu-central-1"
  profile = "default"
  version = "~> 1.11"
}

provider "aws" {
  alias   = "us"
  region  = "us-east-1"
  profile = "default"
  version = "~> 1.11"
}

module "ssl_private_image_gallery" {
  source = "github.com/digitalkaoz/tf-private-static-image-video-gallery"

  region                           = "${var.region}"
  domain                           = "${var.domain}"
  certdomain                       = "${var.certdomain}"
  cloudfront_key_pair              = "${var.cloudfront_key_pair}"
  encrypted_cloudfront_private_key = "${var.encrypted_cloudfront_private_key}"
  website_config                   = "${var.website_config}"
}
```

## TODO

* encrypt more stuff
* handle building of lambda functions outside of terraform?! would fix the needless terraform state changes but would need another tooling step :/
* extract image metadata for later usage (e.g. geolocated on a worldmap)
* certificate generation with DNS validation
* cloudfront key_pair handling complete inside terraform
* remove/publish gatsby lambda patches/hacks
* fix gatsby css generation in lambda (to get rid of custom html.js + proper styles toolchain)
