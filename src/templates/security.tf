resource "random_string" "random" {
  length = 16
  special = true
}

resource "tls_private_key" "temp_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "linode_sshkey" "ssh_key" {
  label = "key"
  ssh_key = chomp(tls_private_key.temp_key.public_key_openssh)
}
