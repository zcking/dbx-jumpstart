variable "name" {
  type        = string
  description = "Name of the DLT pipeline"
}

variable "tags" {
  type        = map(string)
  description = "Extra tags"
  default     = {}
}

variable "parameters" {
  type        = map(string)
  description = "Key/value pairs of configuration to pass to the DLT Pipeline"
  default     = {}
}

variable "catalog" {
  type        = string
  description = "Catalog that tables will be managed in"
  default     = "main"
}

variable "schema" {
  type        = string
  description = "Target schema to create tables in"
  default     = "default"
}

variable "development" {
  type        = bool
  description = "Run the pipeline in development mode or not"
  default     = false
}

variable "continuous" {
  type        = bool
  description = "Run the pipeline continuously or not"
  default     = false
}

variable "channel" {
  type        = string
  description = "DLT Release channel (current or preview)"
  default     = "current"
  validation {
    condition     = contains(["current", "preview"], var.channel)
    error_message = "channel must be one of [current, preview]"
  }
}

variable "edition" {
  type        = string
  description = "DLT product edition (core, pro, advanced)"
  default     = "advanced"
  validation {
    condition     = contains(["core", "pro", "advanced"], var.edition)
    error_message = "edition must be one of [core, pro, advanced]"
  }
}

variable "photon_enabled" {
  type        = bool
  description = "Enable Photon engine for optimized performance"
  default     = true
}

variable "min_workers" {
  type        = number
  description = "Autoscaling minimum number of workers"
  default     = 1
  validation {
    condition     = var.min_workers >= 0
    error_message = "Minimum workers must be an integer >= 0"
  }
}

variable "max_workers" {
  type        = number
  description = "Autoscaling maximum number of workers"
  default     = 3
}

variable "node_type_id" {
  type        = string
  description = "Node/VM instance type supported by Databricks"
  default     = "i3.xlarge"
}

variable "read_access_groups" {
  type        = list(string)
  description = "Access control list of Groups with read access"
  default     = ["users"]
}

variable "manage_access_groups" {
  type        = list(string)
  description = "Access control list of Groups with CAN_MANAGE access"
  default     = []
}

variable "notebook_path" {
  type        = string
  description = "Path to the Notebook serving as entrypoint for the pipeline if not using the git configurations."
}

variable "git_url" {
  type        = string
  description = "The URL of the Git repository to clone for notebook. Set to `null` to skip Git Repo setup."
}

variable "git_provider" {
  type        = string
  description = "Git provider for the repo at `git_url`"
  default     = "gitHub"
  validation {
    condition = contains([
      "gitHub", "gitHubEnterprise",
      "bitbucketCloud", "bitbucketServer",
      "azureDevOpsServices",
      "gitLab", "gitLabEnterpriseEdition",
      "awsCodeCommit"
    ], var.git_provider)
    error_message = "Git provider not supported"
  }
}

variable "git_branch" {
  type        = string
  description = "Git branch to checkout in the initial repo clone"
  default     = "main"
}

variable "git_tag" {
  type        = string
  description = "Git tag to checkout in the initial repo clone"
  default     = null
}

variable "notifications" {
  type = list(object({
    email_recipients = list(string)
    alerts           = list(string)
  }))
  description = "List of alert notification configurations. Supported alerts are [on-update-failure, on-update-success, on-update-fatal-failure, on-flow-failure]"
  default     = []
}