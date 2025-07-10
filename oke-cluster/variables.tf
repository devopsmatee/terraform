variable "compartment_id" {
  description = "The OCID of the compartment"
  default     = "ocid1.compartment.oc1.."  # Replace with actual Compartment OCID
}

variable "region" {
  description = "The OCI region where resources will be created"
  default     = "me-riyadh-1"
}

variable "oke_cluster_name" {
  description = "Name of the OKE Cluster"
  default     = "secure-oke-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the OKE cluster"
  default     = "v1.30.1"
}

variable "node_shape" {
  description = "Shape of the node (e.g., VM.Standard.E4.Flex)"
  default     = "VM.Standard3.Flex"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  default     = 2
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file for OKE worker nodes."
  type        = string
  default     = "~/.ssh/oci_key.pub" # Default path, adjust if your key is elsewhere
}


