# VDI WSL Setup

A set of scripts for exporting, importing and configuring WSL distributions for a multi-user VDI

We have the need to set up WSL on a multi-user VDI. 

To acheive this we create a 'main' distribution which we configure with the initial sudo user.

We export the main distribution. 

Each user can then run the scripts under their own account on the VDI to set up their own WSL distribution. 

If a user is as admin and should have sudo on their distribution, you can add them to the `sudousers` list in the `user.yaml` file. 

Each script reads the same config file so you only have to specify your config once to run all scripts. 

## Config Files

There are two config files. `config.yaml` & `user.yaml`

## `config.yaml` defines the base config and should not often need to be amended. 

You can set base config used by the Export and Import scripts in **config.yaml**

``` yaml
export:
  seeddistro: Ubuntu-20.04
  exportpath: C:\wsl-distros
import:
  installlocation: C:\install-location
```

`export.seeddistro`

The name of the WSL distribution you wish to export.

`export.exportpath`

The folder you wish to export the distribution to.

`import.installlocation`

The Windows folder in which the imported distributions should be installed.

## `user.yaml` is used to specify config for your own WSL Distro

```yaml
distros:
  - name: distro1
    pod: uk
sudousers:
  - distro1
```

`distros`

List of names representing the distributions you wish to create.
Usually the same as the user who will be using the distribution.

`sudousers`

List of users who should be in the sudo group on their own distribution.

## Usage Instructions

On the VDI we have a WSL Ubuntu distribution `Ubuntu-24.04`
This is the 'main' distribution that is effectively our 'master image' for WSL.

We configure this distribution with any tools that should be installed globally for all users (kubectl, k9s, pwsh, etc)
This distro has the payuk-ubuntu user which has sudo access and is the admin account. 

We then export this main distribution and import and instance of it for each user that needs one.

We then run scripts on each users instance for setting up the user account with a random temp password and the local tools like tfenv, nvm and chezmoi. 

After the main image has been configured the process of exporting the image, creating distros for each user and setting up those distros is all automated with scripts. 

Once you are happy with the main image the process is as follows:

Repo Location:
The repo should be cloned to C:\

If the repo is already there, cd into it and perform a git pull.

If the repo is not already there, cd into C:\ and perform `git clone https://github.com/IamSamD/vdi-wsl-setup.git`

Once the repo is there and up to date:

- Set up your `user.yaml` file with the desired values
- Run the scripts in the following order

Check if there is already an export of the main distro, this will be called `main-distro.tar`.  If there is not already a main distro available:
``` powershell
.\Invoke-ExportDistros.ps1
```

Import a distro for each user that needs one
``` powershell
.\Invoke-ImportDistros.ps1
```

Set up the users on each distro
``` powershell
.\Invoke-WslSetupUsers.ps1
```

Set up local software for each distro
``` powershell
.\Invoke-WslSetupSoftware.ps1
```

There is a [runbook for setting up your WSL distro](https://dev.azure.com/PayUK/Pay.UK%20API%20Platform/_wiki/wikis/Pay.UK-API-Platform.wiki/892/0037-WSL-Distribution-Setup)
Please refer to that for full instructions on how to set up your own WSL distro on the VDI