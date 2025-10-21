# Prerequisites

Before you can deploy the platform, you will have to setup the environment,
that is needed to run the tools, executing some manual steps. These steps
might vary depending on the cloud provider where you will install the platform.

For these steps, you won't need any other program not available on your system
or in any of the contents of this toolkit.

## 1. Configure Your Cloud Environment

### Google Cloud Platform

We assume you have a GCP project ready and you have enough privileges to operate
it. You will need a user with, at least, `Editor` permissions.

To deploy the platform in Google Cloud you will need:

- A service account with permissions for provisioning.
- A pair of SSH keys to access the virtual machines.
- A control node

#### Activate Services APIs

During the deployment of the platform, the toolkit will make use of the APIs of
some services available on GCP. Basically, it'll need permissions to create
and destroy new compute engines, configure resources, or grant permissions
to some service accounts. These are the APIs to enable:

- `compute.googleapis.com`
- `iam.googleapis.com`
- `cloudresourcemanager.googleapis.com`

By default, the services above aren't activated when a GCP project is created,
but they might be already activated on your project if it's been used for other
purposes.

On the Cloud Shell terminal, you can activate them by running the following
commands:

```terminal
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

The services should now been activated.

#### Setup Provider Authentication and Authorization - Service Account

OpenTofu and Ansible will use a Service Account to provision the platform
on your project. This account will have the minimum permissions necessary
for these tasks. To create one, follow these steps:

1. Access GCP's [Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) page.
1. Select the correct project in the dropdown at the top of the page.
1. Create an account with a descriptive name like `bap-sa`.
1. Assign the following IAM roles:
   - `Compute Admin`
   - `Storage Admin` (**Note**: not `Compute Storage Admin`)
   - `Service Account User`

#### Create a Control Node

This documentation assumes you're going to use a control node to add the
provisioning code and configuration files in order to deploy the platform.
The following steps will help you with the basic configuration of this node.

1. From the `Cloud Shell terminal` run the next command to create a
   virtual machine. You need to select the [zone](https://cloud.google.com/compute/docs/regions-zones)
   where the machine will be created (e.g. `europe-southwest1-a`).

   ```terminal
   gcloud compute instances create control-node \
       --image-project=debian-cloud \
       --image-family=debian-11 \
       --machine-type=e2-small \
       --zone=<zone> \
       --service-account=<bap-service-account-email> \
       --scopes=cloud-platform \
       --tags=control
   ```

1. To log in, go to `Compute Engine` > `VM instances` ([link](https://console.cloud.google.com/compute/instances))
   and open a SSH terminal on the control node by clicking on the `SSH`
   button of `control-node` entry.

#### Setup SSH Authentication - OS Login

OpenTofu and Ansible will use SSH to create virtual machines and to provision
other resources. In the case of GCP, you will need to enable
[OS Login](https://cloud.google.com/compute/docs/oslogin) to activate
SSH access.

Follow the next steps on the `control-node`.

1. Generate a SSH key pair. If you don't know how to do it, we recommend to
   follow the steps described on the
   [GitLab documentation](https://docs.gitlab.com/ee/user/ssh.html#generate-an-ssh-key-pair).

1. Activate OS Login for the project.

   ```terminal
   gcloud compute project-info add-metadata --metadata enable-oslogin=TRUE
   ```

1. Add the project's public SSH key to the account

   :information_source:&nbsp;  This command will output the SSH Username
   for the Service Account, typically in the format of `sa_<ID>`.
   Jot down this username for later. It will be used in the Ansible
   configuration.

   ```terminal
   gcloud compute os-login ssh-keys add --key-file=<SSH key>.pub
   ```

SSH access should now be enabled on the Service Account and this will be used
by Ansible to SSH login to each VM.

#### Setup OpenTofu State Storage Bucket - GCP Cloud Storage

OpenTofu state will be stored on a GCP bucket. For the bucket you will
need a unique name such as `<project-name>-opentofu-state`
(e.g. `myproject-opentofu-state`) and a
[bucket storage location](https://cloud.google.com/storage/docs/locations).

Then, run this command from the `control-node` machine:

```terminal
gsutil mb -l <bucket_location> gs://<project-name>-opentofu-state
```

For example:

```terminal
gsutil mb -l EU gs://bap-opentofu-state
```

#### Setup OAuth 2.0 with GCP (Optional)

OpenSearch supports OpenID which can be used to
[connect Google Authentication and OAuth 2.0](https://support.google.com/cloud/answer/6158849?hl=en)
with OpenSearch Dashboards. This means that you can allow users to log in BAP
using your Google organization's accounts instead of the OpenSearch internal
users.

To enable OAuth you will need to create an OAuth consent screen and
client ID.

##### Create OAuth Consent Screen

1. On the `API & Services` menu, access the
   [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent)
   section.
1. Make sure the right project is selected on the dropdown at the top of the
   page.
1. Select `Internal` and click on `Create`.
1. Set meaningful values for the OAuth screen that will be shown to the users
   when they will authenticate:
    - `App information` section:
        - `App name`: the name of the app/service that will be displayed
           to your users (e.g. `Bitergia Analytics`).
        - `User support email`: service support email
    - `App logo`: upload a image to show to the users (optional)
    - `App domain`: fill out these fields according to you needs (optional)
    - `Developer contact information`: these email addresses are for Google
      to notify you about any changes to your project.
1. Click on `SAVE AND CONTINUE` after completing the data.
1. Add scopes (optional) if that applies to you.
1. Click again on `SAVE AND CONTINUE` and after that on `BACK TO DASHBOARD`
   to complete the setup.

##### Create a OAuth 2.0 Client ID

1. On the `API & Services` menu, access the [Credentials](https://console.cloud.google.com/apis/credentials))
   section.
1. Make sure the right project is selected on the dropdown at the top of the
   page.
1. Click on `CREATE CREDENTIALS` > `OAuth client ID`.
1. Select `Web application` in the dropdown menu `Application Type`.
1. Choose a meaningful name to identify your client on the field `Name`
   (e.g. `bap-oauth-client`).
1. Add two URIs to on the `Authorized redirect URIs` section. Replace
   `<domain>` with the domain where you plan to serve BAP:
     - `https://<domain>/` (e.g. `https://myproject.example.com`)
     - `https://<domain>/auth/openid/login` (e.g. `https://myproject.example.com/auth/openid/login`)
