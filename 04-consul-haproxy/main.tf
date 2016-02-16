variable "atlas_username" {}
variable "atlas_consul_token" {}
variable "atlas_environment" {}

variable "zone_id" {}

resource "aws_instance" "web" {
  count = 2
  ami   = "${lookup(var.aws_amis, var.aws_region)}"

  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.terraform-tutorial.key_name}"
  subnet_id     = "${aws_subnet.terraform-tutorial.id}"

  vpc_security_group_ids = ["${aws_security_group.terraform-tutorial.id}"]

  tags { Name = "web-${count.index}" }

  connection {
    user     = "ubuntu"
    key_file = "${path.module}/${var.private_key_path}"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/wait-for-ready.sh"
    ]
  }

  // Notice that we have removed the manual insertion of the DNS and IP.  We
  // are going to rely on Consul and Consul Template to render this file for us
  // instead.
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get --yes install apache2"
    ]
  }

  // Install and configure Consul and Consul Template.
  provisioner "file" {
    source      = "${path.module}/scripts/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/web.json"
    destination = "/tmp/web.json"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install-consul.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'ATLAS_ENVIRONMENT=${var.atlas_environment}' | sudo tee -a /etc/service/consul",
      "echo 'ATLAS_TOKEN=${var.atlas_consul_token}' | sudo tee -a /etc/service/consul",
      "echo 'NODE_NAME=web-${count.index}' | sudo tee -a /etc/service/consul",
      "sudo service consul restart"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/index.html.ctmpl"
    destination = "/tmp/index.html.ctmpl"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/consul-template-apache.conf"
    destination = "/tmp/consul-template.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install-consul-template.sh"
    ]
  }
}

// This is replacing the ELB from 02-instances-lb.  Instead of using the
// ELB from AWS, we will use our own.  Most of these attributes should already
// be familiar to you, so we will skip down to the provisioner.
resource "aws_instance" "haproxy" {
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.terraform-tutorial.key_name}"
  subnet_id     = "${aws_subnet.terraform-tutorial.id}"

  vpc_security_group_ids = ["${aws_security_group.terraform-tutorial.id}"]

  tags { Name = "haproxy" }

  connection {
    user     = "ubuntu"
    key_file = "${path.module}/${var.private_key_path}"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/wait-for-ready.sh"
    ]
  }

  // Install and configure Consul and Consul Template.
  provisioner "file" {
    source      = "${path.module}/scripts/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/haproxy.json"
    destination = "/tmp/haproxy.json"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install-consul.sh",
      "${path.module}/scripts/install-haproxy.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'ATLAS_ENVIRONMENT=${var.atlas_environment}' | sudo tee -a /etc/service/consul",
      "echo 'ATLAS_TOKEN=${var.atlas_consul_token}' | sudo tee -a /etc/service/consul",
      "echo 'NODE_NAME=haproxy' | sudo tee -a /etc/service/consul",
      "sudo service consul restart"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/haproxy.cfg.ctmpl"
    destination = "/tmp/haproxy.cfg.ctmpl"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/consul-template-haproxy.conf"
    destination = "/tmp/consul-template.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install-consul-template.sh"
    ]
  }
}

resource "aws_route53_record" "haproxy" {
   zone_id = "${var.zone_id}"
   name = "haproxy"
   type = "CNAME"
   ttl = 30
   records = ["${aws_instance.haproxy.public_dns}"]
}

resource "aws_route53_record" "consul" {
   zone_id = "${var.zone_id}"
   name = "consul"
   type = "A"
   ttl = 30

   // https://github.com/sethvargo/tf-consul-atlas-join/blob/master/main.tf#L47
   records = ["${module.consul.ip}"]
}

// Output the DNS address so you can easily copy-and-paste into the browser.
output "web" { value = "${aws_route53_record.haproxy.fqdn}" }
output "consul-ui" { value = "${aws_route53_record.consul.fqdn}:8500/ui" }

// Run `terraform plan 03-consul-haproxy`, and Terraform will complain that the
// module is not found:
//
// Error downloading modules: module consul: not found, may need to be downloaded

// Run `terraform get 03-consul-haproxy` to download the module and re-run
// the plan:
//
// Get: git::https://github.com/sethvargo/tf-consul-atlas-join.git

// Now run `terraform apply 03-consul-haproxy`.  Terraform will create one
// new instance for our HAProxy load balancer, but it will also schedule the
// termination of the ELB.

// Once the apply has finished, AWS will have provisioned one new instance and
// destroyed the load balancer, but you will notice that the existing instances
// are not running Consul.  Even though we added information to the
// provisioner, Terraform's provisioner is only done during initial instance
// creation.

// Following the immutable infrastructure paradigm, we need to destroy these web
// instances and create new ones to provision them (we will move this to build
// time steps shortly).

// We can tell Terraform to destroy and recreate the instances using the
// `terraform taint` command:
//
//     $ terraform taint aws_instance.web.0
//     $ terraform taint aws_instance.web.1
//     $ terraform taint aws_instance.web.2
//
// Not being able to specify `.web.*` is annoying, but this handicap is a
// safety feature in Terraform, because tainting is a potentially dangerous
// operation.

// Note that tainting a resource is a _local_ operation.  We have not yet
// changed any production resources.  If you run
// `terraform plan 03-consul-haproxy`, you will see the "-/+", indicating
// that Terraform is going to destroy and create new instance.

// Run `terraform apply 03-consul-haproxy` to destroy and create
// these new instances (thus installing Consul).  In addition,
// a subdomain pointing to the CNAME of the HAProxy will be created.
