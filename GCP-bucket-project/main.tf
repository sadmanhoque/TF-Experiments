resource "google_storage_bucket" "auto-expire" {
  name          = "no-public-access-bucket-sadman"
  location      = "US"
  force_destroy = true

  public_access_prevention = "enforced"
}