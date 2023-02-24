# Deployment and Configuration with Ansible

Once the infrastructure has been created, it's time to deploy and configure
BAP with Ansible. The toolkit provides a set of playbooks and roles that
will do this job.

## 1. Install Ansible and Dependencies

To install Ansible and the dependencies needed to run the playbooks, run
the follow commands from a terminal on the control node:

1. Install Ansible using `pip`:

   ```terminal
   pip3 install ansible
   ```

1. Reset the terminal if the commands are not available yet.

1. Install Ansible dependencies, roles, and playbooks:

   ```terminal
   cd ansible

   pip3 install -r requirements/requirements.txt

   ansible-galaxy install -r requirements/ansible-galaxy-requirements.yml
   ```

## 2. Setup the Inventory and Configuration

As it happens with Terraform, Ansible needs some configuration parameters
in oder to run. You will need to define specific parameters that depend on
the cloud provider you are using and some parameters to deploy and configure
BAP.

We recommend to store the files in a specific directory for your project under
the `ansible/environments` directory of the toolkit repository (e.g.
`ansible/environments/myproject/`). Create there the `inventory` directory.
This documentation assumes you're storing the files there.

### Dynamic Inventory

We use dynamic inventories to help Ansible to locate what virtual machines are
available for deploying the platform. Inventories are dependant of the cloud
provider so some specific configuration is needed. Save this config under
the `ansible/environments/<environment>/inventory` folder.

#### Google Cloud Platform

Create a new file named `<environment>.gcp.yml` (e.g. `myproject.gcp.yml`) in the
`inventory` directory with the following content:

```yaml
---
plugin: gcp_compute
projects:
  - <project_name>
scopes:
  - https://www.googleapis.com/auth/compute
hostnames:
  # List host by name instead of the default public ip
  - name
compose:
  # Set an inventory parameter to use the Public IP address to connect to the host
  # For External ip use "networkInterfaces[0].accessConfigs[0].natIP"
  ansible_host: networkInterfaces[0].networkIP
keyed_groups:
  - key: labels.bap_node_type
    separator: ''
```

Replace the entries in `<>` with your values:

