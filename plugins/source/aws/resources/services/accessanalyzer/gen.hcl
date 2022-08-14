service          = "aws"
output_directory = "."
add_generate     = true

description_modifier "remove_read_only" {
  words = ["  This member is required."]
}

resource "aws" "access_analyzer" "analyzers" {
  path = "github.com/aws/aws-sdk-go-v2/service/accessanalyzer/types.AnalyzerSummary"
  ignoreError "IgnoreAccessDenied" {
    path = "github.com/cloudquery/cloudquery/plugins/source/aws/client.IgnoreCommonErrors"
  }
  multiplex "AwsAccount" {
    path   = "github.com/cloudquery/cloudquery/plugins/source/aws/client.ServiceAccountRegionMultiplexer"
    params = ["access-analyzer"]
  }
  deleteFilter "AccountRegionFilter" {
    path = "github.com/cloudquery/cloudquery/plugins/source/aws/client.DeleteAccountRegionFilter"
  }
  userDefinedColumn "account_id" {
    type        = "string"
    description = "The AWS Account ID of the resource."
    resolver "resolveAWSAccount" {
      path = "github.com/cloudquery/cloudquery/plugins/source/aws/client.ResolveAWSAccount"
    }
  }
  userDefinedColumn "region" {
    type        = "string"
    description = "The AWS Region of the resource."
    resolver "resolveAWSRegion" {
      path = "github.com/cloudquery/cloudquery/plugins/source/aws/client.ResolveAWSRegion"
    }
  }

  options {
    primary_keys = ["arn"]
  }

  column "tags" {
    // TypeJson
    type = "json"
  }

  user_relation "aws" "access_analyzer" "findings" {
    path = "github.com/aws/aws-sdk-go-v2/service/accessanalyzer/types.FindingSummary"
  }

  user_relation "aws" "access_analyzer" "archive_rules" {
    path = "github.com/aws/aws-sdk-go-v2/service/accessanalyzer/types.ArchiveRuleSummary"
  }
}
