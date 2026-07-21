resource "aws_kms_key" "vss" {
  tags                    = { name = var.name }
  description             = var.description

  deletion_window_in_days = var.days_before_delete
  enable_key_rotation     = var.enable_key_rotation

  multi_region            = var.multi_region

  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec

  policy                  = templatefile("${var.json_path}/${var.name}.json", {
                              account = "${var.accountID}"
                              region = "${var.region}"
                            })
}