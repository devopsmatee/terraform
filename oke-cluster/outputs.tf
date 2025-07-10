output "cluster_id" {
  value = oci_containerengine_cluster.oke_cluster.id
}

output "node_pool_id" {
  value = oci_containerengine_node_pool.oke_node_pool.id
}


