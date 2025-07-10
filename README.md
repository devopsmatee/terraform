Terraform Configuration for OCI OKE Network Resources
This repository contains a Terraform configuration to set up the network infrastructure and associated resources needed for an Oracle Cloud Infrastructure (OCI) Oracle Kubernetes Engine (OKE) cluster. The setup includes creating virtual cloud networks (VCN), subnets, route tables, NAT gateway, and network security groups to support the OKE cluster.

Resources Created
1. Availability Domains
Fetches the availability domains in your region using the oci_identity_availability_domains data source.

2. Virtual Cloud Network (VCN)
Creates a VCN for the OKE cluster with the CIDR block 10.0.0.0/16.

DNS label set to okevcn.

3. Route Tables
Private Route Table: A route table for the private subnet that does not have direct internet access.

Public Route Table: A route table for the public subnet that provides internet access via an Internet Gateway.

Private Route Table with NAT Gateway: A route table for the private subnet, with outbound internet access routed via a NAT Gateway.

4. Gateways
NAT Gateway: Provides outbound internet access for the private subnet.

Internet Gateway: Provides internet access to the public subnet.

5. Network Security Group (NSG)
Creates a network security group for the OKE cluster.

6. Subnets
Private Subnet: A private subnet for the OKE cluster node pool.

Public Subnet: A public subnet for the load balancer.

7. OKE Cluster
Creates an Oracle Kubernetes Engine (OKE) cluster with the specified Kubernetes version and configures it to use the created VCN and subnets.

8. Node Pool
Creates a node pool for the OKE cluster with the specified configuration such as the node shape, image ID, and number of nodes.

Configures SSH access to the nodes via an SSH public key.

Prerequisites
Before applying this Terraform configuration, ensure you have the following:

OCI Credentials: The OCI API credentials (user OCID, tenancy OCID, and private key) set up for Terraform to authenticate.

Terraform: Ensure Terraform is installed on your machine. You can install it from terraform.io.

SSH Public Key: A valid SSH public key to access the OKE nodes. Specify the path to your SSH public key in the var.ssh_public_key_path.

Variables
compartment_id: The OCID of the compartment where the resources will be created.

oke_cluster_name: The name of the OKE cluster.

kubernetes_version: The desired Kubernetes version for the OKE cluster.

node_count: The number of nodes in the node pool.

ssh_public_key_path: Path to the SSH public key used for accessing the OKE nodes.

Usage
Step 1: Initialize Terraform
Run the following command to initialize Terraform, which will download the necessary providers and set up the workspace.

bash
Copy
terraform init
Step 2: Configure Your Variables
Create a terraform.tfvars file to set your specific values for the required variables:

hcl
Copy
compartment_id        = "your-compartment-id"
oke_cluster_name      = "your-oke-cluster-name"
kubernetes_version    = "1.24.0"  # Example Kubernetes version
node_count            = 3
ssh_public_key_path   = "/path/to/your/ssh_public_key.pub"
Step 3: Apply the Configuration
After configuring your variables, run the following command to apply the Terraform configuration:

bash
Copy
terraform apply
This will create all the required OCI resources for the OKE cluster.

Step 4: Confirm the Changes
Terraform will show you an execution plan before applying changes. Type yes to confirm and proceed with the creation of the resources.

Step 5: Clean Up
To delete the resources created by this configuration, run:

bash
Copy
terraform destroy
Files
main.tf: Contains the main Terraform configuration that defines all the OCI resources.

variables.tf: Defines the required input variables.

terraform.tfvars: (Optional) A file to specify values for the input variables (e.g., compartment ID, cluster name, node count, etc.).

outputs.tf: (Optional) Defines outputs for important resource information (e.g., OKE Cluster OCID).

Notes
Ensure that the CIDR blocks for your subnets do not overlap with each other or with other networks in your environment.

The node pool configuration uses the VM.Standard3.Flex shape with 2 OCPUs and 16 GB of memory per node. You can adjust these settings based on your requirements.

The service_lb_subnet_ids configuration in the OKE cluster ensures that the load balancer uses the public subnet for service access.

For any issues or questions, please feel free to open an issue or pull request in this repository.








Ask ChatGPT
