# Terraform AWS KMS Module

A Terraform module for managing [AWS Key Management Service](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) customer managed keys, with the key policy rendered from a local JSON template file and support for symmetric encryption, asymmetric signing, HMAC, and multi region keys.

## Features

- **Customer Managed Keys**: Creates a KMS key tagged with the module `name` and described by a free form description.
- **Templated Key Policy**: Renders the key policy from `<json_path>/<name>.json`, substituting the AWS account ID and region into the template.
- **Key Rotation**: Enables automatic annual key rotation by default.
- **Multi Region Keys**: Optionally creates a multi region primary key for cross region replication.
- **Key Usage & Spec**: Supports encryption, signing, and MAC keys through configurable `key_usage` and `customer_master_key_spec` values.
- **Deletion Window**: Configurable waiting period of 7 to 30 days before a scheduled key deletion completes.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

---

## Usage Examples

### Basic Example

Create a symmetric encryption key with the default 7 day deletion window and key rotation enabled.

The module always renders the key policy from a JSON template, so `./json/kms/vss-app.json` must exist. The template receives the `account` and `region` variables:

```json
{
  "Version": "2012-10-17",
  "Id": "vss-app",
  "Statement": [
    {
      "Sid": "EnableIAMUserPermissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${account}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "AllowCloudWatchLogs",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${region}.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "*"
    }
  ]
}
```

```hcl
module "kms" {
  source = "git::https://github.com/virsas/terraform-aws-kms.git?ref=v1.1"

  accountID   = "123456789012"
  region      = "eu-west-1"
  name        = "vss-app"
  description = "Key used to encrypt application data at rest"
}
```

### Advanced Example (Multi Region Key & Custom Policy Path)

Create a multi region symmetric key with a longer deletion window and policy templates stored in a custom directory:

```hcl
module "kms_multi_region" {
  source = "git::https://github.com/virsas/terraform-aws-kms.git?ref=v1.1"

  accountID   = "123456789012"
  region      = "eu-west-1"
  name        = "vss-global"
  description = "Multi region key shared by the global platform"

  json_path = "./policies/kms"

  days_before_delete  = 30
  enable_key_rotation = true
  multi_region        = true
}
```

### Asymmetric Signing Key Example

Create an asymmetric RSA key pair used for signing and verification instead of encryption:

```hcl
module "kms_signing" {
  source = "git::https://github.com/virsas/terraform-aws-kms.git?ref=v1.1"

  accountID   = "123456789012"
  region      = "eu-west-1"
  name        = "vss-signing"
  description = "Key used to sign release artifacts"

  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_4096"
}
```

> [!NOTE]
> Automatic key rotation is only supported for symmetric encryption keys. Set `enable_key_rotation = false` when `key_usage` is `SIGN_VERIFY` or `GENERATE_VERIFY_MAC`, or when `customer_master_key_spec` is anything other than `SYMMETRIC_DEFAULT`.

### HMAC Key Example

Create an HMAC key used to generate and verify message authentication codes:

```hcl
module "kms_hmac" {
  source = "git::https://github.com/virsas/terraform-aws-kms.git?ref=v1.1"

  accountID   = "123456789012"
  region      = "eu-west-1"
  name        = "vss-hmac"
  description = "Key used to generate and verify HMAC tags"

  key_usage                = "GENERATE_VERIFY_MAC"
  customer_master_key_spec = "HMAC_256"
  enable_key_rotation      = false
}
```

---

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_json_path"></a> [json\_path](#input\_json\_path) | Directory containing the key policy templates, which are read as `<json_path>/<name>.json`. | `string` | `"./json/kms"` | no |
| <a name="input_accountID"></a> [accountID](#input\_accountID) | The AWS account ID substituted into the key policy template as `account`. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region substituted into the key policy template as `region`. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the KMS key, used for the `name` tag and to locate the policy JSON file. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the key. | `string` | n/a | yes |
| <a name="input_days_before_delete"></a> [days\_before\_delete](#input\_days\_before\_delete) | The waiting period, in days, before the key is deleted. Must be from `7` to `30` days. | `number` | `7` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Whether to enable automatic key rotation. For security reasons it should stay enabled, but it is only supported for symmetric encryption keys. | `bool` | `true` | no |
| <a name="input_multi_region"></a> [multi\_region](#input\_multi\_region) | Whether to create the key as a multi region key. | `bool` | `false` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | Specifies the intended use of the key. Valid values are `ENCRYPT_DECRYPT`, `SIGN_VERIFY` and `GENERATE_VERIFY_MAC`. | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_customer_master_key_spec"></a> [customer\_master\_key\_spec](#input\_customer\_master\_key\_spec) | Specifies whether the key contains a symmetric key or an asymmetric key pair. Valid values are `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `HMAC_224`, `HMAC_256`, `HMAC_384`, `HMAC_512`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, `ECC_SECG_P256K1`, `ML_DSA_44`, `ML_DSA_65`, `ML_DSA_87`, `SM2` and `ECC_NIST_EDWARDS25519`. | `string` | `"SYMMETRIC_DEFAULT"` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the KMS key. |
| <a name="output_id"></a> [id](#output\_id) | The globally unique identifier of the KMS key. |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
