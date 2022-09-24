
# HTTPS Dedicated Internal Redirector
resource "linode_instance" "internal-redirector-1" {
    label = "internal-redirector-1"
    image = "linode/ubuntu18.04"
    region = "us-east"
    type = "g6-nanode-1"
    authorized_keys = [linode_sshkey.ssh_key.ssh_key]
    root_pass = random_string.random.result

    swap_size = 256
    private_ip = false

    depends_on = [linode_instance.lighthouse]

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
        source = "configs/nebula/config-internal.yaml"
        destination = "/tmp/config.yaml"
    }

    provisioner "file" {
        source = "certificates/ca.crt"
        destination = "/tmp/ca.crt"
    }

    provisioner "file" {
        source = "certificates/internal-redirector-1.crt"
        destination = "/tmp/host.crt"
    }

    provisioner "file" {
        source = "certificates/internal-redirector-1.key"
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
      "ufw allow from 192.168.100.10",
      "ufw allow from 192.168.100.200",
      "apt install socat -y",
      "cat /tmp/key.pub >> /root/.ssh/authorized_keys",
      "rm /tmp/key.pub",
      "mkdir /etc/nebula",
      "mv /tmp/host.* /etc/nebula",
      "mv /tmp/ca.crt /etc/nebula",
      "mv /tmp/config.yaml /etc/nebula",
      "mv /tmp/nebula /etc/nebula/nebula",
      "sed -i 's/LIGHTHOUSE_IP_ADDRESS/${linode_instance.lighthouse.ip_address}/g' /etc/nebula/config.yaml",
      "chmod +x /etc/nebula/nebula",
      "echo 'socat TCP4-LISTEN:443,fork TCP4:192.168.100.200:443' | at now + 1 min",
      "echo '/etc/nebula/nebula -config /etc/nebula/config.yaml' | at now + 1 min",
      "echo 'ufw --force enable' | at now + 1 min",
      "touch /tmp/task.complete"
    ]
  }
}

# DNS Dedicated Internal Redirector
resource "linode_instance" "internal-redirector-2" {
    label = "internal-redirector-2"
    image = "linode/ubuntu18.04"
    region = "us-east"
    type = "g6-nanode-1"
    authorized_keys = [linode_sshkey.ssh_key.ssh_key]
    root_pass = random_string.random.result

    swap_size = 256
    private_ip = false

    depends_on = [linode_instance.lighthouse]

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
        source = "configs/nebula/config-internal.yaml"
        destination = "/tmp/config.yaml"
    }

    provisioner "file" {
        source = "certificates/ca.crt"
        destination = "/tmp/ca.crt"
    }

    provisioner "file" {
        source = "certificates/internal-redirector-2.crt"
        destination = "/tmp/host.crt"
    }

    provisioner "file" {
        source = "certificates/internal-redirector-2.key"
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
      "ufw allow from 192.168.100.20",
      "ufw allow from 192.168.100.200",
      "cat /tmp/key.pub >> /root/.ssh/authorized_keys",
      "rm /tmp/key.pub",
      "mkdir /etc/nebula",
      "mv /tmp/host.* /etc/nebula",
      "mv /tmp/ca.crt /etc/nebula",
      "mv /tmp/config.yaml /etc/nebula",
      "mv /tmp/nebula /etc/nebula/nebula",
      "systemctl disable systemd-resolved.service",
      "systemctl stop systemd-resolved",
      "rm -f /etc/resolv.conf",
      "echo 'nameserver 8.8.8.8' >> /etc/resolv.conf",
      "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf",
      "iptables -I INPUT -p udp -m udp --dport 53 -j ACCEPT",
      "iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to-destination 192.168.100.200:53",
      "iptables -t nat -A POSTROUTING -j MASQUERADE",
      "iptables -I FORWARD -j ACCEPT",
      "iptables -P FORWARD ACCEPT",
      "sysctl net.ipv4.ip_forward=1",
      "sed -i 's/LIGHTHOUSE_IP_ADDRESS/${linode_instance.lighthouse.ip_address}/g' /etc/nebula/config.yaml",
      "chmod +x /etc/nebula/nebula",
      "echo '/etc/nebula/nebula -config /etc/nebula/config.yaml' | at now + 1 min",
      "echo 'ufw --force enable' | at now + 1 min",
      "touch /tmp/task.complete"
    ]
  }
}