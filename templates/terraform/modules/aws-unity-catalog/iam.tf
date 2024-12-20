# This is the IAM trust policy that allows Databricks Unity Catalog
# to assume the cross-account role in our AWS account
# and access the data storage bucket for the metastore.
data "aws_iam_policy_document" "passrole_for_uc" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [
        "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
      ]
      type = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
  statement {
    sid     = "ExplicitSelfRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${var.aws_account_id}:role/${var.name}-uc-access"]
    }
  }
}

#trivy:ignore:avd-aws-0057
resource "aws_iam_policy" "unity_metastore" {
  name = "${var.name}-unity-catalog-metastore-access-iam-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.name}-databricks-unity-metastore"
    Statement = [
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          aws_s3_bucket.metastore.arn,
          "${aws_s3_bucket.metastore.arn}/*"
        ],
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ],
        "Resource" : [
          "${aws_kms_key.metastore.arn}"
        ],
        "Effect" : "Allow"
      }
    ]
  })
  tags = merge(var.tags, {
    Name = "${var.name}-unity-catalog IAM policy"
  })
}

// Required, in case https://docs.databricks.com/data/databricks-datasets.html are needed
resource "aws_iam_policy" "sample_data" {
  name = "${var.name}-unity-catalog-sample-data-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.name}-databricks-sample-data"
    Statement = [
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "arn:aws:s3:::databricks-datasets-oregon/*",
          "arn:aws:s3:::databricks-datasets-oregon"

        ],
        "Effect" : "Allow"
      }
    ]
  })
  tags = merge(var.tags, {
    Name = "${var.name}-unity-catalog IAM policy"
  })
}

resource "aws_iam_role" "metastore_data_access" {
  name                = "${var.name}-uc-access"
  assume_role_policy  = data.aws_iam_policy_document.passrole_for_uc.json
  managed_policy_arns = [aws_iam_policy.unity_metastore.arn, aws_iam_policy.sample_data.arn]
  tags = merge(var.tags, {
    Name = "${var.name}-unity-catalog IAM role"
  })
}