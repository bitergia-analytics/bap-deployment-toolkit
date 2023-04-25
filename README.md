# BAP Deployment Toolkit

This repository provides a set of tools to deploy instances of
[Bitergia Analytics Platform](https://github.com/bitergia-analytics/)
on different cloud providers, using [Terraform](https://www.terraform.io/)
and [Ansible](https://www.ansible.com/) for provisioning and installation.

The latest version of the toolkit supports the following cloud providers:

- [Google Cloud Platform](https://cloud.google.com/gcp)

This toolkit is released under the terms of the [GPL3 or later license](LICENSE).

## Requirements

The current version of the toolkit requires:

- Debian 11 (bullseye) or Ubuntu 20.04 (or later).
- Python 3.8 (or later)
- Terraform 1.3 (or later)
- Ansible 6.4 (or later)

Take into account that other Linux distributions might work but the ones listed
in this README file are the ones that have been used to test this particular toolkit.
For your convenience, this documentation contains also the steps necessary
to install Terraform and Ansible.

## Structure of this repository

The `terraform` directory stores the modules needed for the provisioning of our platform
on the cloud providers supported by this deployment toolkit. Inside, you can find an
`environments` directory where you can store different configurations
for the environments you would like to have the provisioning in.

The `ansible` directory contains all the Ansible roles and playbooks to install
and configure the platform. As the `terraform` dir, it has an `environments`
folder to store the Ansible configurations for all your environments.

The `keys` directory provides a central place to store all of your keys. It is
configured in `.gitignore` so that the keys are not included with any Git commit by default,
to avoid exposing credentials.

The `docs` directory provides the documentation files that will help you to
deploy and configure the platform.

## Contents of the documentation

1. [Architecture Overview](docs/architecture_overview.md)
1. [Prerequisites](docs/prerequisites.md)
1. [Provisioning with Terraform](docs/provision.md)
1. [Deploying and configuring with Ansible](docs/deployment_and_config.md)

## Acknowledgement

This toolkit was inspired by the roles and recipes that
[Ángel Jara](https://github.com/ajaragz) developed when he worked at Bitergia
and by the amazing job the people of GitLab do with their
[GitLab Environment Toolkit](https://gitlab.com/gitlab-org/gitlab-environment-toolkit).

## License

This toolkit is released under the terms of the [GPL3 or later license](LICENSE).
