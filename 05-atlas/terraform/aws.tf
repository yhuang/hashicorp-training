// Many resources in AWS are region-specific.  Instead of hard-coding the
// the AWS region in a given resource declaration, we set the desired
// AWS region to a custom variable.  We then reference the custom variable
// every time a resource declaration requires the AWS region parameter in
// our Terraform template.
variable "AWS_DEFAULT_REGION" {
  default = "us-east-1"
}

// Our AWS access key and AWS secret access key will be referenced as
/  custom variables as well.
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

// The Amazon Web Services (AWS) provider is responsible for understanding
// API interactions and exposing resources supported by AWS.  The AWS
// provider has three required parameters:  region, access_key, and
// secret_key.  These parameters are set to the interpolated values of
// the three custom variables we declared above.
provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region     = "${var.AWS_DEFAULT_REGION}"
}

// This block declares a variable named "aws_amis" that is a mapping of
// each AWS region to the official Ubuntu 14.04 Amazon machine image (AMI)
// that uses hardware virtual machine (HVM) virtualization with EBS support.
// The introdcution of "aws_amis" also allows this tutorial to be adjusted
// geographically with ease.
variable "aws_amis" {
  default = {
    ap-northeast-1 = "ami-d886a1b6"
    ap-southeast-1 = "ami-a17dbac2"
    eu-central-1   = "ami-99cad9f5"
    eu-west-1      = "ami-a317ced0"
    sa-east-1      = "ami-ae44ffc2"
    us-east-1      = "ami-f7136c9d"
    us-west-1      = "ami-44b1de24"
    cn-north-1     = "ami-a664f89f"
    us-gov-west-1  = "ami-30b8da13"
    ap-southeast-2 = "ami-067d2365"
    us-west-2      = "ami-46a3b427"
  }
}

// This public SSH key is used throughout the tutorial.
variable "public_key_path" {
  default = "keys/terraform-tutorial.pub"
}

// This private ssh key is used throughout the tutorial.
variable "private_key_path" {
  default = "keys/terraform-tutorial"
}

// This block declares the public-private SSH key pair packaged with this
// tutorial.
resource "aws_key_pair" "terraform-tutorial" {
  // The ke_yname parameter defines the name of the key pair, and it will
  // show up in the AWS web console or API output, since the actual key
  // (ssh-rsa AAA..) is neither descriptive nor human-friendly.
  key_name = "hashicorp-tutorial"

  // We could hard-code a public key here, as shown below:
  // public_key = "ssh-rsa AAAAB3..."
  //
  // Instead we are going to leverage Terraform's ability to read a file
  // from your local machine using the `file` attribute.
  //
  // Other intrinsic functions are documented here:
  // https://www.terraform.io/docs/configuration/interpolation.html
  public_key = "${file("${var.public_key_path}")}"
}

// This block creates a Virtual Private Network (VPC) for our tutorial. Any
// resource we launch will live inside this VPC.  We will not spend much
// detail here, since these are really Amazon-specific configurations and the
// beauty of Terraform is that you only have to configure them once and forget
// about doing so.
resource "aws_vpc" "terraform-tutorial" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags { Name = "terraform-tutorial" }
}

// The Internet Gateway is like the public router for your VPC.  It provides
// internet to-from resources inside the VPC.
resource "aws_internet_gateway" "terraform-tutorial" {
  vpc_id = "${aws_vpc.terraform-tutorial.id}"
  tags { Name = "terraform-tutorial" }
}

// The subnet is the IP address range your resources will occupy inside the
// VPC. Here we have chosen the 10.0.0.x subnet with a /24 mask bit.  You
// could choose any class C subnet.
resource "aws_subnet" "terraform-tutorial" {
  vpc_id = "${aws_vpc.terraform-tutorial.id}"
  cidr_block = "10.0.0.0/24"
  tags { Name = "terraform-tutorial" }

  map_public_ip_on_launch = true
}

// The Routing Table is the mapping of where traffic should go.  Here we are
// telling AWS that all traffic from the local network should be forwarded to
// the Internet Gateway created above.
resource "aws_route_table" "terraform-tutorial" {
  vpc_id = "${aws_vpc.terraform-tutorial.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terraform-tutorial.id}"
  }

  tags { Name = "terraform-tutorial" }
}

// The Route Table Association binds our subnet and route together.
resource "aws_route_table_association" "terraform-tutorial" {
  subnet_id = "${aws_subnet.terraform-tutorial.id}"
  route_table_id = "${aws_route_table.terraform-tutorial.id}"
}

// The AWS Security Group is akin to a firewall. It specifies the inbound
// (ingress) and outbound (egress) networking rules. This particular
// security group is intentionally insecure for the purposes of this
// tutorial. You should only open those ports required by your production
// environment.
resource "aws_security_group" "terraform-tutorial" {
  name   = "terraform-tutorial-web"
  vpc_id = "${aws_vpc.terraform-tutorial.id}"

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
