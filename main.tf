
provider "google" {
  credentials = file("credentials.json")
  project = "cs-tmpl-test"
  region  = "us-central1"
  zone    = "us-central1-a"
}


resource "google_cloud_run_service" "default"  {
  name     = "terraform-demo-master"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/cs-tmpl-test/terraform-demo-master:latest"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}