resource "linode_domain" "c2-domain" {
    type = "master"
    domain = var.linode_domain
    soa_email = "soa@${var.linode_domain}"
    ttl_sec = 120
    tags = []

    depends_on = [linode_instance.edge-redirector-1]
}

resource "linode_domain_record" "root" {
    domain_id = linode_domain.c2-domain.id
    name = var.linode_domain
    record_type = "A"
    ttl_sec = 120
    target = linode_instance.edge-redirector-1.ip_address

    depends_on = [linode_instance.edge-redirector-1]
}

resource "linode_domain_record" "ns1" {
    domain_id = linode_domain.c2-domain.id
    name = "ns1"
    record_type = "A"
    ttl_sec = 120
    target = linode_instance.internal-redirector-2.ip_address

    depends_on = [linode_instance.edge-redirector-2]
}

resource "linode_domain_record" "dns" {
    domain_id   = linode_domain.c2-domain.id
    record_type = "NS"
    target      = "ns1.${var.linode_domain}"
    ttl_sec = 120

    depends_on = [linode_domain_record.ns1]
}
