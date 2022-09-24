resource "null_resource" "setup" {
  provisioner "local-exec" {
    command = <<-EOT
      wget -O /tmp/nebula.tar.gz https://github.com/slackhq/nebula/releases/download/v1.6.0/nebula-linux-amd64.tar.gz
      mkdir /tmp/nebula
      tar -zxvf /tmp/nebula.tar.gz -C /tmp/nebula
      chmod +x keys/generate_key.sh
      keys/generate_key.sh
      cd certificates && /tmp/nebula/nebula-cert ca -name "Red Nebula, Inc"
      /tmp/nebula/nebula-cert sign -name "lighthouse1" -ip "192.168.100.1/24"
      /tmp/nebula/nebula-cert sign -name "edge-redirector-1" -ip "192.168.100.10/24" -groups "edge"
      /tmp/nebula/nebula-cert sign -name "edge-redirector-2" -ip "192.168.100.20/24" -groups "edge"
      /tmp/nebula/nebula-cert sign -name "internal-redirector-1" -ip "192.168.100.110/24" -groups "internal"
      /tmp/nebula/nebula-cert sign -name "internal-redirector-2" -ip "192.168.100.120/24" -groups "internal"
      /tmp/nebula/nebula-cert sign -name "team-server" -ip "192.168.100.200/24" -groups "team-server"
      /tmp/nebula/nebula-cert sign -name "operator" -ip "192.168.100.250/24" -groups "operator"
      cp configs/nebula/config-operator.yaml /tmp/nebula
    EOT
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }
}