# cert generator

## Usage
```shell
$ docker-compose run --rm app
$ docker-compose run --rm app ORGANIZATION COMMON_NAME ALT_NAMES
$ docker-compose run --rm app "ArgoCD Dex Server" "argocd-dex-server" "DNS.1=argocd-dex-server.argocd.svc" # use generic.* certs
```
