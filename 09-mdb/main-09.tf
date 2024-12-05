terraform {
	required_providers {
		yandex = {
			source = "yandex-cloud/yandex"
		}
	}
}

provider "yandex" {
	#token     = "${YC_TOKEN}" # var.yc_iam_token
  #cloud_id  = var.yc_cloud_id
  #folder_id = var.yc_folder_id
  zone      = "ru-central1-a" #var.region
}

resource "yandex_vpc_network" "network-12-9" {
	name = "network-9-04"
}

resource "yandex_vpc_subnet" "subnet-12-9-a" {
	name = "subnet-12-9-a"
  zone           = "ru-central1-a"
	v4_cidr_blocks = ["10.1.0.0/24"]
	network_id = yandex_vpc_network.network-12-9.id
}

resource "yandex_vpc_subnet" "subnet-12-9-b" {
  name = "subnet-12-9-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-12-9.id
  v4_cidr_blocks = ["10.2.0.0/24"]
}

###

resource "yandex_mdb_postgresql_database" "testdb" {
  cluster_id = yandex_mdb_postgresql_cluster.mdb_pgs_cluster.id
  name       = "testdb"
  owner      = yandex_mdb_postgresql_user.dbuser.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  extension {
    name = "uuid-ossp"
  }
  extension {
    name = "xml2"
  }
}

resource "yandex_mdb_postgresql_user" "dbuser" {
  cluster_id = yandex_mdb_postgresql_cluster.mdb_pgs_cluster.id
  name       = "user"
  password   = "password"
  conn_limit = 50
  settings = {
    default_transaction_isolation = "read committed"
    log_min_duration_statement    = 5000
  }
}

resource "yandex_mdb_postgresql_cluster" "mdb_pgs_cluster" {
  name        = "test_ha"
  description = "test High-Availability (HA) PostgreSQL Cluster with priority and set master"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.network-12-9.id

  host_master_name = "host_name_a"

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_size          = 10
      disk_type_id       = "network-ssd"
    }

  }

  host {
    zone              = "ru-central1-a"
    name              = "host_name_a1"
    assign_public_ip  = true
    subnet_id         = yandex_vpc_subnet.subnet-12-9-a.id
  }
  
  host {
    zone              = "ru-central1-a"
    name              = "host_name_a2"
    assign_public_ip  = true
    subnet_id         = yandex_vpc_subnet.subnet-12-9-a.id
  }

  host {
    zone                    = "ru-central1-b"
    name                    = "host_name_b"
    replication_source_name = "host_name_a1"
    assign_public_ip        = true
    subnet_id               = yandex_vpc_subnet.subnet-12-9-b.id
  }
}

output "instance_external_ip" {
  value = "${resource.yandex_mdb_postgresql_cluster.mdb_pgs_cluster.host.*.fqdn}"
}