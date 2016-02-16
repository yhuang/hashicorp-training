resource "aws_instance" "server" {
  count         = "${var.servers}"
  ami           = "${var.ami}"

  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${var.subnet_id}"

  vpc_security_group_ids = ["${var.security_group}"]

  connection {
    user     = "ubuntu"
    key_file = "${var.private_key_path}"
  }

  tags { Name = "${var.name}-${count.index}" }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/wait-for-ready.sh"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/upstart.conf"
    destination = "/tmp/upstart.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'CONSUL_SERVERS=${var.servers}' | sudo tee -a /etc/service/consul",
      "echo 'ATLAS_ENVIRONMENT=${var.atlas_environment}' | sudo tee -a /etc/service/consul",
      "echo 'ATLAS_TOKEN=${var.atlas_token}' | sudo tee -a /etc/service/consul",
      "echo 'NODE_NAME=consul-${count.index}' | sudo tee -a /etc/service/consul",
      "sudo service consul restart"
    ]
  }
}

output "address" { value = "${aws_instance.server.0.public_dns}" }
output "ip" { value = "${aws_instance.server.0.public_ip}" }
