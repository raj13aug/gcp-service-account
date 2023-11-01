resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = var.description

  depends_on = [
    google_project_service.enabled_apis,
  ]
}

resource "google_project_iam_member" "sa_iam" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa.email}"

  depends_on = [
    google_project_service.enabled_apis,
  ]
}

resource "google_service_account_key" "gcp_tests" {
  service_account_id = google_service_account.sa.name
}

resource "local_file" "gcp_tests_store" {
  content  = base64decode(google_service_account_key.gcp_tests.private_key)
  filename = "${path.module}/tester.json"
}