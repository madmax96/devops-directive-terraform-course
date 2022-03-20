# Terraform Learning

## Basic commands

### `terraform init`

Used to initialize a working directory containing `.tf` files.
 - Downloads required providers.
 - Downloads and initialises modules (if any)

Should be rerun whenever `terraform` Block is changed.

### `terraform plan`

Purpose of this command is to print out detailed plan for provisioning desired infrastructure.

After first run of `apply` command terraform will create `terraform.tfstate` file which is a `json` file that contains entire state of all created resources(with all properties).
On all following runs terraform will first enter `Refreshing state...` phase for all resources that are in `terraform.tfstate`. The purpose of this is to check if some propery of some resource was maybe changed outside of terraform (terraform knows this by comparing resource properties from state file with the ones that are actually live on cloud). If there is some differences `tf` prints a Note. In this case the real value that is set on cloud for that propery will be used in printed out plan.

Based on results of `Refreshing state...` (a.k.a the state of resource live on cloud) and the current configuration of resources (the desired state) terraform will figure out what needs to be done and will print out full plan that consists of:
 - resources to add
 - resources to delete
 - resources to modify in-place
 - resources to replace (modify in-place is not possible  because of the cloud provider API)

If resource is renamed after first apply was done, on next apply terraform will plan that as deletion of resource with old name and creation of resource with new name (essentially it is an replacement).

### `terraform apply`

Provision the desired state of infrastructure.

First print out plan (using `terraform plan`) and then prompts user to enter `yes` to start the process.

Before terraform actually starts creating resources (with specified provider) it locks the state so no other processes can write to it. This is important in order to prevent multiple processes creating infrastructure elements and potentially collide with one another resulting in undesired state.

After the command finishes it prints out all output variables. At this point state file is updated so that it maches current infrastructure state. The state is also unlocked.

### `terraform validate`

Validates configuration files, HCL syntax, attribute names, value types, etc. Static checks only.

### `terraform destroy`

Prints out every resource that will be destroyed (after `Refreshing state...` of every resource), then prompts user for `yes` to start the process.

After process finishes state file is empty and every resource that was in the state (a.k.a that was managed by terraform) is gone from cloud.

## Terraform directoires and files

### `.terraform.tfstate`

Current infrastructure state of resources managed by terraform.

JSON file that contains all informations about provisioned resources.

Can be stored locally or remotely (recommended).

Remote backends enable storage of TF state in a remote location to enable secure collaboration.

### `.terraform.tfstate.lock.info`

Stores state locking metadata. The metadata contains the lock ID, which is required to unlock the state.

State is locked when apply/destroy starts and unlocked after command finishes.

### `.terraform.lock.hcl`

Contains specific providers (exact versions )that should be installed.

Message from `terraform init`: "Terraform has created a lock file `.terraform.lock.hcl` to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future."

### `.terraform`

Contains required providers binaries, required modules data, current worskpace info, etc... - data created and maintained by terraform internally.

## Modules

### Root Module - Root working directory.

### Child Module - Invoked from other modules with `module` block.

## Workspaces

Provide isolation of state. Usefull for deploying to multiple stages.

In config files we can use `terraform.workspace` to identify current workspace.

Terraform keeps current workspace in `.terraform/environment`

With remote backends in this case state is still stored in one place as a unit - directory `terraform.tfstate.d` with subdirectories for each workspace. Those subdirectories are containing `terraform.tfstate` file and lock file for that state.

## Terraform backends

Backend configuration is used to store state remotely and prevent collisions by utilising locking feature.

This is important to enable safe collaboration between multiple devs.

Secure information might be in the state file (passwords,credentials, etc...) so state file must be encrypted.

State file should also be versioned in order to have backup.

Most popular backend is `S3` for storage + `DynamoDB` for locking.

## Debugging terraform

`TF_LOG=DEBUG terraform <basic_command>`