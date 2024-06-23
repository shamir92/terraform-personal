terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.38.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}


provider "digitalocean" {
  token = var.digital_ocean_token
}

provider "local" {
  # Configuration options
}

resource "digitalocean_tag" "terraform" {
  name = "terraform"
}

data "digitalocean_regions" "all" {
  filter {
    key    = "available"
    values = ["true"]
  }
}

# output "region_list" {
#   value = data.digitalocean_regions.all.regions
# }

resource "local_file" "region_list_file" {
  content  = jsonencode(data.digitalocean_regions.all.regions)
  filename = "${path.module}/region_list.json"
}

resource "digitalocean_vpc" "test-terraform" {
  name     = "example-project-network"
  region   = "sgp1"
  ip_range = "10.0.0.0/16"
}

resource "digitalocean_droplet" "web" {
  image  = "ubuntu-20-04-x64"
  name   = "web"
  region = "sgp1"
  size   = "s-1vcpu-1gb"
  vpc_uuid = digitalocean_vpc.test-terraform.id
  tags = [ digitalocean_tag.terraform.id ]
}


# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "web-1" {
  image  = "ubuntu-20-04-x64"
  name   = "web-1"
  region = "sgp1"
  size   = "s-1vcpu-1gb"
  vpc_uuid = digitalocean_vpc.test-terraform.id
  tags = [ digitalocean_tag.terraform.id ]
}

resource "digitalocean_droplet" "web-2" {
  image  = "ubuntu-20-04-x64"
  name   = "web-2"
  region = "sgp1"
  size   = "s-1vcpu-1gb"
  vpc_uuid = digitalocean_vpc.test-terraform.id
  tags = [ digitalocean_tag.terraform.id ]
}

# resource "digitalocean_droplet" "web-3" {
#   image  = "ubuntu-20-04-x64"
#   name   = "web-3"
#   region = "sgp1"
#   size   = "s-1vcpu-1gb"
#   vpc_uuid = digitalocean_vpc.test-terraform.id
#   tags = [ digitalocean_tag.terraform.id ]  
# }

resource "digitalocean_firewall" "web" {
  name = "only-22-80-and-443"

  droplet_ids = [digitalocean_droplet.web.id, digitalocean_droplet.web-1.id, digitalocean_droplet.web-2.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["192.168.1.0/24", "2002:1:2::/48"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Create a new check for the target endpoint in a specific region
resource "digitalocean_uptime_check" "shamirhusein_my_id" {
  name    = "example-europe-check"
  target  = "https://shamirhusein.my.id"
  regions = ["eu_west","us_east","us_west","se_asia"]
}

# Create a latency alert for the uptime check
resource "digitalocean_uptime_alert" "alert_shamirhusein_my_id" {
  name       = "latency-alert"
  check_id   = digitalocean_uptime_check.shamirhusein_my_id.id
  type       = "latency"
  threshold  = 300
  comparison = "greater_than"
  period     = "2m"
  notifications {
    email = ["shamirhusein@gmail.com"]
    # slack {
    #   channel = "Production Alerts"
    #   url     = "https://hooks.slack.com/services/T1234567/AAAAAAAA/ZZZZZZ"
    # }
  }
}

# Create a latency alert for the uptime check
resource "digitalocean_uptime_alert" "down_shamirhusein_my_id" {
  name       = "down-alert"
  check_id   = digitalocean_uptime_check.shamirhusein_my_id.id
  type       = "down"
  threshold  = 300
  comparison = "greater_than"
  period     = "2m"
  notifications {
    email = ["shamirhusein@gmail.com"]
    # slack {
    #   channel = "Production Alerts"
    #   url     = "https://hooks.slack.com/services/T1234567/AAAAAAAA/ZZZZZZ"
    # }
  }
}

# Create a latency alert for the uptime check
resource "digitalocean_uptime_alert" "downglobal_shamirhusein_my_id" {
  name       = "downglobal-alert"
  check_id   = digitalocean_uptime_check.shamirhusein_my_id.id
  type       = "down_global"
  threshold  = 300
  comparison = "greater_than"
  period     = "2m"
  notifications {
    email = ["shamirhusein@gmail.com"]
    # slack {
    #   channel = "Production Alerts"
    #   url     = "https://hooks.slack.com/services/T1234567/AAAAAAAA/ZZZZZZ"
    # }
  }
}