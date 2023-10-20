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
- `iap.googleapis.com` (**Note**: Only if you want to activate IAP tunnel)

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

Activate IAP service (Optional)

```terminal
gcloud services enable iap.googleapis.com
```

The services should now been activated.

#### Setup Provider Authentication and Authorization - Service Account

Terraform and Ansible will use a Service Account to provision the platform
on your project. This account will have the minimum permissions necessary
for these tasks. To create one, follow these steps:

1. Access GCP's [Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) page.
1. Select the correct project in the dropdown at the top of the page.
1. Create an account with a descriptive name like `bap-sa`.
1. Assign the following IAM roles:
   - `Compute Admin`
   - `Storage Admin` (**Note**: not `Compute Storage Admin`)
   - `Service Account User`
   - `IAP Policy Admin` (**Note**: Only if you want to activate IAP tunnel)

Once the account has been created, you will need to create a key file:

1. Access the service accounts details by clicking over it on the accounts
   listing page.
1. Go to the `Keys` tab.
1. Click on `Add Key` > `Create new key`.
1. Select `JSON` format.
1. Click `Create` to download the key.
1. Rename the file to a more descriptive name such as
   `bap-sa-keys-<project-name>.json` (e.g. bap-sa-keys-myproject.json).

Keep this file safe for now. You will need it when you run Terraform and Ansible
later.

#### Setup SSH Authentication - OS Login

Terraform and Ansible will use SSH to create virtual machines and to provision
other resources. In the case of GCP, you will need to enable
[OS Login](https://cloud.google.com/compute/docs/oslogin) to activate
SSH access.

First of all, you will need to generate a SSH key pair. If you don't know how
to do it, we recommend to follow the steps described on the
[GitLab documentation](https://docs.gitlab.com/ee/user/ssh.html#generate-an-ssh-key-pair).

After it, follow the next steps on the Cloud Shell.

1. Copy the contents of the SSH keys and the keys created for the service account
   on the Cloud Shell (e.g. `<SSH key>.pub` and `bap-sa-keys-<project-name>.json`).
1. Activate OS Login for the project.

   ```terminal
   gcloud compute project-info add-metadata --metadata enable-oslogin=TRUE
   ```

1. Login as the Service Account user via its key copied in the previous step.

   ```terminal
   gcloud auth activate-service-account --key-file=bap-sa-keys-<project-name>.json
   ```

1. Add the project's public SSH key to the account

   :information_source:&nbsp;  This command will output the SSH Username
   for the Service Account, typically in the format of `sa_<ID>`.
   Jot down this username for later. It will be used in the Ansible
   configuration.

   ```terminal
   gcloud compute os-login ssh-keys add --key-file=<SSH key>.pub
   ```

1. Switch back your logged in account in Cloud Shell to your regular account
   using your email address.

   ```terminal
   gcloud config set account <account-email-address>
   ```

SSH access should now be enabled on the Service Account and this will be used
by Ansible to SSH login to each VM.

#### Setup Terraform State Storage Bucket - GCP Cloud Storage

Terraform state will be stored on a GCP bucket. For the bucket you will
need a unique name such as `<project-name>-terraform-state`
(e.g. `myproject-terraform-state`) and a
[bucket storage location](https://cloud.google.com/storage/docs/locations).

Then, run this command from the Cloud Shell machine terminal:

```terminal
gsutil mb -l <bucket_location> gs://<project-name>-get-terraform-state
```

For example:

```terminal
gsutil mb -l EUROPE-SOUTHWEST1 gs://bap-terraform-state
```

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
       --scopes=cloud-platform \
       --tags=control
   ```

1. To log in, go to `Compute Engine` > `VM instances` ([link](https://console.cloud.google.com/compute/instances))
   and open a SSH terminal on the control node by clicking on the `SSH`
   button of `control-node` entry.

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
