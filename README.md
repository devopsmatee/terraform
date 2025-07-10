# Terraform Configuration for OCI OKE Network Resources

This repository contains a **Terraform configuration** to set up the network infrastructure and associated resources needed for an **Oracle Cloud Infrastructure (OCI)** **Oracle Kubernetes Engine (OKE)** cluster. The setup includes creating virtual cloud networks (VCN), subnets, route tables, NAT gateway, and network security groups to support the OKE cluster.

## Resources Created

### 1. **Availability Domains**
- Fetches the availability domains in your region using the `oci_identity_availability_domains` data source.

### 2. **Virtual Cloud Network (VCN)**
- Creates a **VCN** for the OKE cluster with the CIDR block `10.0.0.0/16`.
- DNS label set to `okevcn`.

### 3. **Route Tables**
- **Private Route Table**: A route table for the private subnet that does not have direct internet access.
- **Public Route Table**: A route table for the public subnet that provides internet access via an **Internet Gateway**.
- **Private Route Table with NAT Gateway**: A route table for the private subnet, with outbound internet access routed via a **NAT Gateway**.

### 4. **Gateways**
- **NAT Gateway**: Provides outbound internet access for the private subnet.
- **Internet Gateway**: Provides internet access to the public subnet.

### 5. **Network Security Group (NSG)**
- Creates a **Network Security Group (NSG)** for the OKE cluster.

### 6. **Subnets**
- **Private Subnet**: A private subnet for the OKE cluster node pool.
- **Public Subnet**: A public subnet for the load balancer.

### 7. **OKE Cluster**
- Creates an **Oracle Kubernetes Engine (OKE) cluster** with the specified Kubernetes version and configures it to use the created VCN and subnets.

### 8. **Node Pool**
- Creates a **Node Pool** for the OKE cluster with the specified configuration such as the node shape, image ID, and number of nodes.
- Configures SSH access to the nodes via an SSH public key.

## Prerequisites

Before applying this Terraform configuration, ensure you have the following:

1. **OCI Credentials**: The OCI API credentials (user OCID, tenancy OCID, and private key) set up for Terraform to authenticate.
2. **Terraform**: Ensure **Terraform** is installed on your machine. You can install it from [terraform.io](https://www.terraform.io/).
3. **SSH Public Key**: A valid **SSH public key** to access the OKE nodes. Specify the path to your SSH public key in the `var.ssh_public_key_path`.

## Variables

The following input variables are required:

| Variable Name              | Description                                                            | Example                      |
|----------------------------|------------------------------------------------------------------------|------------------------------|
| `compartment_id`            | The OCID of the compartment where the resources will be created.       | `"ocid1.compartment.oc1..xxxx"` |
| `oke_cluster_name`          | The name of the OKE cluster.                                           | `"my-oke-cluster"`            |
| `kubernetes_version`        | The desired Kubernetes version for the OKE cluster.                    | `"1.24.0"`                   |
| `node_count`                | The number of nodes in the node pool.                                  | `3`                          |
| `ssh_public_key_path`       | Path to the SSH public key used for accessing the OKE nodes.           | `"/path/to/your/ssh_public_key.pub"` |

## Usage

### Step 1: Initialize Terraform

Run the following command to initialize Terraform, which will download the necessary providers and set up the workspace.

```bash
terraform init
