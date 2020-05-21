provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.rhel_vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "resource_pool" {
  name          = var.cluster_id
  datacenter_id = data.vsphere_datacenter.dc.id
}
// Request from phpIPAM a new IP addresses for the compute nodes
module "ipam_rhel_master" {
  source         = "./ipam"
  name           = "rhel-master"
  instance_count = var.rhel_master_count
  ipam           = var.ipam
  ipam_token     = var.ipam_token
  machine_cidr   = var.machine_cidr
  ip_addresses   = []
  cluster_domain = var.cluster_domain
}

// Request from phpIPAM a new IP addresses for the compute nodes
module "ipam_rhel_compute" {
  source         = "./ipam"
  name           = "rhel-worker"
  instance_count = var.rhel_compute_count
  ipam           = var.ipam
  ipam_token     = var.ipam_token
  machine_cidr   = var.machine_cidr
  ip_addresses   = []
  cluster_domain = var.cluster_domain
}
module "ipam_rhel_infra" {
  source         = "./ipam"
  name           = "rhel-infra"
  instance_count = var.rhel_infra_count
  ipam           = var.ipam
  ipam_token     = var.ipam_token
  machine_cidr   = var.machine_cidr
  ip_addresses   = []
  cluster_domain = var.cluster_domain
}


// Uncomment this section if you
// would like to create the subdomain
module "dns_cluster_domain" {
  source         = "./cluster_domain"
  cluster_domain = var.cluster_domain
  base_domain    = var.base_domain
}


/*
// If the subdomain already exists
// uncomment this section
data "aws_route53_zone" "cluster" {
  name = var.cluster_domain
}
*/
resource "aws_route53_record" "a_record_master" {
  count = length(module.ipam_rhel_master.ip_addresses)

  type = "A"
  ttl  = "60"

  //if you would like to create the new subdomain
  //uncomment this and above
  zone_id = module.dns_cluster_domain.zone_id

  // This subdomain zone_id should already exist
  // if you have already executed vSphere UPI
  //zone_id = data.aws_route53_zone.cluster.zone_id

  name    = "rhel-master-${count.index}.${var.cluster_domain}"
  records = [module.ipam_rhel_master.ip_addresses[count.index]]
}

resource "aws_route53_record" "a_record_compute" {
  count = length(module.ipam_rhel_compute.ip_addresses)

  type = "A"
  ttl  = "60"

  //if you would like to create the new subdomain
  //uncomment this and above
  zone_id = module.dns_cluster_domain.zone_id

  // This subdomain zone_id should already exist
  // if you have already executed vSphere UPI
  //zone_id = data.aws_route53_zone.cluster.zone_id

  name    = "rhel-compute-${count.index}.${var.cluster_domain}"
  records = [module.ipam_rhel_compute.ip_addresses[count.index]]
}
resource "aws_route53_record" "a_record_infra" {
  count = length(module.ipam_rhel_infra.ip_addresses)

  type = "A"
  ttl  = "60"

  //if you would like to create the new subdomain
  //uncomment this and above
  zone_id = module.dns_cluster_domain.zone_id

  // This subdomain zone_id should already exist
  // if you have already executed vSphere UPI
  //zone_id = data.aws_route53_zone.cluster.zone_id

  name    = "rhel-infra-${count.index}.${var.cluster_domain}"
  records = [module.ipam_rhel_infra.ip_addresses[count.index]]
}

resource "vsphere_virtual_machine" "vm_compute" {
  count = var.rhel_compute_count

  name = element(split(".", aws_route53_record.a_record_compute[count.index]["name"]), 0)

  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.compute_num_cpus
  memory           = var.compute_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  folder           = var.cluster_id
  enable_disk_uuid = "true"

  wait_for_guest_net_timeout  = "10"
  wait_for_guest_net_routable = "true"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = 60
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = element(split(".", aws_route53_record.a_record_compute[count.index]["name"]), 0)
        domain    = var.cluster_domain
      }
      network_interface {
        ipv4_address = module.ipam_rhel_compute.ip_addresses[count.index]
        # TODO: This needs to be a var
        ipv4_netmask = 26
        # TODO: This needs to be a var
      }
      ipv4_gateway    = "139.178.89.193"
      dns_server_list = var.vm_dns_addresses
    }
  }
}

resource "vsphere_virtual_machine" "vm_infra" {
  count = var.rhel_infra_count

  name = element(split(".", aws_route53_record.a_record_infra[count.index]["name"]), 0)

  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.compute_num_cpus
  memory           = var.compute_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  folder           = var.cluster_id
  enable_disk_uuid = "true"

  wait_for_guest_net_timeout  = "10"
  wait_for_guest_net_routable = "true"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = 60
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = element(split(".", aws_route53_record.a_record_infra[count.index]["name"]), 0)
        domain    = var.cluster_domain
      }
      network_interface {
        ipv4_address = module.ipam_rhel_infra.ip_addresses[count.index]
        # TODO: This needs to be a var
        ipv4_netmask = 26
        # TODO: This needs to be a var
      }
      ipv4_gateway    = "139.178.89.193"
      dns_server_list = var.vm_dns_addresses
    }
  }
}
resource "vsphere_virtual_machine" "vm_master" {
  count = var.rhel_master_count

  name = element(split(".", aws_route53_record.a_record_master[count.index]["name"]), 0)

  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.compute_num_cpus
  memory           = var.compute_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  folder           = var.cluster_id
  enable_disk_uuid = "true"

  wait_for_guest_net_timeout  = "10"
  wait_for_guest_net_routable = "true"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = 60
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = element(split(".", aws_route53_record.a_record_master[count.index]["name"]), 0)
        domain    = var.cluster_domain
      }
      network_interface {
        ipv4_address = module.ipam_rhel_master.ip_addresses[count.index]
        # TODO: This needs to be a var
        ipv4_netmask = 26
        # TODO: This needs to be a var
      }
      ipv4_gateway    = "139.178.89.193"
      dns_server_list = var.vm_dns_addresses
    }
  }
}
resource "local_file" "ansible_hosts_file" {
  content = templatefile("${path.module}/hosts.tmpl", {
    compute = aws_route53_record.a_record_compute.*.name,
    master =  aws_route53_record.a_record_master.*.name,
    infra =   aws_route53_record.a_record_infra.*.name,
  })

  filename = "${path.module}/hosts.ini"
}

