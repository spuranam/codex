#
# Amazonia - Terraform Configuration for
# GCP BOSH + Cloud Foundry
#

variable "google_credentials"  {} # Your Google Credentials (required)
variable "google_project"      {} # Your Google Region      (required)
variable "google_network_name" {} # Name of the Network     (required)
variable "google_region"       {} # Google Region           (required)
variable "google_zone_1"       {} # Google Zone 1           (required)
variable "google_zone_2"       {} # Google Zone 2           (required)
variable "google_zone_3"       {} # Google Zone 3           (required)

variable "network"        { default = "10.4" }      # First 2 octets of your /16

###############################################################

provider "google" {
  credentials = "${file("${var.google_credentials}")}"
  project     = "${var.google_project}"
  region      = "${var.google_region}"
}



##    ## ######## ######## ##      ##  #######  ########  ##    ##  ######
###   ## ##          ##    ##  ##  ## ##     ## ##     ## ##   ##  ##    ##
####  ## ##          ##    ##  ##  ## ##     ## ##     ## ##  ##   ##
## ## ## ######      ##    ##  ##  ## ##     ## ########  #####     ######
##  #### ##          ##    ##  ##  ## ##     ## ##   ##   ##  ##         ##
##   ### ##          ##    ##  ##  ## ##     ## ##    ##  ##   ##  ##    ##
##    ## ########    ##     ###  ###   #######  ##     ## ##    ##  ######

###########################################################################
# Default Network
#

resource "google_compute_network" "default" {
  name = "${var.google_network_name}"
}



 ######  ##     ## ########  ##    ## ######## ########  ######
##    ## ##     ## ##     ## ###   ## ##          ##    ##    ##
##       ##     ## ##     ## ####  ## ##          ##    ##
 ######  ##     ## ########  ## ## ## ######      ##     ######
      ## ##     ## ##     ## ##  #### ##          ##          ##
##    ## ##     ## ##     ## ##   ### ##          ##    ##    ##
 ######   #######  ########  ##    ## ########    ##     ######

###############################################################
# DMZ - De-militarized Zone
#
resource "google_compute_subnetwork" "dmz" {
  name          = "${var.google_network_name}-dmz"
  network       = "${google_compute_network.default.self_link}"
  ip_cidr_range = "${var.network}.0.0/24"

}
output "google.network.dmz.subnet" {
  value = "${google_compute_subnetwork.dmz.name}"
}

