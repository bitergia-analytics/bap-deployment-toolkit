resource "random_id" "backups_assets_bucket_id" {
  prefix      = "${var.prefix}-bap-backups-"
  byte_length = 8
}

resource "aws_s3_bucket" "backups_assets" {
  bucket = random_id.backups_assets_bucket_id.hex

  tags = merge(
    {
      Role   = "backups-assets"
      Custom = var.custom_tags
    }
  )
  force_destroy = true
}

resource "random_id" "sortinghat_assets_bucket_id" {
  prefix      = "${var.prefix}-bap-sortinghat-"
  byte_length = 8
}

resource "aws_s3_bucket" "sortinghat_assets" {
  bucket = random_id.sortinghat_assets_bucket_id.hex

  tags = merge(
    {
      Role   = "sortinghat-assets"
      Custom = var.custom_tags
    }
  )
  force_destroy = true
}
