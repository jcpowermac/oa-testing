//dns1 = "139.178.89.254"
vm_dns_addresses = ["1.1.1.1", "9.9.9.9"]
//vm_dns_addresses = ["139.178.89.253"]

// ID identifying the cluster to create. Use your username so that resources created can be tracked back to you.
cluster_id = "jcallen-311"

// Domain of the cluster. This should be "${cluster_id}.${base_domain}".
cluster_domain = "jcallen-311.devcluster.openshift.com"

// Base domain from which the cluster domain is a subdomain.
base_domain = "devcluster.openshift.com"

// Name of the vSphere server. The dev cluster is on "vcsa.vmware.devcluster.openshift.com".
vsphere_server = "vcsa.vmware.devcluster.openshift.com"

// User on the vSphere server.
vsphere_user = "jcallen@e2e.local"

// Password of the user on the vSphere server.
vsphere_password = ""

// Name of the vSphere cluster. The dev cluster is "devel".
vsphere_cluster = "devel"

// Name of the vSphere data center. The dev cluster is "dc1".
vsphere_datacenter = "dc1"

// Name of the vSphere data store to use for the VMs. The dev cluster uses "nvme-ds1".
vsphere_datastore = "nvme-ds1"

// Name of the VM template to clone to create VMs for the cluster. The dev cluster has a template named "rhcos-latest".
//vm_template = "rhcos-42.80.20191002.0-vmware"
//vm_template = "rhcos-43.81.202001142154.0-vmware.x86_64"
//vm_template = "rhcos-42.80.20191002.0-vmware"
//vm_template = "rhcos-44.81.202003062006-0-vmware.x86_64"

//vm_template = "rhcos-43.81.202003111353.0-vmware.x86_64"
vm_template = "rhcos-43.81.202003111353.0-vmware.x86_64"

// The machine_cidr where IP addresses will be assigned for cluster nodes.
// Additionally, IPAM will assign IPs based on the network ID.
machine_cidr = "139.178.89.192/26"

// The number of control plane VMs to create. Default is 3.
control_plane_count = 3

// The number of compute VMs to create. Default is 3.
compute_count = 3

// Path to the bootstrap ignition file
bootstrap_ignition_path = "./bootstrap.ign"
bootstrap_ignition      = "./bootstrap.ign"

// Path to the master/control plane ignition file
control_plane_ignition_path = "./master.ign"
control_plane_ignition      = "./master.ign"

// Path to the compute/compute ignition file
compute_ignition_path = "./worker.ign"
compute_ignition      = "./worker.ign"

// Set ipam and ipam_token if you want to use the IPAM server to reserve IP
// addresses for the VMs.

// Address or hostname of the IPAM server from which to reserve IP addresses for the cluster machines.
ipam = "139.178.89.254"

// Token to use to authenticate with the IPAM server.
ipam_token = ""

// Set bootstrap_ip, control_plane_ip, and compute_ip if you want to use static
// IPs reserved someone else, rather than the IPAM server.

// The IP address to assign to the bootstrap VM.
//bootstrap_ip = "10.0.0.10"

// The IP addresses to assign to the control plane VMs. The length of this list
// must match the value of control_plane_count.
//control_plane_ips = ["10.0.0.20", "10.0.0.21", "10.0.0.22"]

// The IP addresses to assign to the compute VMs. The length of this list must
// match the value of compute_count.
//compute_ips = ["10.0.0.30", "10.0.0.31", "10.0.0.32"]
