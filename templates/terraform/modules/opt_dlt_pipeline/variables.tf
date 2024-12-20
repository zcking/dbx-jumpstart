variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

variable "min_workers" {
  type        = number
  description = "Minimum number of workers to use for the pipeline"
  default     = 1
}

variable "max_workers" {
  type        = number
  description = "Maximum number of workers to use for the pipeline"
  default     = 2
}

variable "cloud_files_format" {
  type        = string
  description = "Format of the cloud files to be loaded"
  default     = "json"
}

variable "cloud_files_path" {
  type        = string
  description = "Path to the raw files to be loaded from cloud storage"
  default     = "s3://mybucket/myfolder/"
}

variable "development" {
  type        = bool
  description = "Whether to use the development mode on the pipeline"
  default     = false
}