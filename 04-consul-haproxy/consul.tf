// For this tutorial, we are using a special version of the official
// Consul module, which is included in the official Consul repo at
// https://github.com/hashicorp/consul under the `terraform` folder
module "consul" {
  // The source parameter defines the source of the Consul module.
  // GitHub is one of the sources supported by Terraform.
  //
  // https://www.terraform.io/docs/modules/sources.html
  source = "github.com/sethvargo/tf-consul-atlas-join"

  // The ami parameter sets the AMI ID for the specified AWS region.
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  // This parameter tells the Consul module to create 3 servers.
  servers = 3

  // These two parameters tells the Consul module to launch the specified
  // number of Consul servers with the assigned security group and inside
  // our VPC
  subnet_id      = "${aws_subnet.terraform-tutorial.id}"
  security_group = "${aws_security_group.terraform-tutorial.id}"

  // The aws_key_pair resource is declared in aws.tf.
  key_name         = "${aws_key_pair.terraform-tutorial.key_name}"

  // Sometimes files that are not Terraform configuration files can be
  // embed within a module.  These embedded files can provisioning scripts
  // or uploaded assets.
  //
  // In these cases, you cannot use a relative path, since paths in Terraform
  // are generally relative to the working directory that Terraform was
  // executed from.  Instead, you want to use a module-relative path.
  //
  // To reference path information, the syntax is `path.TYPE`.  `TYPE` can be
  // `cwd`, `module`, or `root`.  `cwd` will interpolate the current working
  // directory.  `module` will interpolate the path to the current module.
  // `root` will interpolate the path of the root module.
  //
  // In the case below, the interpolated string will resolve to:
  //
  // "03-consul-haproxy/keys/terraform-tutorial"
  private_key_path = "${path.module}/${var.private_key_path}"

  // These variables are provided via our top-level module so that the Consul
  // cluster can join using Atlas.  These two parameters remove the need to use
  // a "well-known" IP address for the new Consul servers join the cluster,
  // and it gives us the web interface in Atlas.
  //
  // https://github.com/sethvargo/tf-Consul-atlas-join/blob/master/variables.tf#L21-L27
  atlas_environment = "${var.atlas_environment}"
  atlas_token       = "${var.atlas_consul_token}"
}
