# Bucket to store website
resource "google_storage_bucket" "website" {
  provider = google
  name     = "coffeetime-website"
  location = "US"
}