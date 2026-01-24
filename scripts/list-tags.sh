#!/bin/bash
#
# list-tags.sh - List available tags for a Docker image
#
# Usage: ./scripts/list-tags.sh <image-name> [limit]
#
# Examples:
#   ./scripts/list-tags.sh nginx
#   ./scripts/list-tags.sh grafana/grafana 50
#   ./scripts/list-tags.sh n8nio/n8n 20 docker.n8n.io
#

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <image-name> [limit] [registry]"
  echo ""
  echo "Examples:"
  echo "  $0 nginx"
  echo "  $0 grafana/grafana 50"
  echo "  $0 n8nio/n8n 20 docker.n8n.io"
  exit 1
fi

IMAGE="$1"
LIMIT="${2:-20}"
REGISTRY="${3:-docker.io}"

echo "Listing tags for ${REGISTRY}/${IMAGE} (showing first ${LIMIT})..."
echo ""

if ! command -v crane &> /dev/null; then
  echo "Error: crane is not installed"
  echo "Install it with: go install github.com/google/go-containerregistry/cmd/crane@latest"
  exit 1
fi

crane ls "${REGISTRY}/${IMAGE}" | head -n "${LIMIT}"
