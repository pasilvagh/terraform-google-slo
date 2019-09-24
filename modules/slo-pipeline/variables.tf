/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "Project id to create SLO infrastructure"
}

variable "bucket_name" {
  description = "Name of the bucket to create"
}

variable "exporters" {
  description = "SLO export destinations config"
  type        = "list"

  # wait on https://github.com/hashicorp/terraform/issues/22449 to be merged
  # type = list(object({
  #   class = string
  #   project_id = string
  #   dataset_id = string
  #   table_id = string
  #   topic_name = string
  # }))
}

variable "pubsub_topic_name" {
  description = "Pub/Sub topic name"
  default     = "slo-export-topic"
}

variable "function_name" {
  description = "Cloud Function name"
  default     = "slo-exporter"
}

variable "function_memory" {
  description = "Memory in MB for the Cloud Function (increases with no. of SLOs)"
  default     = 128
}

variable "region" {
  description = "Region for the App Engine app"
  default     = "us-east1"
}

variable "service_account_name" {
  description = "Name of the service account to create"
  default     = "slo-exporter"
}