
#output "internal_ip_address_host_name_a" {
#  value = yandex_mdb_postgresql_cluster.mdb_pgs_cluster.host[0]
#}

#output "external_ip_address_host_name_b" {
#  value = yandex_mdb_postgresql_cluster.mdb_pgs_cluster.host[1].*
#}

output "vm-ip_addresses" {
  value = tomap ({
    for name, vm in yandex_mdb_postgresql_cluster.mdb_pgs_cluster.host : name => vm.fqdn
  })
}