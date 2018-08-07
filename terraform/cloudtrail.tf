locals {
  cloudtrail_s3_bucket_name = "my-cloudtrail-bucket"
  cloudtrail_cloudwatchlog_name = "cloudtrail-cloudwatchlogs"
  cloudtrail_name = "cloudtrail"
  cloudtrail_iam_name_prefix = "CloudTrail_CloudWatchLogs"
}

# cloud watch logs
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name = "${local.cloudtrail_cloudwatchlog_name}"

  provisioner "local-exec" {
    command = "sleep 10"
  }

  tags = "${merge(
        var.common_tags,
        local.common_tags,
        map(
            "Name", "${local.cloudtrail_name}"
        )
    )}"
}

resource "aws_cloudwatch_log_stream" "cloudtrail" {
  name           = "CloudTrail_${local.region}"
  log_group_name = "${aws_cloudwatch_log_group.cloudtrail.name}"
}

# iam
resource "aws_iam_role" "cloudtrail" {
  name        = "${local.cloudtrail_iam_name_prefix}_Role"
  description = "Terraform managed. iam role for cloud trail send to cloud watch logs"
  depends_on  = ["aws_cloudwatch_log_stream.cloudtrail"]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "aws_iam_policy" "cloudtrail" {
  name = "${local.cloudtrail_iam_name_prefix}_Policy"
  path = "/"
  description = "Terraform Mamnaged. IAM Role Policy for CloudTrail Logging"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Sid": "AWSCloudTrailCreateLogStream20141101",
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogStream"
        ],
        "Resource": [
            "${replace(aws_cloudwatch_log_stream.cloudtrail.arn, aws_cloudwatch_log_stream.cloudtrail.name, data.aws_caller_identity.current.account_id)}_${aws_cloudwatch_log_stream.cloudtrail.name}*"
        ]
    },
    {
        "Sid": "AWSCloudTrailPutLogEvents20141101",
        "Effect": "Allow",
        "Action": [
            "logs:PutLogEvents"
        ],
        "Resource": [
            "${replace(aws_cloudwatch_log_stream.cloudtrail.arn, aws_cloudwatch_log_stream.cloudtrail.name, data.aws_caller_identity.current.account_id)}_${aws_cloudwatch_log_stream.cloudtrail.name}*"
        ]
    }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudtrail" {
    role       = "${aws_iam_role.cloudtrail.name}"
    policy_arn = "${aws_iam_policy.cloudtrail.arn}"
}

# s3
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${local.cloudtrail_s3_bucket_name}"
  acl           = "private"
  force_destroy = false

  tags = "${merge(
    var.common_tags,
    local.common_tags,
    map(
      "Name", "${local.cloudtrail_s3_bucket_name}"
    )
  )}"
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = "${aws_s3_bucket.cloudtrail.id}"
  depends_on = ["aws_s3_bucket.cloudtrail"]

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.cloudtrail.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/454939465870/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

# cloud trail
resource "aws_cloudtrail" "this" {
  name = "${local.cloudtrail_name}"

  depends_on = [
    "aws_s3_bucket.cloudtrail",
    "aws_s3_bucket_policy.cloudtrail",
    "aws_cloudwatch_log_group.cloudtrail",
    "aws_iam_role.cloudtrail",
  ]

  s3_bucket_name             = "${aws_s3_bucket.cloudtrail.id}"
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}"
  cloud_watch_logs_role_arn  = "${aws_iam_role.cloudtrail.arn}"

  enable_log_file_validation = true
  is_multi_region_trail      = true
  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }
  tags = "${merge(
    var.common_tags,
    local.common_tags,
    map(
      "Name", "${local.cloudtrail_name}"
    )
  )}"
}
