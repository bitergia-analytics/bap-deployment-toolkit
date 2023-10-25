# Provisioning with Terraform

The toolkit uses Terraform to manage, on your cloud provider, the lifecycle of
the resources needed by BAP. It will be responsible of creating and updating
virtual machines, storage buckets, and firewall rules.

## 1. Install Terraform

You will have to install Terraform on the control node. There are many methods
to do it but we recommend the one described on the
[official documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

:information_source:&nbsp; You might need to install `wget` to install
Terraform. You can do it with the following command:

```terminal
sudo apt install wget
```

## 2. Configure Terraform

Due to cloud providers offer different types of solutions and resources, you're
required to define some configuration parameters before running Terraform. These
parameters are stored in the files:

- `variables.tf` - sets the common variables
- `main.tf` - defines the cloud provider basic parameters
- `environment.tf` - stores the types of the virtual machines

We recommend to store the files in a specific directory for your project under
the `terraform/environments` directory of the toolkit repository (e.g.
`terraform/environments/myproject/`). This documentation assumes you're storing
the files there.

The next sections describe how to set up the configuration based on your cloud
provider.

### Google Cloud Platform

#### Variables (`variables.tf`)

Below you can find the variables you need to configure in `variables.tf` file.

```tf
variable "project" {
  default = "<project_name>"
}

variable "zone" {
  default = "<project_zone>"
}

variable "prefix" {
  default = "<project_prefix>"
}
```

Replace the entries in `<>` with your values:

- `project`: the [id](https://support.google.com/googleapi/answer/7014113?hl=en) of the GCP project.
- `zone`: the GCP [zone](https://cloud.google.com/compute/docs/regions-zones)
   where the resources of the project will be created.
- `prefix`: the prefix that is added to all resources created by Terraform (VM, Cloud Storage Bucket, firawall, etc).

#### Terraform Settings (`main.tf`)

This is the template for the `main.tf`.

```tf
terraform {
  required_version = ">= 1.0"

  backend "gcs" {
    bucket  = "<bucket_name>"
    prefix = "<folder_name>"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project
  zone = var.zone
}
```

Replace the entries in `<>` with your values:

- `bucket`: name of the bucket to store the Terraform state. This is the value
   of the bucket defined in the [prerequisites section](./prerequisites.md).
- `prefix`: name of the folder where the state will be stored.

### GCP Module Settings (`environment.tf`)

Below, you can find the different variables you can configure for this module.
You can set the number of nodes and virtual machine type for each component
of the architecture. Take the next example as reference for a large project
but adapt them to your necessities.

You can create different OpenSearch Dashboards machines depends on your needs.
We have three scenarios for OpenSearch Dashboards:

1. One OpenSearch Dashboards `without anonymous` access.
    - `opensearch_dashboards_node_count = 1`
    - `opensearch_dashboards_anonymous_node_count = 0`
2. One OpenSearch Dashboards `with anonymous` access.
    - `opensearch_dashboards_node_count = 0`
    - `opensearch_dashboards_anonymous_node_count = 1`
3. Two OpenSearch Dashboards `one with anonymous` access and the `other not`.
    - `opensearch_dashboards_node_count = 1`
    - `opensearch_dashboards_anonymous_node_count = 1`

Ansible will provision the OpenSearch Dashboard machines depending on which
group the hostname belongs to.

If you decided to activate IAP, you can also create a TCP tunnel, so the
platform will only be accessible to the defined users through it. There won't
be any other way to access it. You can activate this IAP tunnel over TCP with
the following config parameters. By default, the tunnel won't be created.

- `network_iap_tunnel = true`
- `network_nginx_iap_tunnel_members = ["user:example@example.com"]`

If you have doubts about how to list the users, please check the following
[link](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_tunnel_instance_iam#argument-reference).

```tf
module "bap_env_gcp" {
  source = "../../modules/bap_env_gcp"

  prefix = "test"
  zone = var.zone

  custom_tags = ["devel", "research"]

  mariadb_node_count = 1
  mariadb_machine_type = "e2-standard-2"

  redis_node_count = 1
  redis_machine_type = "e2-standard-2"

  opensearch_node_count = 3
  opensearch_machine_type = "e2-highmem-4"

  opensearch_dashboards_node_count = 1
  opensearch_dashboards_anonymous_node_count = 0
  opensearch_dashboards_machine_type = "e2-highmem-4"

  nginx_node_count = 1
  nginx_machine_type = "e2-standard-2"

  mordred_node_count = 1
  mordred_machine_type = "e2-standard-2"

  sortinghat_node_count = 1
  sortinghat_machine_type = "e2-standard-2"

  sortinghat_worker_node_count = 2
  sortinghat_worker_machine_type = "e2-standard-2"

  network_iap_tunnel = false
  network_nginx_iap_tunnel_members = ["user:example@example.com"]
}

output "bap_env_gcp" {
  value = module.bap_env_gcp
}
```

## 3. Provision

Once you have created all the configuration files, you will be ready to create
the infrastructure for the platform. Run the following commands:

1. Change to the Terraform environment directory:

   ```terminal
   cd terraform/environments/<environment>
   ```

1. Initialize Terraform downloading the requirements and configuring the modules.

   ```terminal
   terraform init
   ```

1. Provision the infrastructure. You will need to confirm the changes.

   ```terminal
   terraform apply
   ```
