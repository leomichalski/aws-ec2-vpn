resource "aws_iam_policy" "basic_policy" {
  name        = "basic_policy"
  path        = var.policies_path

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:GetCallerIdentity"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    ProjectTag = var.project_tag
  }
}

resource "aws_iam_group_policy_attachment" "attach_basic_policy" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.basic_policy.arn
}

// Create
resource "aws_iam_policy" "create_policy" {
  name        = "create_policy"
  path        = var.policies_path

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateKeyPair",
          "ec2:CreateVpc",
          "ec2:CreateSubnet",
          "ec2:CreateInternetGateway",
          "ec2:CreateRoute",
          "ec2:CreateRouteTable",
          "ec2:CreateLocalGatewayRouteTableVpcAssociation",
          "ec2:CreateSecurityGroup",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateReplaceRootVolumeTask",
          "ec2:CreateTags",
          "ec2:AllocateAddress"
        ]
        "Resource" : "*"
      }
    ]
  })

  tags = {
    ProjectTag = var.project_tag
  }
}

resource "aws_iam_group_policy_attachment" "attach_create_policy" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.create_policy.arn
}

// Read
resource "aws_iam_policy" "read_policy" {
  name        = "read_policy"
  path        = var.policies_path

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:ImportKeyPair",
          "ec2:DescribeReplaceRootVolumeTasks",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeInstanceCreditSpecifications",
          "ec2:DescribeImages",
          "ec2:DescribeVolumes",
          "ec2:DescribeSubnets",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules",
          "ec2:DescribeRouteTables",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeImportImageTasks",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeTags",
          "ec2:DescribeAddresses"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    ProjectTag = var.project_tag
  }
}

resource "aws_iam_group_policy_attachment" "read_policy" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.read_policy.arn
}

// Update
resource "aws_iam_policy" "update_policy" {
  name        = "update_policy"
  path        = var.policies_path

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:ModifyVpc*",
          "ec2:ModifySubnetAttribute",
          "ec2:ModifyLocalGatewayRoute",
          "ec2:ModifySecurityGroupRules",
          "ec2:ModifyVolumeAttribute",
          "ec2:ModifyAvailabilityZoneGroup",
          "ec2:ReplaceRouteTableAssociation",
          "ec2:AttachInternetGateway",
          "ec2:AssociateAddress"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    ProjectTag = var.project_tag
  }
}

resource "aws_iam_group_policy_attachment" "update_policy" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.update_policy.arn
}

// Delete
resource "aws_iam_policy" "delete_policy" {
  name        = "delete_policy"
  path        = var.policies_path

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DeleteKeyPair",
          "ec2:DeleteVpc",
          "ec2:DeleteSubnet",
          "ec2:DeleteInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DeleteRouteTable",
          "ec2:DeleteLocalGatewayRouteTableVpcAssociation",
          "ec2:DeleteSecurityGroup",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:ReleaseAddress"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    ProjectTag = var.project_tag
  }
}

resource "aws_iam_group_policy_attachment" "attach_delete_policy" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.delete_policy.arn
}

resource "aws_iam_policy" "instance_policy" {
  name        = "instance_policy"
  path        = var.policies_path

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:ResetInstanceAttribute",
          "ec2:ModifyInstanceAttribute",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:RebootInstances"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    ProjectTag = var.project_tag
  }
}

resource "aws_iam_group_policy_attachment" "attach_instance_policy" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.instance_policy.arn
}

// Necessary for acessing the terraform backend
resource "aws_iam_policy" "terraform_backend_access" {
  name        = "terraform_backend_access"
  path        = var.policies_path

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
        ]
        "Resource" : [
          "*"
          # // TODO: only allow actions on a specific dynamodb table
          # "arn:aws:dynamodb:*:*:table/*",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        "Resource" : [
          "*"
          # // TODO: only allow actions on a specific s3 bucket
          # "arn:aws:s3:::*"
        ]
      }
    ]
  })

  tags = {
    ProjectTag = var.project_tag
  }
}

resource "aws_iam_group_policy_attachment" "attach_terraform_backend_access" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.terraform_backend_access.arn
}

