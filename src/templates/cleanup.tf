resource "null_resource" "pre_setup" {
  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
      rm certificates/*
      rm keys/red*
      rm -rf /tmp/working_dir /tmp/nebula*
    EOT
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }
}