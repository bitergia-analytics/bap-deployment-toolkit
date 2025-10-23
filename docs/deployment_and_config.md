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

As it happens with OpenTofu, Ansible needs some configuration parameters
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
auth_kind: application
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

    # Project settings
    project_id: "<project_name>"

    # Passwords and credentials
    mariadb_root_password: <mariadb_root_password>
    mariadb_backup_service_account: backup
    mariadb_backup_service_account_password: <mariadb_backup_password>
    mariadb_service_account: sortinghat
    mariadb_service_account_password: <sortinghat_password>
    redis_password: <redis_password>

    # MariaDB Settings
    mariadb_innodb_buffer_pool_size: <innodb_buffer_pool_size>

    # OpenSearch Settings
    opensearch_cluster_prefix: <opensearch_cluster_prefix>
    opensearch_cluster_name: <opensearch_cluster_name>
    opensearch_cluster_manager_heap_size: <opensearch_cluster_manager_heap_size>
    opensearch_cluster_data_heap_size: <opensearch_cluster_data_heap_size>
    ## Uncomment this section to configure OpenSearch notification channels for Slack.
    #opensearch_notification_channels:
    #- config_id: "slack_channel_1"
    #  name: "Slack Channel 1"
    #  description: "Slack channel 1 for OpenSearch notifications"
    #  config_type: "slack"
    #  slack_url: "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
    #- config_id: "slack_channel_2"
    #  name: "Slack Channel 2"
    #  description: "Slack channel 2 for OpenSearch notifications"
    #  config_type: "slack"
    #  slack_url: "https://hooks.slack.com/services/T00000000/B00000000/YYYYYYYYYYYYYYYYYYYYYYYY"

    ## Uncomment this section to configure a OpenSearch snapshot policy.
    #opensearch_snapshot_policy:
    #  policy_id: "daily_snapshot"
    #  description: "Daily snapshot policy for OpenSearch"
    #  time_limit: "1h"
    #  enabled: true
    #  retention:
    #    max_age: "30d"
    #    max_count: 31
    #    min_count: 1
    #  indices: "*"
    #  notification_channel_id: "slack_channel_1"
    #  notification_conditions:
    #    creation: true
    #    deletion: false
    #    failure: true
    #  creation_cron_expression: "0 0 * * *"  # Daily at midnight
    #  deletion_cron_expression: "0 3 * * *"  # Daily at 3 AM
    #  timezone: "UTC"
    #  date_format: "yyyy-MM-dd"

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
    backups_assets_bucket: <backups_assets_bucket>

    # SortingHat Credentials
    sortinghat_secret_key: <sortinghat_secret_key>
    sortinghat_superuser_name: <sortinghat_admin_username>
    sortinghat_superuser_password: <sortinghat_admin_password>

    # SortingHat Database
    sortinghat_database: <sortinghat_database>

    # SortingHat Multi tenant
    sortinghat_multi_tenant: <sortinghat_multi_tenant>

    # Sortinghat Storage
    sortinghat_assets_bucket: <sortinghat_assets_bucket>
    sortinghat_bucket_provider: <cloud provider>

    # Sortinghat Workers
    sortinghat_workers: <sortinghat_workers>

    # SortingHat uWSGI workers and threads
    sortinghat_uwsgi_workers: "<sortinghat_uwsgi_workers>"
    sortinghat_uwsgi_threads: "<sortinghat_uwsgi_threads>"

    # SortingHat Nginx max_conns
    sortinghat_max_conns: "<sortinghat_max_conns>"

    # Mordred Settings
    mordred_setups_repo_url: <repo_mordred_config.git>

    # Nginx Certbot
    letsencrypt_register_email: <letsencrypt_register_email>

    ## Uncomment to define an Nginx Default host
    #nginx_default_host: <nginx_defualt_fqdn>

    ## Uncomment to define custom certificates. Otherwise it will create Let's Encrypt certificates.
    #custom_cert:
    #  cert: custom.crt
    #  key: custom.key

    # Instances Settings
    instances:
    - project: <project_a>
      tenant: <tenant_name_a>
      public: false
      mordred:
        password: <mordred_tenant_a_password>
        overwrite_roles: <overwrite_roles>
        sources_repository: "<repo_teneant_a_projects.git>"
        host: <mordred_host_a>
      sortinghat:
        tenant: <tenant_name_a>
        dedicated_queue: true
        openinfra_client_id: "<openinfra_client_id>"
        openinfra_client_secret: "<openinfra_client_secret>"
        eclipse_foundation_user_id: "<eclipse_foundation_user_id>"
        eclipse_foundation_password: "<eclipse_foundation_password>"
      nginx:
        fqdn: <fqdn-1>
        http_rest_api: false
    - project: <project_b>
      tenant: <tenant_name_b>
      public: true
      mordred:
        password: <mordred_tenant_b_password>
        overwrite_roles: <overwrite_roles>
        sources_repository: "<repo_teneant_b_projects.git>"
        host: <mordred_host_b>
      sortinghat:
        tenant: <sortinghat_tenant>
        dedicated_queue: false
      nginx:
        fqdn: <fqdn-2>
        http_rest_api: true
