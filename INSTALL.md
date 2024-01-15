# Installation

## 1. Setup

Integrating these scripts into your repository is not difficult. You could either:

- add it as a submodule, which will use github's versioning, but does require everyone to _recursively_ pull your repository.
- simply use the [install.sh](./install.sh) script. This gives you the choice to install whatever module you wish to incorporate.

## 2. Configure

The modules require variables which you can configure in the [\_variables.sh](./_variables.sh) file. Simply copy and paste the content of the [.\_variables.sh.example](./._variables.sh.example)-file and change its values to your specific infrastructure.

## 3. Maintenance

Upgrading the modules (or adding new ones) can be done using the [updater.sh]()-file in the [.version](./.version)-folder. For more information, see the [README](./.version/README.md) inside that folder.
