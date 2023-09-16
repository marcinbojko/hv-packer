packer {
  required_plugins {
    windows-update = {
      version = ">= 0.14.1"
      source = "github.com/rgl/windows-update"
    }
    hyperv = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/hyperv"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}
