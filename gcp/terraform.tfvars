project = "active-defender-350709"

vpc = {
  "master" = {
    name    = "master"
    region  = "europe-west1"
    zone    = "europe-west1-b"
    subnet  = "10.1.0.0/24"
    machine = "custom-4-8192"
    image   = "centos-cloud/centos-7-v20220519"
    size    = "20"
    ip      = ["10.1.0.10"]
  },
  "worker" = {
    name    = "worker"
    region  = "europe-central2"
    zone    = "europe-central2-a"
    subnet  = "10.2.0.0/24"
    machine = "custom-2-8192"
    image   = "centos-cloud/centos-7-v20220519"
    size    = "20"
    ip      = ["10.2.0.11","10.2.0.12"]
  },
  "control" = {
    name    = "control"
    region  = "europe-north1"
    zone    = "europe-north1-c"
    subnet  = "10.3.0.0/24"
    machine = "custom-2-4096"
    image   = "centos-cloud/centos-7-v20220519"
    size    = "20"
    ip      = ["10.3.0.10"]
  }
}