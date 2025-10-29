locals {
  trust_policies = {
    "CROSSACCOUNT"              = data.aws_iam_policy_document.cross_account.json,
    "EXOCOMPUTE_EKS_LAMBDA"     = data.aws_iam_policy_document.eks_lambda.json,
    "EXOCOMPUTE_EKS_MASTERNODE" = data.aws_iam_policy_document.eks_master_node.json,
    "EXOCOMPUTE_EKS_WORKERNODE" = data.aws_iam_policy_document.eks_worker_node.json,
  }
}

data "aws_iam_policy_document" "cross_account" {
  override_policy_documents = [
    data.aws_iam_policy_document.rsc_user.json
  ]

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "backup.amazonaws.com",
      ]
    }
  }

  version = "2012-10-17"
}

data "aws_iam_policy_document" "eks_lambda" {
  override_policy_documents = [
    data.aws_iam_policy_document.rsc_user.json
  ]

  statement {
    sid    = "LambdaAssumeRolePolicyDocumentSid"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }

  version = "2012-10-17"
}

data "aws_iam_policy_document" "eks_master_node" {
  statement {
    sid    = "ClusterAssumeRolePolicyDocumentSid"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com",
      ]
    }
  }

  version = "2012-10-17"
}

data "aws_iam_policy_document" "eks_worker_node" {
  statement {
    sid    = "WorkerNodeAssumeRolePolicyDocumentSid"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }

  version = "2012-10-17"
}

data "aws_iam_policy_document" "rsc_user" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"
      identifiers = [
        var.rsc_user_arn,
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        var.external_id,
      ]
    }
  }

  version = "2012-10-17"
}
