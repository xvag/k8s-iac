terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = var.gcp_creds
  project = var.project
}

resource "google_compute_network" "master-vpc" {
  name = "master-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "master-subnet" {
  name          = "master-subnet"
  region        = var.master.region
  ip_cidr_range = var.master.subnet
  network       = google_compute_network.master-vpc.id
}

resource "google_compute_network" "worker-vpc" {
  name = "worker-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "worker-subnet" {
  name          = "worker-subnet"
  region        = var.worker.region
  ip_cidr_range = var.worker.subnet
  network       = google_compute_network.worker-vpc.id
}

resource "google_compute_network" "control-vpc" {
  name = "control-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "control-subnet" {
  name          = "control-subnet"
  region        = var.control.region
  ip_cidr_range = var.control.subnet
  network       = google_compute_network.control-vpc.id
}

resource "google_compute_network_peering" "master-worker" {
  name         = "master-worker"
  network      = google_compute_network.master-vpc.self_link
  peer_network = google_compute_network.worker-vpc.self_link
}

resource "google_compute_network_peering" "worker-master" {
  name         = "worker-master"
  network      = google_compute_network.worker-vpc.self_link
  peer_network = google_compute_network.master-vpc.self_link
}

resource "google_compute_firewall" "master-fw" {
  name    = "master-fw"
  network = google_compute_network.master-vpc.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_compute_firewall" "worker-fw" {
  name    = "worker-fw"
  network = google_compute_network.worker-vpc.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_compute_firewall" "control-fw" {
  name    = "control-fw"
  network = google_compute_network.control-vpc.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    "0.0.0.0/0"
  ]
}


resource "google_compute_instance" "master-vm" {
  name         = "master-vm"
  machine_type = var.master.machine
  zone         = var.master.zone

  boot_disk {
    initialize_params {
      image = var.master.image
    }
  }

  network_interface {
    network = google_compute_network.master-vpc.name
    subnetwork = google_compute_subnetwork.master-subnet.name
    access_config {
    }
  }
}

resource "google_compute_instance" "worker-vm" {
  count = 2

  name         = "worker-vm-${count.index}"
  machine_type = var.worker.machine
  zone         = var.worker.zone

  boot_disk {
    initialize_params {
      image = var.worker.image
    }
  }

  network_interface {
    network = google_compute_network.worker-vpc.name
    subnetwork = google_compute_subnetwork.worker-subnet.name
    access_config {
    }
  }
}

resource "google_compute_instance" "control-vm" {
  name         = "control-vm"
  machine_type = var.control.machine
  zone         = var.control.zone

  boot_disk {
    initialize_params {
      image = var.control.image
    }
  }

  network_interface {
    network = google_compute_network.control-vpc.name
    subnetwork = google_compute_subnetwork.control-subnet.name
    access_config {
    }
  }
}