```

Replace the entries in `<>` with your values:

- `ansible_user`: SSH username for the Service Account, in the format of `sa_<ID>`.
- `ansible_ssh_private_key_file`: Absolute path to the SSH private key file for
  the Service Account. If you followed this documentation, you should have it
  stored under the `keys/<environment>/` directory.
- `project_id`: the [id](https://support.google.com/googleapi/answer/7014113?hl=en) of the GCP project.
- `mariadb_root_password`: strong password for the MariaDB root user.
- `mariadb_backup_service_account_password`: strong password for the MariaDB backup service account.
- `mariadb_service_account_password`: strong password for the MariaDB
  service account user.
- `redis_password`: strong password for the redis server.
- `mariadb_innodb_buffer_pool_size`: The size in bytes of the buffer pool, the memory
  area where InnoDB caches table and index data. A good value is 70%-80% of available
  memory (by default is `6871947673` 6.4G)
- `opensearch_cluster_prefix`: prefix of the OpenSearch cluster.
- `opensearch_cluster_name` (optional): name of the OpenSearch cluster.
  This value will be used in combination with `<opensearch_cluster_prefix>`
  to define the name of the cluster. Its default parameter is `bap-opensearch`.
- `opensearch_cluster_manager_heap_size` (optional): Java heap size for the OpenSearch cluster manager nodes (e.g. `1g`, `2g`).
  If you don't set a value, its default value will be `512m`.
- `opensearch_cluster_data_heap_size` (optional): Java heap size for the OpenSearch cluster data nodes (e.g. `1g`, `2g`).
  If you don't set a value, its default value will be `512m`.
- `opensearch_admin_user`: admin user on the OpenSearch cluster.
- `opensearch_admin_password`: strong password for the admin user of OpenSearch.
- `opensearch_dashboards_password`: strong password for internal communication.
  between OpenSearch and OpenSearch Dashboards.
- `opensearch_customer_user`: default user for OpenSearch dashboards.
- `opensearch_customer_password`: strong password for the default user.
- `opensearch_readall_password`: strong password for the internal OpenSearch user.
- `opensearch_backups_password`: strong password for the backups user.
- `auditlog_policy`: auditlog policy.
- `auditlog_policy.name`: name of the auditlog policy (by default is `auditlog_policy`).
- `auditlog_policy.description`: description of the auditlog policy (by default is `3 month retention policy for auditlog indexes.`).
- `auditlog_policy.min_index_age`: minimum age of the index to be eligible for rollover (by default is `90d`).
- `backups_assets_bucket`: this is the name of the bucket created by OpenTofu
  for storing the OpenSearch snapshots and MariaDB backups.
  Check your cloud provider to obtain the name of the bucket. If you didn't
  change the configuration, it should be `<prefix>-bap-backups-<id>`, where
  `<prefix>` is the [opentofu prefix](https://github.com/bitergia-analytics/bap-deployment-toolkit/blob/main/docs/provision.md#gcp-module-settings-environmenttf)
  and `<id>` is a random number.
- `sortinghat_secret_key`: strong password/key for the SortingHat service.
- `sortinghat_superuser_name`: admin user of the SortingHat service.
- `sortinghat_superuser_password`: strong password for the admin user
  of the SortingHat server.
- `sortinghat_database`: SortingHat database (by default is `sortinghat_db`).
- `sortinghat_multi_tenant`: activate SortingHat multi tenant (`"true" | "false"`,
  by default is `"true"`).
- `sortinghat_assets_bucket`: this is the name of the bucket created by
  OpenTofu for storing the static files of the SortingHat's UI. Check your
  cloud provider to obtain the name of the bucket. It should start with
  the prefix `<prefix>-bap-sortinghat-`, where `<prefix>` is the
  [opentofu prefix](https://github.com/bitergia-analytics/bap-deployment-toolkit/blob/main/docs/provision.md#gcp-module-settings-environmenttf).
- `sortinghat_bucket_provider`: cloud provider type; valid values are: `gcp`.
- `sortinghat_workers`: number of SortingHat Workers (by default is `1`).
- `sortinghat_uwsgi_workers`: number of SortingHat uWSGI workers (by default is `1`).
- `sortinghat_uwsgi_threads`: number of SortingHat uWSGI threads (by default is `4`).
- `sortinghat_max_conns`: limits the maximum number of simultaneous active connections
  to the proxied server (by default is `75`).
- `letsencrypt_register_email`: email used for registration, recovery contact,
  and warnings about expired certs on Let's Encrypt.
- `nginx_defualt_fqdn` (optional): enable a default host (404 page not found).

After configuring these parameters, you need to configure the instances of the
task scheduler (Mordred) and Nginx virtual host. You need a task scheduler for each project
you want to analyze. Check the section about configuring Mordred for more information
about how to setup the task scheduler.

- `mordred_setups_repo_url`: URL of the git repository where the configuration
  for each project/mordred instance are stored.
- `instances`: Mordred and Nginx virtual host configurations. Create as many entries of
  project as you might need.
- `instances.project`: name of the project to analyze.
- `instances.tenant`: the name of the tenant for this OpenSearch Dashboards endpoint..
- `instances.public`: OpenSearch Dashboards with anonymous access `true | false`. If
  the variable is not defined the OpenSearch Dashboards is private.
- `instances.mordred.overwrite_roles` (optional): overwrite roles and tenant `true | false`.
- `instances.mordred.password`: strong password for the modred user
   of this tenant.
- `instances.mordred.sources_repository`: repository with the list of data
   sources to analyze on this project.
- `instances.mordred.host`: on which mordred VM host will deploy the container (e.g. `0`).
- `instances.sortingaht.tenant`: the name used here will be used to store the data from
- `instances.sortinghat.dedicated_queue` (optional): to run identities jobs on a dedicated queue.
   This will also create a dedicated worker for these tasks. The possible values are `true`
   or `false`. By default is set to `false`.
- `instances.sortinghat.openinfra_client_id` (optional): OpenInfraID Oauth2 client ID for private API. When the
  parameter is not set, it will only obtain members from the public API that doesn't contain
  email information. (by default is ""). Only works with dedicated queues.
- `instances.sortinghat.openinfra_client_secret` (optional): OpenInfraID Oauth2 client secret for private
   API (by default is ""). Only works with dedicated queues.
- `instances.sortinghat.eclipse_foundation_user_id` (optional): Eclipse Foundation API user ID.
- `instances.sortinghat.eclipse_foundation_password` (optional): Eclipse Foundation API user's password.
- `instances.nginx.fqdn`: full qualified domain name (e.g. `bap.example.com`)
  where BAP will be available.
- `instances.nginx.http_rest_api`: Open OpenSearch HTTP rest API only if the variable is defined
  with the value `true`.

**IMPORTANT**: When there are multiple instances that will use the same
SortingHat tenant, be sure the `instances.sortinghat` configuration is exactly
the same on all those entries. Unexpected errors can appear, if the parameters
are different.

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

#### SSH Keys for Non-Public Data Sources (Optional)

Sometimes, data sources such as `git` or `gerrit` would require access using
SSH protocol. For those cases, the platform generates a SSH key pair when it's
deployed for the first time. However, these keys won't work for private
repositories which require authentication. For those cases, you can provide your
own SSH keys, setting their location on the `vars.yml` file under the
`all.vars` section.

As with other keys and certificates, we recommend to store the certificates under
the `keys/<environment>` directory of this toolkit.

```yaml
    mordred_ssh_key:
      private: "<path_to_private_ssh_key>"
      public: "<path_to_public_ssh_key>"
