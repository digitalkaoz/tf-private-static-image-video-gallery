# Serverless Secured Image/Video Gallery Website

password protected Image/Video Gallery built ontop of AWS Services

> this Project started as a simple Terraform Port of [AWSPics](https://github.com/jpsim/AWSPics), so most ideas comes from there.

## Demo

[Demo Deployment](https://gallery-demo.digitalkaoz.net/)

use these credentials: `demouser` : `demouser`

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

create and download a cloudfront private key [here](https://console.aws.amazon.com/iam/home?region=us-east-1#/security_credential), note the ID

put the absolute path to file into the variable `cloudfront_private_key_file`
put the key_pair ID into `cloudfront_key_pair`

> thats needed to generate signed cloudfront cookies and the ability to login

4.
a user in your [AWS Cognito User Pool](https://eu-central-1.console.aws.amazon.com/cognito/home?region=eu-central-1#) after the stack is initially completed

> so your users can login

## Usage

```tf
//terraform.tfvars

domain = "gallery-demo.digitalkaoz.net"
region = "eu-central-1"
certdomain = "digitalkaoz.net" #only if your domain is a subdomain
cloudfront_key_pair = "XYZ"
cloudfront_private_key_file = "/path/to/cloudfront_private_key.pem"
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
  cloudfront_private_key_file      = "${var.cloudfront_private_key_file}"
  website_config                   = "${var.website_config}"
}
```

you have to wait until your Cloudfront Distribution is done deploying, so grab a coffee (~20min) before going on

### uploading images and videos

simply drop your files (categorized by folders) inside the `source` bucket into the folder `original`

### providing folder metadata

simply create a markdown file inside the folder named `post.md`

### creating users

simply create them inside `AWS Cognito`

## TODO

* encrypt more stuff
* handle building of lambda functions outside of terraform?! would fix the needless terraform state changes but would need another tooling step :/
* extract image metadata for later usage (e.g. geolocated on a worldmap)
* certificate generation with DNS validation
* remove/publish gatsby lambda patches/hacks
* Fix Terraform Building of function code ordering = build -> package -> upload -> create_function (sometimes its wrong)
* sometimes the build lambda ist uploaded somehow strange and errors in gatsby site config validation "path should not be null"
* use correct lambda source code hash to minimize tainted resources (sha1, sha256 ? )
* remove css build chain for gatsby in lambda to remove custom `html.js` and hardcoded `static/main.css`
