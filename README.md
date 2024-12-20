# Databricks Jumpstarter

This is an internal command-line tool for automating a Databricks platform setup
using Terraform and templates that can be extended for future playbooks.

![Jumpstart Demo](https://make-with-data-assets.s3.us-east-1.amazonaws.com/jumpstart_demo.gif)

## Setup

Create a new virtual environment for this Python project with `pipenv` or `virtualenv`:  

```shell
pipenv --python 3.9
```

Then anytime you wish to start working on the project, run `pipenv shell` to activate the environment. 

Install dependencies with `pipenv install --dev`. If you need to add a new dependency to the project, run `pipenv install <library>` and if the library is only for development/testing then you should include the `--dev` flag to mark it as a development dependency: `pipenv install --dev pytest`.

## Usage

To use the jumpstarter to generate a new project, run `python app.py` and follow the prompts.

The first thing the tool will ask you for is a project name. You should give this a value representing your name or company name. All the generated code/configuration will be rendered in a new folder matching this name.

After you complete the prompts, the folder will be created and all configurations generated within. A `settings.json` file will also be created in this folder, so should you need to reproduce this exact jumpstart spec, you can optionally pass this JSON file to the app, like so: `python app.py settings.json`.

## Walkthrough

If you read nothing else, please read this. This section details a play by play recipe of how to use this jumpstart tool to actually onboard.

> As of the time of this writing, this jumpstarter only supports AWS.

### Step 1: Sign up for Databricks on AWS Marketplace

The easiest way to sign up and manage billing for a Databricks account on AWS is to use the AWS Marketplace. 

With this route, the you can follow the instructions on the marketplace: https://aws.amazon.com/marketplace/pp/prodview-wtyi5lgtce6n6 

**Important:** Just make sure that when prompted, **skip** the option of using the CloudFormation template to deploy your workspace. That option is very basic and does not provide any standards or best practices such as workspace topology, customer managed keys, etc.

After this is done, you should be able to login to the databricks *account* console at https://accounts.cloud.databricks.com


### Step 2: Create a Service Principal for Terraform

1. Go to https://accounts.cloud.databricks.com/users/serviceprincipals/add
2. Enter the service principal name: `terraform` and click "Add"
3. Go back to [Service principals](https://accounts.cloud.databricks.com/users/serviceprincipals)
4. Click the `terraform` service principal you just created
5. Click the "Roles" tab
6. Toggle "Account admin"
7. Go back and Click the `terraform` service principal once again
8. Under "OAuth secrets" click "Generate secret". Take note of the client ID and secret shown here. They will not be shown again after you click away.

### Step 6: Configure your Databricks CLI

Now you must configure your databricks CLI. Make sure you have the databricks CLI installed and up-to-date:  

```shell
brew tap databricks/tap
brew install databricks
```

You must configure a profile with the same name as you did the AWS CLI earlier (`<profile>` e.g. `databricks`). 

To do this, open or create the file `~/.databrickscfg` and paste the following contents:  

```ini
[<profile>]
account_id = <databricks_account_id>
host  = https://accounts.cloud.databricks.com
client_id = <oauth_client_id>
client_secret = <oauth_secret>
```

The `<` and `>` symbols are not part of the real value. 

To verify this setup is correct, run:  

```shell
databricks --profile <profile> account users list
```

This should list the users on the account if successful.

### Step 7: Jumpstart!

All the prerequisite setup is done, you're ready to execute the jumpstart. Follow the instructions in the [Usage](#usage) section to execute the jumpstart program. When prompted for a project name, please use the same exact name as you've been using for `<profile>` so far. This will ensure all the profiles for AWS, Databricks, and Terraform align correctly.

## Tests

This repository uses `pytest` for Python testing framework. To run the tests simply run `pytest`.
