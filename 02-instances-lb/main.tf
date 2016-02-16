// We are going to create a compute resource ("web") in EC2. There are a
// number of optional parameters Terraform can accept, but we are only going
// to use the required ones for now.
resource "aws_instance" "web" {
  // The count parameter tells Terraform to create 3 of the same instances.  Instead
  // of copying and pasting this resource block multiple times, we can easily
  // scale outward and inward with the count parameter.  Usually this parameter
  // is set to a variable, but we will hardcode the value here for simplicity.
  count = 3

  // The ami paramter sets the AMI ID (e.g. "ami-dfba9ea8").  Since AMIs are
  // region-specific, we can ask Terraform to look up the proper AMI ID from our
  // mapping variable aws_amis in the aws.tf file.
  //
  // Notice that we access variables using the "var" keyword and a "dot"
  // notation.  The "lookup" function is built into Terraform and provides
  // a way to look up a value in a map.
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  // For demonstration purposes, we will launch the smallest instance.
  instance_type = "t2.micro"

  // We could hard-code the key_name to the string "terraform-tutorial" from
  // above, but Terraform allows us to reference our key pair resource block.
  // Referencing our key pair resource this way also declares the AWS key pair
  // as a dependency of the aws_instance resource.  Terraform builds a graph of
  // all the resources and executes in parallel where possible.  If we just
  // hard-coded the name, Terraform may attempt to create the instance first
  // before the AWS key pair is ready.  This race condition would result in an
  // error.
  key_name = "${aws_key_pair.terraform-tutorial.key_name}"

  // The subnet_id parameter is the subnet in which this instance should run.
  // We can just reference the subnet created by our aws.tf file.
  subnet_id = "${aws_subnet.terraform-tutorial.id}"

  // The vpc_security_group_ids parameter specifies the security group(s) to
  // which this instance belongs.  We can reference the security group created
  // in the aws.tf file.  This security group allows all ingress and egress
  // traffic through to help simplify the tutorial.
  vpc_security_group_ids = ["${aws_security_group.terraform-tutorial.id}"]

  // Tags are arbitrary key-value pairs that can help you organize your AWS
  // resources.   The "Name" tag is special, because it is displayed in
  // the AWS EC2 web console and can help in the identification of the EC2
  // instance.
  tags { Name = "web-${count.index}" }

  // Terraform uses a number of defaults when connecting to a resource, but
  // these can be overridden using `connection` block in either a resource or
  // provisioner.
  //
  // Within the EC2 instance, you can optionally have a `connection` block.
  // The `connection` blocks describe to Terraform how to connect to the
  // resource for provisioning.  Terraform will use "sane defaults" to access
  // the EC2 instance, but since we are using a custom SSH key, the
  // `connection` block is required.
  //
  // https://www.terraform.io/docs/configuration/resources.html
  connection {
    user     = "ubuntu"
    key_file = "${path.module}/${var.private_key_path}"
  }

  // The `remote-exec` provisioner invokes a script on a remote resource
  // after it is created.  The `remote-exec` provisioner supports both
  // `ssh` and `winrm` type connections.
  //
  // The first remote-exec provisioner is used to wait for `cloud-init` to
  // finish.  Without this line, Terraform may try to provision the instance
  // before `apt` has updated all its sources.  The default behavior without
  // this `remote-exec` provisioner is not a Terraform bug; instead, it is an
  // implementation detail of an operating system and the way that
  // operating system runs on the cloud platform.
  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/wait-for-ready.sh"
    ]
  }

  // Use the `remote-exec` provisioner to execute commands that will install
  // a simple web server.
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get --yes install apache2",
      "echo \"<h1>${self.public_dns}</h1>\" | sudo tee /var/www/html/index.html",
      "echo \"<h2>${self.public_ip}</h2>\"  | sudo tee -a /var/www/html/index.html"
    ]
  }
}

// This block creates a new elastic load balancer (ELB).
resource "aws_elb" "web" {
  // The name parameter defines the name of the ELB.
  name = "web"


  // The subnets parameter defines a list of subnet IDs to attach to the ELB,
  // so the ELB can forward traffic to the instances.
  subnets = ["${aws_subnet.terraform-tutorial.id}"]

  // The security_groups parameter specifies a list of security group IDs to
  // assign to the ELB.
  security_groups = ["${aws_security_group.terraform-tutorial.id}"]

  // The listener block tells the ELB on which port(s) to listen.  This block
  // can be enumerated multiples to specify multiple ports.  Since we are
  // just declaring a simple web server, port 80 is sufficient.
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  // The health_check block sets a health check for the ELB. If  instances in
  // the ELB are reported as "unhealthy", they will stop receiving traffic.
  // The test below is a simple HTTP check to each instance on port 80.
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  // The instances parameter enumerates the list of EC2 instances that will
  // be attached to this load balancer.  Please take note of the splat(*)
  // operator in the variable interpolation.  The splat operator lets
  // Terraform know to use all of the instances created via the count
  // parameter above.
  instances = ["${aws_instance.web.*.id}"]

  // Tags are arbitrary key-value pairs that can help you organize your AWS
  // resources.   The "Name" tag is special, because it is displayed in
  // the AWS EC2 web console and can help in the identification of the ELB.
  tags { Name = "terraform-tutorial" }
}

// This block defines output variables Terraform will need to export.
// This particular module will output the ELB's public DNS and a list
// of the EC2 instances attached to that ELB.
output "elb-address" { value = "${aws_elb.web.dns_name}" }
output "instance-ips" { value = "${join(", ", aws_instance.web.*.public_ip)}"}

// Run `terraform apply 02-instances-lb` and Terraform will create three new
// instances, a load balancer, and all the pieces to wire them together.

// Once the apply has finished, AWS will health check the instances and then add
// them to the load balancer if they pass.  This process can take a few minutes
// the first time.  For this reason, you can visit each of the IP addresses of
// the instances first.  Once the load balancer is healthy with all three
// instances, go to the address in your browser.  Keep refreshing the page and
// you should see different IP addresses cycle for the three instances.