```

Replace the entries in `<>` with your values:

- `mordred_ssh_key.private`: path to your SSH private key file
- `mordred_ssh_key.public`: path to your SSH public key file

#### Create OpenSearch notification channels for Slack (optional)

This toolkit allows to receive notifications about the activity on OpenSearch. Rigth now, the only
channel supported is Slack. To configure it add the following parameters to your config. You can
find more information in [the official documentation](https://docs.opensearch.org/docs/latest/observing-your-data/notifications/api/).

- `opensearch_notification_channels`: Channel configurations, only available for Slack.
  Create as many entries as you might need.
- `opensearch_notification_channels.config_id`: Specifies the channel identifier.
- `opensearch_notification_channels.name`: The name of the channel.
- `opensearch_notification_channels.description`: The description of the channel.
- `opensearch_notification_channels.slack_url`: The URL of the Slack channel.

Here are some examples of the notifications:

```text
Snapshot Management - Snapshot Creation Notification
Snapshot daily_snapshot-2025-07-04-566z0ew1 creation has finished successfully.

Snapshot Management - Snapshot Deletion Notification
Snapshot(s) [daily_snapshot-2025-07-04-ajuaw79l] deletion has finished.
```

#### Create OpenSearch Snapshot Policy (optional)

You can use the toolkit to set OpenSearch policies that will create data snapshots.
These snapshots will serve as a backup in the case you need to recover data. By default,
the will be created every day but you can set how often you want to generate them.
At the same time, you can set a retention policy to delete old snapshots. By default,
snapshots will be kept for 30 days.
You can find more info about how snapshots work on OpenSearch in
[their official documentation](https://docs.opensearch.org/docs/latest/tuning-your-cluster/availability-and-recovery/snapshots/sm-api/).
Set the following parameters to configure the snapshot policies.

**Important**: You must create and configure a OpenSearch notification channel
before setting up `opensearch_snapshot_policy.notification_channel_id`.

- `opensearch_snapshot_policy`: Snapshot management policy
- `opensearch_snapshot_policy.policy_id`: Policy ID
- `opensearch_snapshot_policy.description`: The description of the SM policy
- `opensearch_snapshot_policy.enabled`: Should this SM policy be enabled at creation?
- `opensearch_snapshot_policy.date_format`: Specifies the format for the date in the snapshot name.
  Supports all date formats supported by OpenSearch (e.g. "yyyy-MM-dd"). Snapshot names
  have the format `<policy_name>-<date_format>-<random number>`.
- `opensearch_snapshot_policy.indices`: The names of the indexes in the snapshot. Multiple index
  names are separated by `,`. Supports wildcards (`*`).
- `opensearch_snapshot_policy.creation_cron_expression`: The cron schedule used to create snapshots.
- `opensearch_snapshot_policy.deletion_cron_expression`: The cron schedule used to delete snapshots.
- `opensearch_snapshot_policy.time_limit`: Sets the maximum time to wait for snapshot creation and
  deletion to finish.
- `opensearch_snapshot_policy.retention.max_age`: The maximum time a snapshot is retained.
- `opensearch_snapshot_policy.retention.max_count`: The maximum number of snapshots to be retained.
- `opensearch_snapshot_policy.retention.min_count`: The minimum number of snapshots to be retained.
- `opensearch_snapshot_policy.notification_channel_id`: The channel ID of the channel used for notifications.
- `opensearch_snapshot_policy.notification_conditions.creation`: Do you want notifications about snapshot creation? (`true` | `false`).
- `opensearch_snapshot_policy.notification_conditions.deletion`: Do you want notifications about snapshot deletion? (`true` | `false`).
- `opensearch_snapshot_policy.notification_conditions.failure`: Do you want notifications about creation or deletion failure? (`true` | `false`).
- `opensearch_snapshot_policy.timezone`: Policy timezone (e.g. `UTC`). You can find the entire list at [TZ Identifier column](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

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

Make sure the SSH keys you configured in the previous step are copied to
`keys/<environment>/` with the correct permissions and add the username to
`ansible_user` (`sa_<ID>`) in `vars.yml`.

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
