resource "linode_instance" "lighthouse" {
    label = "lighthouse"
    image = "linode/ubuntu18.04"
    region = "us-east"
    type = "g6-nanode-1"
    authorized_keys = [linode_sshkey.ssh_key.ssh_key]
    root_pass = random_string.random.result

    swap_size = 256
    private_ip = false

    depends_on = []

    connection {
        host = self.ip_address
        user = "root"
        type = "ssh"
        private_key = tls_private_key.temp_key.private_key_pem
        timeout = "10m"
    }

    provisioner "file" {
        source = "keys/red_nebula_rsa.pub"
        destination = "/tmp/key.pub"
    }

    provisioner "file" {
        source = "configs/nebula/config-lighthouse.yaml"
        destination = "/tmp/config.yaml"
    }

    provisioner "file" {
        source = "certificates/ca.crt"
        destination = "/tmp/ca.crt"
    }

    provisioner "file" {
        source = "certificates/lighthouse1.crt"
        destination = "/tmp/host.crt"
    }

    provisioner "file" {
        source = "certificates/lighthouse1.key"
        destination = "/tmp/host.key"
    }

    provisioner "file" {
        source = "/tmp/nebula/nebula"
        destination = "/tmp/nebula"
    }

    provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/local/bin",
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update",
      "yes | apt-get upgrade",
      "ufw allow 22",
      "ufw allow 4242/udp",
      "cat /tmp/key.pub >> /root/.ssh/authorized_keys",
      "rm /tmp/key.pub",
      "mkdir /etc/nebula",
      "mv /tmp/host.* /etc/nebula",
      "mv /tmp/ca.crt /etc/nebula",
      "mv /tmp/config.yaml /etc/nebula",
      "mv /tmp/nebula /etc/nebula/nebula",
      "chmod +x /etc/nebula/nebula",
      "echo '/etc/nebula/nebula -config /etc/nebula/config.yaml' | at now + 1 min",
      "echo 'ufw --force enable' | at now + 1 min",
      "touch /tmp/task.complete"
    ]
  }
}