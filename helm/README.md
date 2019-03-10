## Before start

Please ensure that helm is installed on your cluster.

```sh
kubectl apply -f service-account.yaml
helm init --service-account tiller
```

Sincerely yours, Captain Obvious

Besides, to work correctly with cert-manager one must create CRDs manually beforeahed, [see for details](https://github.com/helm/charts/tree/master/stable/cert-manager)

## When ready to go

```sh
helm upgrade --wait --timeout 900 --debug --install --namespace kubeinit kubeinit .
```

## Errata

When there is a `dial tcp timeout` error inside of cert-manager logs, one should patch its deployment using provided patch file and command:

```sh
kubectl patch deployment kubeinit-cert-manager -n kubeinit --type merge --patch "$(cat patch-cert-manager-dns-policy.yaml)"
```
