# Deployment and Configuration with Ansible

Once the infrastructure has been created, it's time to deploy and configure
BAP with Ansible. The toolkit provides a set of playbooks and roles that
will do this job.
If you want to deploy all BAP services in one VM, in the section **4. Deploy the platform**,
you will have to run [all_in_one.yml](/docs/deployment_and_config.md#deploy-all-bap-services-in-a-single-vm-optional) playbook.

## 1. Install Ansible and Dependencies

To install Ansible and the dependencies needed to run the playbooks, run
the follow commands from a terminal on the control node:

1. Install Ansible using `pip`:

   ```terminal
   pip3 install ansible --break-system-packages
   ```

1. Reset the terminal if the commands are not available yet.

1. Install Ansible dependencies, roles, and playbooks:

   ```terminal
   cd ansible

   pip3 install -r requirements/requirements.txt --break-system-packages

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
    mariadb_backup_service_account: backup
    mariadb_backup_service_account_password: <mariadb_backup_password>
    mariadb_service_account: grimoirelab
    mariadb_service_account_password: <grimoirelab_password>
    redis_password: <redis_password>

    # MariaDB Settings
    mariadb_innodb_buffer_pool_size: <innodb_buffer_pool_size>

    # Uncomment to add a custom ca-certificate
    #custom_ca_cert: <ca_cert>

    # OpenSearch Settings
    custom_opensearch_endpoint: <custom_opensearch_endpoint>
    opensearch_cluster_prefix: <opensearch_cluster_prefix>
    opensearch_cluster_name: <opensearch_cluster_name>
    opensearch_cluster_heap_size: <opensearch_cluster_heap_size>
    ## Uncomment to restore OpenSearch Security files from a backup
    # opensearch_security_backup_restore: true
    # opensearch_security_backup_restore_name: opensearch-security-backup_20241018.tgz

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

    # SortingHat Multi tenant
    sortinghat_multi_tenant: <sortinghat_multi_tenant>

    # Sortinghat Storage
    sortinghat_assets_bucket: <sortinghat_bucket_name>
    sortinghat_bucket_provider: <cloud provider>

    # Sortinghat Workers
    sortinghat_workers: <sortinghat_workers>

    # SortingHat uWSGI workers and threads
    sortinghat_uwsgi_workers: "<sortinghat_uwsgi_workers>"
    sortinghat_uwsgi_threads: "<sortinghat_uwsgi_threads>"

    # SortingHat Nginx max_conns
    sortinghat_max_conns: "<sortinghat_max_conns>"

    # Ngninx Certbot
    letsencrypt_register_email: <letsencrypt_register_email>

    ## Uncomment to define custom certificates. Otherwise it will create Let's Encrypt certificates.
    #custom_cert:
    #  cert: custom.crt
    #  key: custom.key

    # Instance Setting
    instance:
      sortinghat: <True | False>
      public: <True | False>
      fqdn: example.com
```

Replace the entries in `<>` with your values:

- `ansible_user`: SSH username for the Service Account, in the format of `sa_<ID>`.
- `ansible_ssh_private_key_file`: Absolute path to the SSH private key file for
  the Service Account. If you followed this documentation, you should have it
  stored under the `keys/<environment>/` directory.
- `gcp_service_account_host_file`: Absolute path to the Service Account
  credentials file. If you followed this documentation, you should have it
  in a `.json` file under the `keys/<environment>/` directory.
- `project_id`: the [id](https://support.google.com/googleapi/answer/7014113?hl=en) of the GCP project.
- `mariadb_root_password`: strong password for the MariaDB root user.
- `mariadb_backup_service_account_password`: strong password for the MariaDB backup service account.
- `mariadb_service_account_password`: strong password for the MariaDB
  service account user.
- `redis_password`: strong password for the redis server.
- `mariadb_innodb_buffer_pool_size`: The size in bytes of the buffer pool, the memory
  area where InnoDB caches table and index data. A good value is 70%-80% of available
  memory (by default is `6871947673` 6.4G)
- `custom_ca_cert` (optional): custom ca-certificate.
- `custom_opensearch_endpoint` (optional): external OpenSearch endpoint.
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
- `sortinghat_multi_tenant`: activate SortingHat multi tenant (`"true" | "false"`,
  by default is `"true"`).
- `sortinghat_assets_bucket`: this is the name of the bucket created by
  Terraform for storing the static files of the SortingHat's UI. Check your
  cloud provider to obtain the name of the bucket. It should start with
  the prefix `<prefix>-bap-sortinghat-`, where `<prefix>` is the
  [terraform prefix](https://github.com/bitergia-analytics/bap-deployment-toolkit/blob/main/docs/provision.md#gcp-module-settings-environmenttf).
- `sortinghat_bucket_provider`: cloud provider type; valid values are: `gcp`.
- `sortinghat_workers`: number of SortingHat Workers (by default is `1`).
- `sortinghat_uwsgi_workers`: number of SortingHat uWSGI workers (by default is `1`).
- `sortinghat_uwsgi_threads`: number of SortingHat uWSGI threads (by default is `4`).
- `sortinghat_max_conns`: limits the maximum number of simultaneous active connections
  to the proxied server (by default is `75`).
- `letsencrypt_register_email`: email used for registration, recovery contact,
  and warnings about expired certs on Let's Encrypt.

After configuring these parameters, you need to configure the instances of the
task scheduler (GrimoireLab) and Nginx virtual host. Check the section about configuring
GrimoireLab for more information about how to setup the task scheduler.

- `instance`: GrimoireLab and Nginx virtual host configurations.
- `instance.sortinghat` (Optional): Active SortingHat endpoint `true | false` (by default is `false`).
- `instance.public` (Optional): OpenSearch Dashboards with anonymous access `true | false`. If
  the variable is not defined the OpenSearch Dashboards is private (by default is `false`).
- `instance.fqdn`: full qualified domain name (e.g. `bap.example.com`)
  where BAP will be available.

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

    opensearch_dashboards_multiple_auth: <true|false>
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
- `opensearch_dashboards_multiple_auth`: Enable multiple authorization to use
  Basic authorization and OpenID. If the value is `false` only OpenID is activated.

#### Custom SSL Certificates (Optional)

By default, the toolkit uses [Let's Encrypt](https://letsencrypt.org/) as CA
and to generate SSL certificates that will be renewed periodically. However,
if you want to stop using **Let's Encrypt** and to use your own certificates
instead, you will have to set some extra parameters to the `vars.yml` file
under the `all.vars` section.

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

#### Restore OpenSearch Security from a backup (optional)

Toolkit will create a backup daily by default, if you want to restore the
OpenSearch Security files from a backup add these parameters. Click [here](https://opensearch.org/docs/latest/security/configuration/security-admin/)
for more information.

- `opensearch_security_backup_restore`: Restore from a backup (by default is `false`)
- `opensearch_security_backup_restore_name`: The name of the backup to restore
  with the format `opensearch-security-backup_%Y%m%d.tgz` (e.g. `opensearch-security-backup_20241018.tgz`).
- `opensearch_security_backup_cronjob_time`: The frequency of the backup, here are the
  choices: `annually`, `daily`, `hourly`, `monthly`, `reboot`, `weekly`, and `yearly`
  (by default is `daily`).

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

### Deploy all BAP services in a single VM (Optional)

Run `all_in_one.yml` instead of running `all.yml` playbook.

```terminal
ansible-playbook -i environments/<environment>/inventory/ playbooks/all_in_one.yml
```

After some minutes, the platform will be accessible in the domain you configured
on the previous step.

### Connection to the platform using a IAP tunnel (GCP only)

If you configured an IAP tunnel to secure the access of the platform, you will
have to run some commands in your computer, in order to connect to front-end.
This configuration requires to have installed [gcloud CLI](https://cloud.google.com/sdk/docs/install).

First, you will need to check if the GCP project where you installed
the platform is active in your local configuration.

```terminal
gcloud config configurations list
gcloud config configurations activate [NAME]
```

If it's not, you will have to set it as active.

```terminal
gcloud config configurations create [NAME]
gcloud config set project [PROJECT-ID]
gcloud auth login
```

Once the project is configured in your local machine, you will need to create
a tunnel for your TCP connections. This tunnel goes from your local machine
to the to the NGINX instance, where the front-end is served.

```terminal
gcloud compute start-iap-tunnel <NGINX_INSTANCE_NAME> 443 --local-host-port=localhost:<LOCAL_PORT> --zone=<ZONE>
```

Then, connect to the dashboard with your browser
with the URL `https://localhost:<LOCAL_PORT>`.

For example, to connect to the dashboard using the port `8443` of your local
machine, you will have to run the following command:

```terminal
gcloud compute start-iap-tunnel test-nginx-0 443 --local-host-port=localhost:8443 --zone=europe-southwest1-a
```

Then, open your browser with the URL `https://localhost:8443`.

You can also find more info about TCP tunnels on [this doc](https://cloud.google.com/iap/docs/using-tcp-forwarding).
