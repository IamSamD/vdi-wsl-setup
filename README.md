# VDI WSL Setup

A set of scripts for exporting, importing and configuring WSL distributions for a multi-user VDI

We have the need to set up WSL on a multi-user VDI. 

To acheive this we create a 'main' distribution which we configure with the initial sudo user.

We export the main distribution for each user that needs one. 

The distribution name should be the same as the user that will use it. 

We then import each distribution, one per user and run a script via WSL to set up the user in their distro

If a user is as admin and should have sudo on their distribution, you can add them to the `sudousers` list in the config file. 

Each script reads the same config file so you only have to specify your config once to run all scripts. 

## Config File

You can set all variables in **config.yaml**

``` yaml
seeddistro:
  name: Ubuntu-20.04
  exportpath: C:\wsl-distros
distros:
  - distro1
  - distro2
sudousers:
  - user1
  - distro2
```

`seeddistro.name`

The name of the WSL distribution you wish to export.

`seeddistro.exportpath`

The folder you wish to export the distribution to.

`distros`

List of names representing the distributions you wish to create.
Usually the same as the user who will be using the distribution.

`sudousers`

List of users who should be in the sudo group on their own distribution.

## Usage

- Set up your config file with the desired values
- Run the scripts in the following order

``` powershell
.\Invoke-ExportDistros.ps1
```

``` powershell
.\Invoke-ImportDistros.ps1
```

``` powershell
.\Invoke-WslSetup.ps1
```