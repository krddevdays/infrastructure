## TL;DR

Setup environment variables using any suitable for you way.

```sh
cd terraform
make init && make plan && make apply
# wait until instance cloud-config is up and running
ssh ubuntu@<instance-address> 'tail -f /var/log/cloud-config-output.log'
# Ensure that your DNS records point to the newly created machine public IPs.
cd ansible
ansible-playbook init.yml
```

After completion, cluster admin config can be found in `ansible/pki/admin.conf`

## Required environment variables

No variables - no success.

`YC_TOKEN` - YC JWT token.
`YC_CLOUD_ID` - YC cloud identifier.
`YC_FOLDER_ID` - YC project folder identifier.
`YC_ZONE` - default YC AZ.
`YC_KEY_ID` - service account key ID.
`YC_KEY_SECRET` - service account key secret.
`YC_BUCKET` - bucket name for backend.
`DNSIMPLE_TOKEN` - DNSimple token.
`DNSIMPLE_ACCOUNT` - DNSimple account id.
`TF_VAR_domain` - domain name on DNSimple.

## Errata

In case of terraform version older than 0.12 before running terraform replace the following lines inside of inventory.tf: `master_inventories = "${...}"` by `master_inventories = ""`, then `make plan && make apply`, revert lines back and `make plan && make apply` again. This is a terraform bug and it will be fixed in 0.12.0 https://github.com/hashicorp/terraform/issues/18160

## Host keys

Host public and private keys are being stored in this repository, but the private part is encrypted by ansible-vault. To process the following operations one must have access to the ansible-vault decryption password.

Decrypt: `ansible-vault decrypt id_rsa.encrypted --output=id_rsa --vault-password-file=<file location>`

Encrypt: `ansible-vault encrypt id_rsa --output=id_rsa.encrypted --vault-password-file=<file location>`

## Upgrade Kubernetes version

At first, one must edit (and commit :-) ) upgrade.yml file to specify new desired k8s version.

```sh
cd ansible
ansible-playbook upgrade.yml
```

## Reset cluster

In most normal cases there is no need to reset kubernetes cluster while running in the cloud, but for some extremely rare cases it may be useful.

```sh
cd ansible
ansible-playbook reset.yml
```
