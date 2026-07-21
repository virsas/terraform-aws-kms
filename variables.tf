variable "json_path" {
  description           = "By default the json files are located in ./json/kms directory with names *NAME*.json."
  type                  = string
  default               = "./json/kms"
}

variable "accountID" {
  description           = "The AWS account ID"
  type                  = string
}

variable "region" {
  description           = "The AWS region"
  type                  = string
}

variable "name" {
  description           = "Name of the KMS used by the tag and json file"
  type                  = string
}

variable "description" {
  description           = "Description for the key"
  type                  = string
}

variable "days_before_delete" {
  description           = "The waiting period before the key is deleted in number of days. Must be from 7 to 30 days. By default it is 7 days."
  type                  = number
  default               = 7
}

variable "enable_key_rotation" {
  description           = "Enable / Disable key rotation. By default it is enabled and for security reasons it should stay that way,"
  type                  = bool
  default               = true
}

variable "multi_region" {
  description           = "Enable / Disable multi region keys. By default it is disabled"
  type                  = bool
  default               = false
}

variable "key_usage" {
  type        = string
  description = "Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
  default     = "ENCRYPT_DECRYPT"

  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "The key_usage variable must be one of: ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
  }
}

variable "customer_master_key_spec" {
  type        = string
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair."
  default     = "SYMMETRIC_DEFAULT"

  validation {
    condition = contains([
      "SYMMETRIC_DEFAULT",
      "RSA_2048", "RSA_3072", "RSA_4096",
      "HMAC_224", "HMAC_256", "HMAC_384", "HMAC_512",
      "ECC_NIST_P256", "ECC_NIST_P384", "ECC_NIST_P521", "ECC_SECG_P256K1",
      "ML_DSA_44", "ML_DSA_65", "ML_DSA_87",
      "SM2", "ECC_NIST_EDWARDS25519"
    ], var.customer_master_key_spec)
    error_message = "The customer_master_key_spec variable must be a valid AWS KMS key spec (e.g., SYMMETRIC_DEFAULT, ECC_NIST_P256, RSA_4096)."
  }
}