- `project_name`: the [id](https://support.google.com/googleapi/answer/7014113?hl=en) of the GCP project.

### BAP Configuration

Inside the `inventory` directory, create a file named `vars.yml` with the
following contents:

```yaml
---
all:
  vars:
    # Ansible Settings
    ansible_user: "<service_account_ssh_user>"
    ansible_ssh_private_key_file: "<path_to_ssh_key>"

    gcp_service_account_host_file: "<path_to_service_account_credentials_json>"

    # Project settings
    project_id: "<project_name>"

    # Passwords and credentials
    mariadb_root_password: <mariadb_root_password>
    mariadb_service_account: sortinghat
    mariadb_service_account_password: <sortinghat_password>
    redis_password: <redis_password>

    # OpenSearch Settings
    opensearch_cluster_prefix: <opensearch_cluster_prefix>
    opensearch_cluster_name: <opensearch_cluster_name>
    opensearch_cluster_heap_size: <opensearch_cluster_heap_size>

    ## OpenSearch Credentials
    opensearch_admin_user: <admin_username>
    opensearch_admin_password: <admin_password>
    opensearch_dashboards_password: <dashboards_password>
    opensearch_customer_user: <default_user_username>
    opensearch_customer_password: <default_user_password>
    opensearch_readall_password: <default_readall_password>
    opensearch_backups_user: <backup_username>
    opensearch_backups_password: <backup_password>

    ## Backups Storage
    backups_assets_bucket: <backups_bucket_name>

    # SortingHat Credentials
    sortinghat_secret_key: <sortinghat_secret_key>
    sortinghat_superuser_name: <sortinghat_admin_username>
    sortinghat_superuser_password: <sortinghat_admin_password>

    # Sortinghat Storage
    sortinghat_assets_bucket: <sortinghat_bucket_name>
    sortinghat_bucket_provider: <cloud provider>

    # Mordred Settings
    mordred_setups_repo_url: <repo_mordred_config.git>
    mordred_instances:
    - project: <project_a>
      tenant: <tenant_name_a>
      mordred_password: <mordred_tenant_a_password>
      sources:
        repository: "<repo_teneant_a_projects.git>"
    - project: <project_b>
      tenant: <tenant_name_b>
      mordred_password: <mordred_tenant_b_password>
      sources:
        repository: "<repo_teneant_b_projects.git>"

    virtualhost:
      fqdn: <fqdn>
```

Replace the entries in `<>` with your values:

- `ansible_user`: SSH username for the Service Account, in the format of `sa_<ID>`.
- `ansible_ssh_private_key_file`: Absolute path to the SSH private key file for
  the Service Account. If you followed this documentation, you should have it
  stored under the `keys/<enviroment>/` directory.
- `gcp_service_account_host_file`: Absoulute path to the Service Account
  credentials file. If you followed this documentation, you should have it
  in a `.json` file under the `keys/<enviroment>/` directory.
- `project_id`: the [id](https://support.google.com/googleapi/answer/7014113?hl=en) of the GCP project.
- `mariadb_root_password`: strong password for the MariaDB root user.
- `mariadb_service_account_password`: strong password for the MariaDB
  service account user.
- `redis_password`: strong password for the redis server.
- `opensearch_cluster_prefix`: prefix of the OpenSearch cluster.
- `opensearch_cluster_name` (optional): name of the OpenSearch cluster.
  This value will be used in combination with `<opensearch_cluster_prefix>`
  to define the name of the cluster. Its default parameter is `bap-opensearch`.
- `opensearch_cluster_heap_size` (optional): Java heap size for the OpenSearch cluster nodes (e.g. `1g`, `2g`).
  If you don't set a value, its default value will be `512m`.
- `opensearch_admin_user`: admin user on the OpenSearch cluster.
- `opensearch_admin_password`: strong password for the admin user of OpenSearch.
- `opensearch_dashboards_password`: strong password for internal communication.
  between OpenSearch and OpenSearch Dashboards.
- `opensearch_customer_user`: default user for OpenSearch dashboards.
- `opensearch_customer_password`: strong password for the default user.
- `opensearch_readall_password`: strong password for the internal OpenSearch user.
- `opensearch_backups_password`: strong password for the backups user.
- `backups_assets_bucket`: this is the name of the bucket created by Terraform
  for storing the OpenSearch snapshots and MariaDB backups.
  Check your cloud provider to obtain the name of the bucket. If you didn't
  change the configuration, it should be `<prefix>-bap-backups-<id>`, where
  `<prefix>` is the [terraform prefix](https://github.com/bitergia-analytics/bap-deployment-toolkit/blob/main/docs/provision.md#gcp-module-settings-environmenttf)
  and `<id>` is a random number.
- `sortinghat_secret_key`: strong password/key for the SortingHat service.
- `sortinghat_superuser_name`: admin user of the SortingHat service.
- `sortinghat_superuser_password`: strong password for the admin user
  of the SortingHat server.
- `sortinghat_assets_bucket`: this is the name of the bucket created by
  Terraform for storing the static files of the SortingHat's UI. Check your
  cloud provider to obtain the name of the bucket. It should start with
  the prefix `<prefix>-bap-sortinghat-`, where `<prefix>` is the
  [terraform prefix](https://github.com/bitergia-analytics/bap-deployment-toolkit/blob/main/docs/provision.md#gcp-module-settings-environmenttf).
- `sortinghat_bucket_provider`: cloud provider type; valid values are: `gcp`.
- `virtualhost.fqdn`: full qualified domain name (e.g. `bap.example.com`)
  where BAP will be available.

After configuring these parameters, you need to configure the instances of the
task scheduler (Mordred). You need a task scheduler for each project you want
to analyze. Check the section about configuring Mordred for more information
about how to setup the task scheduler.

- `mordred_setups_repo_url`: URL of the git repository where the configuration
  for each project/mordred instance are stored.
- `mordred_instances`: create as many entries of project as you might need.
- `mordred_instances.project`: name of the project to analyze.
- `mordred_instances.tenant`: the name used here will be used to store the
   data from this project in a separate tenant from the others.
- `mordred_instances.mordred_password`: strong password for the modred user
   of this tenant.
- `mordred_instances.sources.repository`: repository with the list of data
   sources to analyze on this project

#### OpenID Configuration (Optional)

If you're using OpenID/OAuth 2.0 for authenticating the users that will access
the platform, you need to add this configuration to the `vars.yml` file under
the `all.vars` section.

```yaml
    openid:
      connect_url: "<openid_connect_url>"
      subject_key: "email"
      admins:
        users:
          - <user1@example.com>
          - <user2@example.com>
      client_id: "<client_id>"
      client_secret: "<client_secret>"
      base_redirect_url: "https://<fnqd>"
      logout_url: "https://<fnqd>/auth/openid/login"
```

Replace the entries in `<>` with your values:

- `openid.connect_url`: url of your OpenID provider
- `openid.admins.users`: list of the users (email accounts) that when the
   service is deployed will have access to the platform. You need to set at
   least one to have access. Later, you can create more users using the
   OpenSearch Dashboards interface.
- `openid.client_id`: ID of the OAuth client used to authorize the users.
- `openid.client_secret`: Secret of the OAuth client used to authorize the users.
- `openid.base_redirect_url`: Replace `fnqd` by the full domain where the
  platform will be served.
- `openid.logout_url`: Replace `fnqd` by the full domain where the platform
  will be served.

#### Custom SSL Certificates (Optional)

If you have custom SSL certificates for the domain where the platform will
be serve, you will need to add some configuration to the `vars.yml` file under
the `all.vars` section.

We recommend to store all the certificates in the directory `keys/<environment>`
of this toolkit.

```yaml
    custom_cert:
      cert: <path_to_the_cert_file>
      key: <path_to_the_key_file>
```

Replace the entries in `<>` with your values:

- `custom_cert.cert`: path to your `.crt` or `.pem` certificate
- `custom_cert.key`: path to your `.key` file

## 3. Setup Ansible Authentication

Ansible will need to authenticate and access the resources in order to deploy
the platform. Depending on your cloud provider, the authentication method may
vary.

### Google Cloud Platform

Run the following commands:

```terminal
export GCP_SERVICE_ACCOUNT_FILE=<path_sa_credentials.json>
export GCP_AUTH_KIND=serviceaccount
```

Where `path_sa_credentials.json` is the path to the credentials file you
saved when you created the service account. If you followed the instructions
of this documentation, it should be stored in `keys/<environment>` directory.

## 4. Deploy the Platform

Now you are ready to deploy the platform with Ansible. From the `ansible`
directory, run the following command to deploy and configure it:

```terminal
ansible-playbook -i environments/<environment>/inventory/ playbooks/all.yml
```

After some minutes, the platform will be accessible in the domain you configured
on the previous step.