###############################################################
# GLOBAL - Global Infrastructure
#
# This includes the following:
#   - proto-BOSH
#   - SHIELD
#   - Vault (for deployment credentials)
#   - Concourse (for deployment automation)
#   - Bolo
#
resource "google_compute_subnetwork" "global-infra-0" {
  name          = "${var.google_network_name}-global-infra-0"
  network       = "${google_compute_network.default.self_link}"
  ip_cidr_range = "${var.network}.1.0/24"

}
output "google.network.global-infra-0.subnet" {
  value = "${google_compute_subnetwork.global-infra-0.name}"
}
resource "google_compute_subnetwork" "global-infra-1" {
  name          = "${var.google_network_name}-global-infra-1"
  ip_cidr_range = "${var.network}.2.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.global-infra-1.subnet" {
  value = "${google_compute_subnetwork.global-infra-1.name}"
}
resource "google_compute_subnetwork" "global-infra-2" {
  name          = "${var.google_network_name}-global-infra-2"
  ip_cidr_range = "${var.network}.3.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.global-infra-2.subnet" {
  value = "${google_compute_subnetwork.global-infra-2.name}"
}

###############################################################
# OpenVPN - OpenVPN
#
resource "google_compute_subnetwork" "global-openvpn-0" {
  name          = "${var.google_network_name}-global-openvpn-0"
  ip_cidr_range = "${var.network}.4.0/25"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.global-openvpn-0.subnet" {
  value = "${google_compute_subnetwork.global-openvpn-0.name}"
}
resource "google_compute_subnetwork" "global-openvpn-1" {
  name          = "${var.google_network_name}-global-openvpn-1"
  ip_cidr_range = "${var.network}.4.128/25"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.global-openvpn-1.subnet" {
  value = "${google_compute_subnetwork.global-openvpn-1.name}"
}

###############################################################
# DEV-INFRA - Development Site Infrastructure
#
#  Primarily used for BOSH directors, deployed by proto-BOSH
#
#  Also reserved for situations where you prefer to have
#  dedicated, per-site infrastructure (SHIELD, Bolo, etc.)
#
#  Three zone-isolated networks are provided for HA and
#  fault-tolerance in deployments that support / require it.
#
resource "google_compute_subnetwork" "dev-infra-0" {
  name          = "${var.google_network_name}-dev-infra-0"
  ip_cidr_range = "${var.network}.16.0/24"
  network       = "${google_compute_network.default.self_link}"

}
output "google.network.dev-infra-0.subnet" {
  value = "${google_compute_subnetwork.dev-infra-0.name}"
}
resource "google_compute_subnetwork" "dev-infra-1" {
  name          = "${var.google_network_name}-dev-infra-1"
  ip_cidr_range = "${var.network}.17.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-infra-1.subnet" {
  value = "${google_compute_subnetwork.dev-infra-1.name}"
}
resource "google_compute_subnetwork" "dev-infra-2" {
  name          = "${var.google_network_name}-dev-infra-2"
  ip_cidr_range = "${var.network}.18.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-infra-2.subnet" {
  value = "${google_compute_subnetwork.dev-infra-2.name}"
}

###############################################################
# DEV-CF-EDGE - Cloud Foundry Routers
#
#  These subnets are separate from the rest of Cloud Foundry
#  to ensure that we can properly ACL the public-facing HTTP
#  routers independent of the private core / services.
#
resource "google_compute_subnetwork" "dev-edge-0" {
  name          = "${var.google_network_name}-dev-edge-0"
  ip_cidr_range = "${var.network}.19.0/25"
  network       = "${google_compute_network.default.self_link}"

}
output "google.network.dev-edge-0.subnet" {
  value = "${google_compute_subnetwork.dev-edge-0.name}"
}
resource "google_compute_subnetwork" "dev-edge-1" {
  name          = "${var.google_network_name}-dev-edge-1"
  ip_cidr_range = "${var.network}.19.128/25"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-edge-1.subnet" {
  value = "${google_compute_subnetwork.dev-edge-1.name}"
}

###############################################################
# DEV-CF-CORE - Cloud Foundry Core
#
#  These subnets contain the private core components of Cloud
#  Foundry.  They are separate for reasons of isolation via
#  Network ACLs.
#
resource "google_compute_subnetwork" "dev-cf-core-0" {
  name          = "${var.google_network_name}-dev-core-0"
  ip_cidr_range = "${var.network}.20.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-cf-core-0.subnet" {
  value = "${google_compute_subnetwork.dev-cf-core-0.name}"
}
resource "google_compute_subnetwork" "dev-cf-core-1" {
  name          = "${var.google_network_name}-dev-core-1"
  ip_cidr_range = "${var.network}.21.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-cf-core-1.subnet" {
  value = "${google_compute_subnetwork.dev-cf-core-1.name}"
}
resource "google_compute_subnetwork" "dev-cf-core-2" {
  name          = "${var.google_network_name}-dev-core-2"
  ip_cidr_range = "${var.network}.22.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-cf-core-2.subnet" {
  value = "${google_compute_subnetwork.dev-cf-core-2.name}"
}

###############################################################
# DEV-CF-RUNTIME - Cloud Foundry Runtime
#
#  These subnets house the Cloud Foundry application runtime
#  (either DEA-next or Diego).
#
resource "google_compute_subnetwork" "dev-cf-runtime-0" {
  name          = "${var.google_network_name}-dev-cf-runtime-0"
  ip_cidr_range = "${var.network}.23.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-cf-runtime-0.subnet" {
  value = "${google_compute_subnetwork.dev-cf-runtime-0.name}"
}
resource "google_compute_subnetwork" "dev-cf-runtime-1" {
  name          = "${var.google_network_name}-dev-cf-runtime-1"
  ip_cidr_range = "${var.network}.24.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-cf-runtime-1.subnet" {
  value = "${google_compute_subnetwork.dev-cf-runtime-1.name}"
}
resource "google_compute_subnetwork" "dev-cf-runtime-2" {
  name          = "${var.google_network_name}-dev-cf-runtime-2"
  ip_cidr_range = "${var.network}.25.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-cf-runtime-2.subnet" {
  value = "${google_compute_subnetwork.dev-cf-runtime-2.name}"
}

###############################################################
# DEV-CF-SVC - Cloud Foundry Services
#
#  These subnets house Service Broker deployments for
#  Cloud Foundry Marketplace services.
#
resource "google_compute_subnetwork" "dev-cf-svc-0" {
  name          = "${var.google_network_name}-dev-cf-svc-0"
  ip_cidr_range = "${var.network}.26.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-cf-svc-0.subnet" {
  value = "${google_compute_subnetwork.dev-cf-svc-0.name}"
}
resource "google_compute_subnetwork" "dev-cf-svc-1" {
  name          = "${var.google_network_name}-dev-cf-svc-1"
  ip_cidr_range = "${var.network}.27.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-cf-svc-1.subnet" {
  value = "${google_compute_subnetwork.dev-cf-svc-1.name}"
}
resource "google_compute_subnetwork" "dev-cf-svc-2" {
  name          = "${var.google_network_name}-dev-cf-svc-2"
  ip_cidr_range = "${var.network}.28.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.dev-cf-svc-2.subnet" {
  value = "${google_compute_subnetwork.dev-cf-svc-2.name}"
}

###############################################################
# STAGING-INFRA - Staging Site Infrastructure
#
#  Primarily used for BOSH directors, deployed by proto-BOSH
#
#  Also reserved for situations where you prefer to have
#  dedicated, per-site infrastructure (SHIELD, Bolo, etc.)
#
#  Three zone-isolated networks are provided for HA and
#  fault-tolerance in deployments that support / require it.
#
resource "google_compute_subnetwork" "staging-infra-0" {
  name          = "${var.google_network_name}-staging-infra-0"
  ip_cidr_range = "${var.network}.32.0/24"
  network       = "${google_compute_network.default.self_link}"

}
output "google.network.staging-infra-0.subnet" {
  value = "${google_compute_subnetwork.staging-infra-0.name}"
}
resource "google_compute_subnetwork" "staging-infra-1" {
  name          = "${var.google_network_name}-staging-infra-1"
  ip_cidr_range = "${var.network}.33.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-infra-1.subnet" {
  value = "${google_compute_subnetwork.staging-infra-1.name}"
}
resource "google_compute_subnetwork" "staging-infra-2" {
  name          = "${var.google_network_name}-staging-infra-2"
  ip_cidr_range = "${var.network}.34.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-infra-2.subnet" {
  value = "${google_compute_subnetwork.staging-infra-2.name}"
}

###############################################################
# STAGING-CF-EDGE - Cloud Foundry Routers
#
#  These subnets are separate from the rest of Cloud Foundry
#  to ensure that we can properly ACL the public-facing HTTP
#  routers independent of the private core / services.
#
resource "google_compute_subnetwork" "staging-edge-0" {
  name          = "${var.google_network_name}-staging-edge-0"
  ip_cidr_range = "${var.network}.35.0/25"
  network       = "${google_compute_network.default.self_link}"

}
output "google.network.staging-edge-0.subnet" {
  value = "${google_compute_subnetwork.staging-edge-0.name}"
}
resource "google_compute_subnetwork" "staging-edge-1" {
  name          = "${var.google_network_name}-staging-edge-1"
  ip_cidr_range = "${var.network}.35.128/25"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-edge-1.subnet" {
  value = "${google_compute_subnetwork.staging-edge-1.name}"
}

###############################################################
# STAGING-CF-CORE - Cloud Foundry Core
#
#  These subnets contain the private core components of Cloud
#  Foundry.  They are separate for reasons of isolation via
#  Network ACLs.
#
resource "google_compute_subnetwork" "staging-cf-core-0" {
  name          = "${var.google_network_name}-staging-core-0"
  ip_cidr_range = "${var.network}.36.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-cf-core-0.subnet" {
  value = "${google_compute_subnetwork.staging-cf-core-0.name}"
}
resource "google_compute_subnetwork" "staging-cf-core-1" {
  name          = "${var.google_network_name}-staging-core-1"
  ip_cidr_range = "${var.network}.37.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-cf-core-1.subnet" {
  value = "${google_compute_subnetwork.staging-cf-core-1.name}"
}
resource "google_compute_subnetwork" "staging-cf-core-2" {
  name          = "${var.google_network_name}-staging-core-2"
  ip_cidr_range = "${var.network}.38.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-cf-core-2.subnet" {
  value = "${google_compute_subnetwork.staging-cf-core-2.name}"
}

###############################################################
# STAGING-CF-RUNTIME - Cloud Foundry Runtime
#
#  These subnets house the Cloud Foundry application runtime
#  (either DEA-next or Diego).
#
resource "google_compute_subnetwork" "staging-cf-runtime-0" {
  name          = "${var.google_network_name}-staging-cf-runtime-0"
  ip_cidr_range = "${var.network}.39.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-cf-runtime-0.subnet" {
  value = "${google_compute_subnetwork.staging-cf-runtime-0.name}"
}
resource "google_compute_subnetwork" "staging-cf-runtime-1" {
  name          = "${var.google_network_name}-staging-cf-runtime-1"
  ip_cidr_range = "${var.network}.40.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-cf-runtime-1.subnet" {
  value = "${google_compute_subnetwork.staging-cf-runtime-1.name}"
}
resource "google_compute_subnetwork" "staging-cf-runtime-2" {
  name          = "${var.google_network_name}-staging-cf-runtime-2"
  ip_cidr_range = "${var.network}.41.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-cf-runtime-2.subnet" {
  value = "${google_compute_subnetwork.staging-cf-runtime-2.name}"
}

###############################################################
# STAGING-CF-SVC - Cloud Foundry Services
#
#  These subnets house Service Broker deployments for
#  Cloud Foundry Marketplace services.
#
resource "google_compute_subnetwork" "staging-cf-svc-0" {
  name          = "${var.google_network_name}-staging-cf-svc-0"
  ip_cidr_range = "${var.network}.42.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-cf-svc-0.subnet" {
  value = "${google_compute_subnetwork.staging-cf-svc-0.name}"
}
resource "google_compute_subnetwork" "staging-cf-svc-1" {
  name          = "${var.google_network_name}-staging-cf-svc-1"
  ip_cidr_range = "${var.network}.43.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-cf-svc-1.subnet" {
  value = "${google_compute_subnetwork.staging-cf-svc-1.name}"
}
resource "google_compute_subnetwork" "staging-cf-svc-2" {
  name          = "${var.google_network_name}-staging-cf-svc-2"
  ip_cidr_range = "${var.network}.44.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.staging-cf-svc-2.subnet" {
  value = "${google_compute_subnetwork.staging-cf-svc-2.name}"
}

###############################################################
# PROD-INFRA - Production Site Infrastructure
#
#  Primarily used for BOSH directors, deployed by proto-BOSH
#
#  Also reserved for situations where you prefer to have
#  dedicated, per-site infrastructure (SHIELD, Bolo, etc.)
#
#  Three zone-isolated networks are provided for HA and
#  fault-tolerance in deployments that support / require it.
#
resource "google_compute_subnetwork" "prod-infra-0" {
  name          = "${var.google_network_name}-prod-infra-0"
  ip_cidr_range = "${var.network}.48.0/24"
  network       = "${google_compute_network.default.self_link}"

}
output "google.network.prod-infra-0.subnet" {
  value = "${google_compute_subnetwork.prod-infra-0.name}"
}
resource "google_compute_subnetwork" "prod-infra-1" {
  name          = "${var.google_network_name}-prod-infra-1"
  ip_cidr_range = "${var.network}.49.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-infra-1.subnet" {
  value = "${google_compute_subnetwork.prod-infra-1.name}"
}
resource "google_compute_subnetwork" "prod-infra-2" {
  name          = "${var.google_network_name}-prod-infra-2"
  ip_cidr_range = "${var.network}.50.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-infra-2.subnet" {
  value = "${google_compute_subnetwork.prod-infra-2.name}"
}

###############################################################
# PROD-CF-EDGE - Cloud Foundry Routers
#
#  These subnets are separate from the rest of Cloud Foundry
#  to ensure that we can properly ACL the public-facing HTTP
#  routers independent of the private core / services.
#
resource "google_compute_subnetwork" "prod-edge-0" {
  name          = "${var.google_network_name}-prod-edge-0"
  ip_cidr_range = "${var.network}.51.0/25"
  network       = "${google_compute_network.default.self_link}"

}
output "google.network.prod-edge-0.subnet" {
  value = "${google_compute_subnetwork.prod-edge-0.name}"
}
resource "google_compute_subnetwork" "prod-edge-1" {
  name          = "${var.google_network_name}-prod-edge-1"
  ip_cidr_range = "${var.network}.51.128/25"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-edge-1.subnet" {
  value = "${google_compute_subnetwork.prod-edge-1.name}"
}

###############################################################
# PROD-CF-CORE - Cloud Foundry Core
#
#  These subnets contain the private core components of Cloud
#  Foundry.  They are separate for reasons of isolation via
#  Network ACLs.
#
resource "google_compute_subnetwork" "prod-cf-core-0" {
  name          = "${var.google_network_name}-prod-core-0"
  ip_cidr_range = "${var.network}.52.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-cf-core-0.subnet" {
  value = "${google_compute_subnetwork.prod-cf-core-0.name}"
}
resource "google_compute_subnetwork" "prod-cf-core-1" {
  name          = "${var.google_network_name}-prod-core-1"
  ip_cidr_range = "${var.network}.53.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-cf-core-1.subnet" {
  value = "${google_compute_subnetwork.prod-cf-core-1.name}"
}
resource "google_compute_subnetwork" "prod-cf-core-2" {
  name          = "${var.google_network_name}-prod-core-2"
  ip_cidr_range = "${var.network}.54.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-cf-core-2.subnet" {
  value = "${google_compute_subnetwork.prod-cf-core-2.name}"
}

###############################################################
# PROD-CF-RUNTIME - Cloud Foundry Runtime
#
#  These subnets house the Cloud Foundry application runtime
#  (either DEA-next or Diego).
#
resource "google_compute_subnetwork" "prod-cf-runtime-0" {
  name          = "${var.google_network_name}-prod-cf-runtime-0"
  ip_cidr_range = "${var.network}.55.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-cf-runtime-0.subnet" {
  value = "${google_compute_subnetwork.prod-cf-runtime-0.name}"
}
resource "google_compute_subnetwork" "prod-cf-runtime-1" {
  name          = "${var.google_network_name}-prod-cf-runtime-1"
  ip_cidr_range = "${var.network}.56.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-cf-runtime-1.subnet" {
  value = "${google_compute_subnetwork.prod-cf-runtime-1.name}"
}
resource "google_compute_subnetwork" "prod-cf-runtime-2" {
  name          = "${var.google_network_name}-prod-cf-runtime-2"
  ip_cidr_range = "${var.network}.57.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-cf-runtime-2.subnet" {
  value = "${google_compute_subnetwork.prod-cf-runtime-2.name}"
}

###############################################################
# PROD-CF-SVC - Cloud Foundry Services
#
#  These subnets house Service Broker deployments for
#  Cloud Foundry Marketplace services.
#
resource "google_compute_subnetwork" "prod-cf-svc-0" {
  name          = "${var.google_network_name}-prod-cf-svc-0"
  ip_cidr_range = "${var.network}.58.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-cf-svc-0.subnet" {
  value = "${google_compute_subnetwork.prod-cf-svc-0.name}"
}
resource "google_compute_subnetwork" "prod-cf-svc-1" {
  name          = "${var.google_network_name}-prod-cf-svc-1"
  ip_cidr_range = "${var.network}.59.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-cf-svc-1.subnet" {
  value = "${google_compute_subnetwork.prod-cf-svc-1.name}"
}
resource "google_compute_subnetwork" "prod-cf-svc-2" {
  name          = "${var.google_network_name}-prod-cf-svc-2"
  ip_cidr_range = "${var.network}.60.0/24"
  network       = "${google_compute_network.default.self_link}"
}
output "google.network.prod-cf-svc-2.subnet" {
  value = "${google_compute_subnetwork.prod-cf-svc-2.name}"
}



 ######  ########  ######          ######   ########   #######  ##     ## ########   ######
##    ## ##       ##    ##        ##    ##  ##     ## ##     ## ##     ## ##     ## ##    ##
##       ##       ##              ##        ##     ## ##     ## ##     ## ##     ## ##
 ######  ######   ##              ##   #### ########  ##     ## ##     ## ########   ######
      ## ##       ##              ##    ##  ##   ##   ##     ## ##     ## ##              ##
##    ## ##       ##    ## ###    ##    ##  ##    ##  ##     ## ##     ## ##        ##    ##
 ######  ########  ######  ###     ######   ##     ##  #######   #######  ##         ######

resource "google_compute_firewall" "dmz" {
  name    = "dmz"
  network = "${google_compute_network.default.name}"

  # Allow ICMP traffic
  allow {
    protocol = "icmp"
  }

  # Allow SSH traffic into the Bastion box
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["dmz"]
}

resource "google_compute_firewall" "internal" {
  name    = "internal"
  network = "${google_compute_network.default.name}"

  # Allow ICMP traffic
  allow {
    protocol = "icmp"
  }

  # Allow TCP traffic
  allow {
    protocol = "tcp"
  }

  # Allow UDP traffic
  allow {
    protocol = "udp"
  }

  source_tags = ["internal"]
  target_tags = ["internal"]
}



########     ###     ######  ######## ####  #######  ##    ##
##     ##   ## ##   ##    ##    ##     ##  ##     ## ###   ##
##     ##  ##   ##  ##          ##     ##  ##     ## ####  ##
########  ##     ##  ######     ##     ##  ##     ## ## ## ##
##     ## #########       ##    ##     ##  ##     ## ##  ####
##     ## ##     ## ##    ##    ##     ##  ##     ## ##   ###
########  ##     ##  ######     ##    ####  #######  ##    ##

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "n1-standard-1"
  zone         = "${var.google_region}-${var.google_zone_1}"

  disk {
    image = "ubuntu-os-cloud/ubuntu-1604-lts"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.dmz.name}"
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  tags = ["dmz", "internal"]

  metadata_startup_script = <<EOT
#!/bin/bash
sudo curl -o /usr/local/bin/jumpbox https://raw.githubusercontent.com/starkandwayne/jumpbox/master/bin/jumpbox
sudo chmod 0755 /usr/local/bin/jumpbox
sudo jumpbox system
EOT
}
output "box.bastion.public_ip" {
  value = "${google_compute_instance.bastion.network_interface.0.access_config.0.assigned_nat_ip}"
}
