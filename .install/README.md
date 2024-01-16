# Installation

## 1. Setup

Integrating these scripts into your repository is not difficult. You could either:

- Git clone or add it as a submodule; which will use github's versioning, but does mean you pull everything which may cause cluttering and confusion to those using the scripts. Submodules also require everyone to _recursively_ pull your repository.
- If you prefer to not include this as a repository and only add the scripts you find of use, then simply use the [install.sh](./install.sh) script. This gives you the choice to install whatever module you wish to incorporate and only imports the necessary files. The script will default to the main branch, but this can be changed.

## 2. Configure

The modules require variables which you can configure in the [\_variables.sh](../_variables.sh) file. Simply copy and paste the content of the [\_variables.sh.example](./_variables.sh.example)-file and change its values to your specific infrastructure.

### [\_variables.sh.example](./_variables.sh.example)

This is an example file for the _\_variables.sh_ file, which holds all the repository-specific variables shared with most of the scripts. This makes it easier to adjust the chain-id, binary name or node directory without having to change it in a lot of different files. This file is expected to be present in the root-folder (of this repository). Using the [install.sh](./install.sh) script will automatically generate one for you, just make sure to adapt the file afterwards.

## 3. Maintenance

Upgrading the modules (or adding new ones) can be done using the [update.sh](./.version/update.sh)-file in the [.version](./.version)-folder.

### [.versionmap](../.version/.versionmap)

This shows which versions for each module is currently installed.

### [update.sh](../.version/update.sh)

This script can be used to update all the utilities. This also asks whether you'd want to include some modules and which you do not want. The versions for every module installed can be found in the [.versionmap](../.version/.versionmap) file.

> [!CAUTION]
> This does overwrite all the README.md files.
