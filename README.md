
# k8s Infra provisioning on Azure
This guide will walk you through setting up the Azure infrastructure for kubernets,which can be further deployed using the Kismatic Enterprise Toolkit (KET).

## Pre-reqs:

- Install the terraform from https://www.terraform.io/downloads.html on your dev environment.
- create a `ssh-key` and suppy the key path in the variables file
                ```variable "ssh-public-key" {
                  default = "~/.ssh/id_rsa.pub"
                }```
                
## Modules structuring

- `network` creates the virtual network in the azure
- `master`  creates the master node requirments for k8s
- `etcd`    creates the etcd node requirments for k8s
- `worker`  creates the worker node requirments for k8s

## Usage Instructions

- Log into Azure using the azure CLI: `az login`
- `./tplan.sh` Generates the terraform plan to provision the infra
- `./tapply.sh` Apply the generated plan to create the infra on azure


## Module invocation usage
```hcl

module "network" {
  source = "modules/network"

  region          = "${var.region}"
  address_space   = "${var.address_space}"
  environment     = "${var.environment}"
  subnet_names    = "${var.subnet_names}"
  subnet1_cidr    = "${var.subnet1_cidr}"
  subnet2_cidr    = "${var.subnet2_cidr}"

}
```

### Next, follow instructions on to get your cluster up via Kismatic
https://github.com/apprenda/kismatic
  



