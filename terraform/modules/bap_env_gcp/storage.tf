resource "random_id" "backups_assets_bucket_id" {
  prefix      = "bap-backups-"
  byte_length = 8
}

resource "google_storage_bucket" "backups_assets" {
  name         = random_id.backups_assets_bucket_id.hex
  location     = var.backups_storage_location

  uniform_bucket_level_access = false
  force_destroy = true
}

resource "random_id" "sortinghat_assets_bucket_id" {
  prefix      = "bap-sortinghat-"
  byte_length = 8
}

resource "google_storage_bucket" "sortinghat_assets" {
  name         = random_id.sortinghat_assets_bucket_id.hex
  location     = var.sortinghat_storage_location

  uniform_bucket_level_access = false
  force_destroy = true
}

