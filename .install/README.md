# Installation

## 1. Setup

Integrating these scripts into your repository is not difficult. You could either:

- Use the [installer.sh](./installer.sh) script; this should be done if you prefer not to include this as a repository and only add the scripts you find of use. Do this by placing it inside of an empty folder (for instance a _/utils_-folder) and run it. This gives you the choice to install whatever module you wish to incorporate and only imports the necessary files. The script will default to the `main` branch, but this can be changed.
 ```
  wget https://raw.githubusercontent.com/zenodeapp/cosmos-utils/main/.install/installer.sh
  ```
- Git clone or add it as a submodule; which will use github's versioning, but does mean you pull everything which may cause cluttering and confusion to those using the scripts. Submodules also require everyone to _recursively_ pull your repository.

## 2. Configure

### [\_variables.sh](../_variables.sh)

The modules require variables which you can configure in the [\_variables.sh](../_variables.sh) file. This makes it easier to adjust the chain-id, binary name or node directory without having to change it in a lot of different files. This file is expected to be present in the root-folder (of this repository). Using the [installer.sh](./installer.sh) script will automatically generate one for you, just make sure to change its values to your specific infrastructure.

### [\_variables.sh.example](./_variables.sh.example)

This is an example file for the _\_variables.sh_ file.

## 3. Maintenance

### [updater.sh](./updater.sh)

Upgrading the modules (or adding new ones) can be done using the [updater.sh](./.version/updater.sh)-file in the [.install](./.install)-folder. This also asks whether you'd want to include some modules and which you do not want.

> [!CAUTION]
> This does overwrite all the README.md files.

### [.versionmap](./.versionmap)

This shows which versions for each module is currently installed.
