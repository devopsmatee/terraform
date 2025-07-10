# Main Terraform configuration file for OCI OKE network resources.

# Fetch Availability Domains for your region
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Create Virtual Cloud Network (VCN) for OKE Cluster
resource "oci_core_virtual_network" "oke_vcn" {
  compartment_id = var.compartment_id
  display_name   = "${var.oke_cluster_name}-vcn"
  cidr_block     = "10.0.0.0/16" # Adjust the VCN CIDR block as needed
  dns_label      = "okevcn"
}

# Create Route Table for Private Subnet (No direct internet access)
resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-private-route-table"
}

# Create NAT Gateway for Outbound Internet Access (for Private Subnet)
resource "oci_core_nat_gateway" "oke_nat_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-nat-gateway"
}

# Create Route Table for Private Subnet with NAT Gateway (for outbound access)
resource "oci_core_route_table" "private_route_table_with_nat" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-private-route-table-with-nat"

  route_rules {
    destination       = "0.0.0.0/0" # Route all outbound traffic
    network_entity_id = oci_core_nat_gateway.oke_nat_gateway.id # To the NAT Gateway
  }
}

# Create Internet Gateway for Public Subnet (Internet access)
resource "oci_core_internet_gateway" "oke_internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-internet-gateway"
  enabled        = true
}

# Create Route Table for Public Subnet (Internet access via Internet Gateway)
resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-public-route-table"

  route_rules {
    destination       = "0.0.0.0/0" # Route all outbound traffic
    network_entity_id = oci_core_internet_gateway.oke_internet_gateway.id # To the Internet Gateway
  }
}

# Create Network Security Group (NSG) for OKE
resource "oci_core_network_security_group" "oke_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-nsg"
}

# Create Subnet for OKE Cluster Node Pool (Private Subnet)
resource "oci_core_subnet" "oke_subnet" {
  depends_on = [
    oci_core_virtual_network.oke_vcn,
    oci_core_route_table.private_route_table_with_nat,
    oci_core_nat_gateway.oke_nat_gateway
  ]

  compartment_id      = var.compartment_id
  vcn_id              = oci_core_virtual_network.oke_vcn.id
  display_name        = "${var.oke_cluster_name}-private-subnet"
  cidr_block          = "10.0.1.0/24"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  route_table_id      = oci_core_route_table.private_route_table_with_nat.id
}

# Create Public Subnet for Load Balancer
resource "oci_core_subnet" "oke_public_subnet" {
  depends_on = [
    oci_core_virtual_network.oke_vcn,
    oci_core_internet_gateway.oke_internet_gateway,
    oci_core_route_table.public_route_table
  ]

  compartment_id      = var.compartment_id
  vcn_id              = oci_core_virtual_network.oke_vcn.id
  display_name        = "${var.oke_cluster_name}-public-subnet"
  cidr_block          = "10.0.2.0/24"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  route_table_id      = oci_core_route_table.public_route_table.id
}

# OKE Cluster Configuration
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_id
  name               = var.oke_cluster_name
  vcn_id             = oci_core_virtual_network.oke_vcn.id
  kubernetes_version = var.kubernetes_version

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    admission_controller_options {
      is_pod_security_policy_enabled = false
    }

    # Add the service_lb_subnet_ids option here
    service_lb_subnet_ids = [oci_core_subnet.oke_public_subnet.id]
  }
}

# Node Pool Configuration for OKE Cluster
resource "oci_containerengine_node_pool" "oke_node_pool" {
  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  name               = "${var.oke_cluster_name}-np"
  kubernetes_version = var.kubernetes_version
  node_shape         = "VM.Standard3.Flex"

  node_source_details {
    source_type = "Image"
    image_id    = "ocid1.image.oc1.me-riyadh-1.aaaaaaaahtpcoq5n7evsa3zlbz6m762dkwafijifejxgxdx7l6aj6pxtd7ga"
  }

  node_shape_config {
    ocpus         = 2
    memory_in_gbs = 16
  }

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.oke_subnet.id
    }

    size = var.node_count
  }

  node_metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
}

