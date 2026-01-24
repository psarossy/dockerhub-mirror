# DockerHub Mirror

DockerHub Mirror on Github powered by Github Actions and [Crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane)
[![GitHub Workflow Status (branch)][github-actions-badge]][github-actions-link]

GitHub Actions scheduled to run daily at Midnight UTC to mirror Docker images to [GHCR.io](https://ghcr.io), bypassing Docker Hub rate limits.

[github-actions-badge]: https://img.shields.io/github/actions/workflow/status/psarossy/dockerhub-mirror/mirror.yml?branch=master "Github Workflow Status (master)"
[github-actions-link]: https://github.com/psarossy/dockerhub-mirror/actions?query=workflow%3AMirror%20Dockerhub

## Why Mirror Docker Images?

Docker Hub enforces rate limits on image pulls:
- **Anonymous users**: 100 pulls per 6 hours
- **Authenticated users**: 200 pulls per 6 hours

For homelabs, CI/CD pipelines, or frequent container deployments, these limits can be restrictive. This project automatically mirrors commonly used images to GitHub Container Registry (GHCR.io), which has more generous rate limits.

## How It Works

1. **Daily Schedule**: GitHub Actions runs at midnight UTC (can also be triggered manually)
2. **Smart Mirroring**: Uses Crane to compare image digests - only copies when images have changed
3. **Efficient**: Parallel processing with matrix strategy mirrors all images simultaneously
4. **Zero Maintenance**: Add new images by simply creating a text file with tags

## Currently Mirrored Images

This repository mirrors **43 Docker images** including:

- **Base Images**: alpine, debian, golang, node, nginx, python, rust
- **Databases**: postgres, mysql, mariadb, redis, elasticsearch, influxdb
- **Applications**: grafana, n8n, node-red, vaultwarden, vikunja, uptime-kuma
- **Tools**: haproxy, telegraf, chronograf, traefik-forward-auth
- And many more...

See the [`images/`](images/) directory for the complete list.

## Usage

### Pulling Mirrored Images

Instead of pulling from Docker Hub:
```bash
docker pull nginx:latest
```

Pull from GHCR.io:
```bash
docker pull ghcr.io/psarossy/nginx:latest
```

### Using in Docker Compose

```yaml
services:
  web:
    image: ghcr.io/psarossy/nginx:latest
    ports:
      - "80:80"
```

### Using in Kubernetes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: ghcr.io/psarossy/nginx:latest
```

## Adding New Images

Want to add a new image to the mirror? It's simple:

### For Official Images (single-word names)

Create a file in `images/` with the image name and list tags:

```bash
cat > images/redis << EOF
latest
7.2
alpine
EOF
```

### For Namespaced Images

Create a directory structure matching the image name:

```bash
mkdir -p images/hashicorp
cat > images/hashicorp/terraform << EOF
latest
1.7.0
EOF
```

Then submit a pull request or [open an issue](../../issues/new/choose).

## Helper Scripts

### List Available Tags

Use the helper script to discover available tags for an image:

```bash
./scripts/list-tags.sh nginx
./scripts/list-tags.sh grafana/grafana 50
```

### Validate Changes Locally

Before committing, validate your changes:

```bash
./scripts/validate-local.sh
```

This checks for:
- Trailing whitespace
- Missing final newlines
- Duplicate tags
- Empty files
- Invalid filenames

## How Mirroring Works

The mirroring process is optimized for efficiency:

1. **Matrix Generation**: Scans `images/` directory to build a list of all images
2. **Parallel Processing**: Each image/tag combination is processed simultaneously
3. **Digest Comparison**: For each tag:
   - Fetches source image digest from Docker Hub
   - Fetches destination digest from GHCR.io (if exists)
   - Only copies if digests differ or destination doesn't exist
4. **Smart Copying**: Crane uses cross-repository blob mounting for fast transfers

This means:
- **Bandwidth efficient**: Only changed images are transferred
- **Time efficient**: Unchanged images are skipped in seconds
- **Cost effective**: Minimal GitHub Actions minutes used

## Repository Structure

```
dockerhub-mirror/
├── .github/
│   ├── workflows/
│   │   ├── mirror.yml       # Main mirroring workflow
│   │   └── validate.yml     # PR validation checks
│   ├── ISSUE_TEMPLATE/      # Issue templates
│   └── pull_request_template.md
├── images/                   # Image tag definitions
│   ├── nginx                # Official images (single file)
│   └── grafana/             # Namespaced images (directories)
│       └── grafana
├── scripts/                  # Helper scripts
│   ├── list-tags.sh         # List available tags
│   └── validate-local.sh    # Local validation
├── CLAUDE.md                 # AI assistant guide
└── README.md                 # This file
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add/update image files following conventions
4. Run `./scripts/validate-local.sh` to check your changes
5. Submit a pull request

See [CLAUDE.md](CLAUDE.md) for detailed development guidelines.

## Requirements

The mirroring workflow requires:
- **GHCR_PAT**: GitHub Personal Access Token with `write:packages` permission
- **DOCKERHUB_RO** (optional): Docker Hub credentials for authenticated pulls (higher rate limits)

These are configured as repository secrets.

## License

This project is released into the public domain under [The Unlicense](LICENSE). Use it freely for any purpose.

## Acknowledgments

- [Crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane) - The efficient container image tool that powers this project
- All the open source projects whose images we mirror

## Monitoring

- View workflow runs: [GitHub Actions](https://github.com/psarossy/dockerhub-mirror/actions)
- Check mirrored images: [GHCR.io Packages](https://github.com/psarossy?tab=packages&repo_name=dockerhub-mirror)
