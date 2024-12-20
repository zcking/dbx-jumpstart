resource "databricks_pipeline" "this" {
  name                  = var.name
  allow_duplicate_names = false
  catalog               = var.catalog
  development           = var.development
  channel               = var.channel
  edition               = var.edition
  target                = var.schema
  photon                = var.photon_enabled
  continuous            = var.continuous
  configuration         = var.parameters

  library {
    file {
      path = var.notebook_path
    }
  }

  # TODO: add support for extra `library { }` blocks to support dependencies

  cluster {
    label = "default"
    custom_tags = merge(var.tags, {
      DeployedBy   = "Terraform"
      cluster_type = "default"
    })
    autoscale {
      mode        = "ENHANCED"
      min_workers = var.min_workers
      max_workers = var.max_workers
    }
    node_type_id = var.node_type_id
  }

  cluster {
    label = "maintenance"
    custom_tags = merge(var.tags, {
      DeployedBy   = "Terraform"
      cluster_type = "maintenance"
    })
    num_workers = 1
  }

  dynamic "notification" {
    for_each = var.notifications
    content {
      email_recipients = notification.value.email_recipients
      alerts           = notification.value.alerts
    }
  }
}