1. Click on `CREATE` and save JSON file with the credentials for later usage.

#### Setup IAP (Optional)

IAP allows to _establish a central authorization layer for applications
accessed by HTTPS_. You can define which users or groups in your organization
can access which resources.
[Google documentation](https://cloud.google.com/iap/docs/concepts-overview)
provides a extensive description of how IAP works and how you can configure
to limit the access to your resources.

If you want to restrict the access to BAP, using IAP, for users or groups
within your GCP organization, you will have to give some permissions
to the project. IAP requires of:

- `iap.googleapis.com` (service)
- `IAP Policy Admin` (IAM policy)

Activate the service from the Cloud Shell terminal with:

```terminal
gcloud services enable iap.googleapis.com
```

And assign the policy to the service account created in the previous steps:

1. Access GCP's [IAM permissions](https://console.cloud.google.com/iam-admin/iam) page.
1. Select the correct project in the dropdown at the top of the page.
1. Click on the pencil icon of the BAP service account created for this project.
1. Click on `+ ADD ANOTHER ROLE`.
1. Select the role `IAP Policy Admin`.
1. Click on `SAVE`.

On the next sections, you will be able to create a IAP tunnel through TCP,
so the front-end of the platform will only be accessible selected users
from their local computers.

## 2. Setup the Control Node

1. Install and update the required packages.

   ```terminal
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y git python3-pip python3-venv
   ```

1. Download the toolkit repository with `git`.

   ```terminal
   git clone https://github.com/bitergia-analytics/bap-deployment-toolkit.git
   ```

1. Create a project directory (e.g. `myproject`) inside the `keys` directory
   of the repository. You will use this directory to store all the keys and
   certificates needed to configure the platform.

1. Copy the keys inside the directory created on the previous step. Key files
   usually need to have the right permissions or Ansible will complain about it.
   Only the user will be allowed to read/write to the file.
   Use the next command to update the permissions of all your keys:

   ```terminal
   chmod 600 ../keys/<env>_ssh_key
   ```

## 3. BAP Configuration

Bitergia Analytics Platform requires a list of repositories to analyze and
the configuration that determines how they are going to be analyzed.

The platform expects as input a set of projects (`projects.json` file).
Each one of these projects contain a list of data sources. These can be `git`,
`Github` or `Gitlab` repositories, `Slack` channels, `Jira` projects and so on.
With this input, the platform will retrieve their data and produce metrics and
analysis according an initial configuration (`setup.cfg`).

The platform also allows to create tenants for your users. This mean you can
create a tenant to analyze a set of projects and create another tenant to
analyze the same projects or some others and data won't be accessible between
them.

### Configuration and projects repositories

The toolkit assumes you are going to have store all these configurations on
`git` repositories, following this structure:

- A repository to store the configurations for every tenant. Each directory,
  on the root directory, will represent a tenant and it will store a `setup.cfg`
  file (see below).

  ```sh
  bap-tenants.example.com.git
  └─ go
     └─ setup.cfg
  └─ tensorflow
     └─ setup.cfg
  └─ angular
     └─ setup.cfg
  ```

- One repository for tenant to store the list of projects to analyze in a
  `projects.json` file.

  ```sh
  go.example.com.git
  └─ projects.json

  tensorflow.example.com.git
  └─ projects.json

  angular.example.com.git
  └─ projects.json
  ```

### Configuring the `setup.cfg` file

This file defines, among other things:

- Which phases of data retrieval and processing are enabled.
- Which backends are used to fetch the data.

Check out the [Mordred documentation](https://github.com/chaoss/grimoirelab-sirmordred#setupcfg-)
on this to see how to set up its contents.

### Configuring the `projects.json` file

This file defines the data sources from where to retrieve the data. Check out the
[Mordred documentation](https://github.com/chaoss/grimoirelab-sirmordred#projectsjson-)
on this to see how to set up its contents.

## 4. Setup Custom Certificates (Optional)

If you plan to use certificates to serve BAP on your domain, copy all your
`.cert`, `.pem`, and `.key` files to use under the `keys/<env>` directory
created on the previous step.

## 5. Alerts (Optional)

You can also use the toolkit to add pre-defined basic alerts on your cloud
provider. They will trigger when something is wrong with the health of the
platform. Unfortunately at this moment, this is only available for the
infrastructure deployed on GCP.

### Google Cloud Platform alerting prerequisites

The alerting system uses the metrics generated by the [Monitoring system](https://console.cloud.google.com/monitoring),
which gathers data from the Google Ops Agents installed on every instance of the
platform. These metrics are useful to evaluate the state of every component
of the infrastructure and to trigger alerts when something starts to go wrong.

Some of the alerts of this toolkit are inspired by the ones defined on the
[GCP Cloud Monitoring Dashboard Samples](https://github.com/GoogleCloudPlatform/monitoring-dashboard-samples/).
with license Apache 2.0.

GCP requires to define, at least, one notification channel where alerts will
be published.

#### Configure the notification channels

GCP supports several types of channels. You can send receive the alerts on
an email account, a Slack channel, on PagerDuty, among others. The configuration
of each channel is out of the scope of this document but we will provide you
the basic steps to do it:

1. Go to the [Notifications](https://console.cloud.google.com/monitoring/alerting/notifications)
   section on the Google Cloud Console.
1. Choose the type of channel you want to use and click on `ADD NEW`
1. Follow the instructions on the screen.
1. Once it is set up, click on clip icon next to the channel to copy the link
   to it. You will need this link on the next section to add the channel
   to your OpenTofu configuration.
