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

locals {
  full_name      = "slo-${var.config.service_name}-${var.config.feature_name}-${var.config.slo_name}"
  pubsub_configs = [for e in var.config.exporters : e if lower(e.class) == "pubsub"]
}

resource "google_service_account" "main" {
  account_id   = local.full_name
  project      = var.project_id
  display_name = "Service account for SLO computations"
}

resource "google_project_iam_member" "stackdriver" {
  count   = var.config.backend.class == "Stackdriver" ? 1 : 0
  project = var.config.backend.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.main.email}"
}

resource "google_pubsub_topic_iam_member" "pubsub" {
  count   = length(local.pubsub_configs)
  topic   = local.pubsub_configs[count.index].topic_name
  project = local.pubsub_configs[count.index].project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.main.email}"
}

resource "local_file" "slo" {
  content  = jsonencode(var.config)
  filename = "${path.module}/code/slo_config.json"
}

resource "local_file" "error_budget_policy" {
  content  = jsonencode(var.error_budget_policy)
  filename = "${path.module}/code/error_budget_policy.json"
}

module "slo-cloud-function" {
  source                                = "github.com/terraform-google-modules/terraform-google-scheduled-function"
  project_id                            = var.project_id
  region                                = var.region
  job_schedule                          = var.schedule
  job_name                              = local.full_name
  topic_name                            = local.full_name
  bucket_name                           = local.full_name
  function_name                         = local.full_name
  function_description                  = var.config.slo_description
  function_entry_point                  = "main"
  function_source_directory             = "${path.module}/code"
  function_available_memory_mb          = 128
  function_runtime                      = "python37"
  function_source_archive_bucket_labels = var.labels
  function_service_account_email        = google_service_account.main.email
  function_labels                       = var.labels
}