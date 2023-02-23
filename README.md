# DockerHub Mirror
DockerHub Mirror on Github powered by Github Actions and [Crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane)  
[![GitHub Workflow Status (branch)][github-actions-badge]][github-actions-link] 

GitHub Actions scheduled to run daily at Midnight UTC to mirror some images to [GHCR.io](https://ghcr.io), bypassing rate limits

Mirrored Images:
* [`adguardhome`](https://ghcr.io/psarossy/adguard%2Fadguardhome)
* [`mealie`](https://ghcr.io/psarossy/hkotel%2Fmealie)
* [`vaultwarden`](https://ghcr.io/psarossy/vaultwarden%2Fserver)
* [`traefik-forward-auth`](https://ghcr.io/psarossy/thomseddon%2Ftraefik-forward-auth)
* [`mariadb`](https://ghcr.io/psarossy/mariadb)
* [`haproxy`](https://ghcr.io/psarossy/haproxy)
* [`osixia/keepalived`](https://ghcr.io/psarossy/osixia%2Fkeepalived)

* [`grafana`](https://ghcr.io/psarossy/grafana%2Fgrafana)
* [`grafana-image-renderer`](https://ghcr.io/psarossy/grafana%2Fgrafana-image-renderer)
* [`influxdb`](https://ghcr.io/psarossy/influxdb)
* [`chronograf`](https://ghcr.io/psarossy/chronograf)
* [`telegraf`](https://ghcr.io/psarossy/telegraf)

[github-actions-badge]: https://img.shields.io/github/actions/workflow/status/psarossy/dockerhub-mirror/mirror.yml?branch=master "Github Workflow Status (master)"
[github-actions-link]: https://github.com/psarossy/dockerhub-mirror/actions?query=workflow%3AMirror%20Dockerhub
