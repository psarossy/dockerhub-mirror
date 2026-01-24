# CLAUDE.md - AI Assistant Guide for DockerHub Mirror

This document provides comprehensive guidance for AI assistants working with the DockerHub Mirror repository.

## Project Overview

**DockerHub Mirror** is a lightweight automation project that mirrors Docker images from Docker Hub to GitHub Container Registry (GHCR.io) to bypass Docker Hub's rate limits. The project uses GitHub Actions and Google's Crane CLI tool to efficiently copy only changed images based on digest comparison.

### Key Facts
- **Language**: No source code - purely configuration-driven
- **Primary Technology**: GitHub Actions, Crane CLI
- **Schedule**: Runs daily at midnight UTC (also supports manual trigger)
- **License**: Public domain (Unlicense)
- **Maintained by**: psarossy

## Repository Structure

```
dockerhub-mirror/
├── .github/
│   ├── workflows/
│   │   └── mirror.yml           # Main GitHub Actions workflow
│   └── dependabot.yml            # Automated dependency updates
├── images/                       # Image tag definitions (43 images total)
│   ├── alpine                    # Single-file format (official images)
│   ├── nginx                     # Single-file format
│   ├── grafana/                  # Directory format (namespaced images)
│   │   ├── grafana              # Image tags list
│   │   └── grafana-image-renderer
│   └── [other images...]
├── .editorconfig                 # Code style configuration
├── README.md                      # Project documentation
└── LICENSE                        # Unlicense (public domain)
```

## Key Files and Their Purposes

### `.github/workflows/mirror.yml`
The heart of the project. This workflow:
- **Trigger**: Runs daily at midnight UTC via cron: `0 0 * * *`
- **Manual trigger**: Supports `workflow_dispatch` for on-demand execution
- **Two-job pipeline**:
  1. `get-images`: Scans `images/` directory and generates a dynamic matrix
  2. `mirror`: Executes parallel mirroring for each image/tag combination

**Critical workflow logic at mirror.yml:40-68**:
- Authenticates to GHCR.io using `GHCR_PAT` secret
- Logs into Docker Hub using `DOCKERHUB_RO` environment variable
- For each tag, compares source and destination digests
- Only copies when digests differ (optimizes bandwidth and time)
- Special case: `n8nio/n8n` uses custom registry `docker.n8n.io`

### Image Tag Files (`images/*`)
Two formats are used:

**Format 1: Single file (official/single-word images)**
```
images/nginx
```
Content:
```
latest
```

**Format 2: Directory structure (namespaced images)**
```
images/grafana/grafana
```
Content:
```
latest

9.3.6
```

**Rules**:
- One tag per line
- Empty lines are ignored
- No comments or special syntax
- File paths mirror Docker image naming: `publisher/image-name`

### `.editorconfig`
Enforces consistent coding style:
- UTF-8 charset
- LF line endings (Unix-style)
- 2-space indentation
- Trim trailing whitespace (except Markdown)
- Insert final newline

## Development Workflows

### Adding a New Image to Mirror

**For official Docker images (single-word names like `nginx`, `alpine`):**
1. Create a new file in `images/` directory with the image name
2. Add tags (one per line)
3. Commit and push

Example:
```bash
# Add Python image with specific tags
cat > images/python << EOF
latest
3.12
3.11
EOF
git add images/python
git commit -m "Add python image to mirror"
```

**For namespaced images (e.g., `grafana/grafana`):**
1. Create directory structure: `images/publisher/`
2. Create file: `images/publisher/image-name`
3. Add tags (one per line)
4. Commit and push

Example:
```bash
# Add Prometheus image
mkdir -p images/prom
cat > images/prom/prometheus << EOF
latest
v2.48.0
EOF
git add images/prom/
git commit -m "Add prom/prometheus to mirror"
```

### Removing an Image
1. Delete the corresponding file or directory under `images/`
2. Commit with descriptive message
3. Note: This only stops future mirroring; existing images remain on GHCR.io

Example:
```bash
rm images/deprecated-image
git add images/deprecated-image
git commit -m "Remove deprecated-image from mirror (image deprecated)"
```

### Updating Tags for Existing Images
1. Edit the relevant file in `images/`
2. Add/remove tags as needed
3. Commit changes

Example:
```bash
# Add new Redis version
echo "7.2" >> images/redis
git add images/redis
git commit -m "Add Redis 7.2 tag"
```

## Code Conventions

### File Naming
- Use lowercase for all image filenames
- Match Docker Hub naming exactly (e.g., `node`, `nginx`)
- For directories, follow Docker's `publisher/image` structure

### Commit Messages
Recent commits show this style:
- Use descriptive, imperative mood: "Add X", "Remove Y", "Update Z"
- Reference context when helpful: "openjdk is deprecated"
- Keep messages concise (single line preferred)

Examples:
- ✅ "Add python 3.12 tag"
- ✅ "Remove openjdk (deprecated)"
- ❌ "updated some files"

### Git Workflow
- **Main branch**: `master` (note: not `main`)
- **Feature branches**: Use descriptive names
- **Branch naming for Claude**: Must start with `claude/` and end with session ID
- **Pull requests**: Required for merging to master
- **Automated updates**: Dependabot creates PRs for GitHub Actions dependencies

### EditorConfig Compliance
All files should follow `.editorconfig` rules:
- 2-space indentation (never tabs)
- UTF-8 encoding
- LF line endings
- Trim trailing whitespace
- Final newline required

## GitHub Actions Details

### Secrets Required
- `GHCR_PAT`: GitHub Personal Access Token with `write:packages` permission
  - Used at mirror.yml:34 for authenticating to GHCR.io
- `DOCKERHUB_RO`: Docker Hub read-only credentials (optional but recommended)
  - Used at mirror.yml:47 for authenticated pulls (higher rate limits)

### Matrix Strategy
The workflow uses dynamic matrix generation:
1. `find images -type f -printf '%P\n'` lists all image files
2. `jq` transforms to matrix format: `{"include": [{"image": "path1"}, {"image": "path2"}]}`
3. Each image processes in parallel with `fail-fast: false`

This means:
- Adding a new image automatically includes it in the workflow
- No workflow changes needed when adding/removing images
- One failing image doesn't stop others from processing

### Performance Optimization
- **Digest comparison**: Only copies when SHA256 digests differ (mirror.yml:54-66)
- **Parallel execution**: All images mirror simultaneously via matrix strategy
- **Crane efficiency**: Uses Crane's cross-repository blob mounting for faster copies
- **Go cache disabled**: Prevents "go.sum not found" warnings (mirror.yml:37)

## Testing and Validation

### No Formal Test Suite
This project has no unit tests or integration tests. Validation occurs through:
1. **GitHub Actions logs**: Check workflow runs for errors
2. **Digest verification**: Crane's digest comparison ensures accuracy
3. **Manual verification**: Pull mirrored images to confirm functionality

### Verifying a Mirror Worked
```bash
# Check if image was mirrored successfully
crane digest docker.io/nginx:latest
crane digest ghcr.io/psarossy/nginx:latest
# Digests should match

# Or pull and test the image
docker pull ghcr.io/psarossy/nginx:latest
docker run --rm ghcr.io/psarossy/nginx:latest nginx -v
```

### Monitoring
- GitHub Actions badge in README shows workflow status
- Workflow runs visible at: https://github.com/psarossy/dockerhub-mirror/actions
- Failed runs indicate issues (authentication, rate limits, network errors)

## Common Tasks for AI Assistants

### Task 1: Add a New Docker Image to Mirror

**Steps**:
1. Determine if image is official (single-word) or namespaced
2. Create appropriate file structure
3. Add relevant tags (check Docker Hub for available tags)
4. Test locally if possible: `find images -type f -printf '%P\n'`
5. Commit with descriptive message
6. Push to feature branch

**Example for official image**:
```bash
cat > images/redis << EOF
latest
7.2
alpine
EOF
git add images/redis
git commit -m "Add redis image to mirror"
```

**Example for namespaced image**:
```bash
mkdir -p images/hashicorp
cat > images/hashicorp/terraform << EOF
latest
1.7.0
EOF
git add images/hashicorp/
git commit -m "Add hashicorp/terraform to mirror"
```

### Task 2: Update Tags for Existing Image

**Steps**:
1. Read existing tags: `cat images/[image-path]`
2. Determine which tags to add/remove
3. Edit file
4. Commit changes
5. Push

**Example**:
```bash
# Add Alpine 3.19 tag
echo "3.19" >> images/alpine
git add images/alpine
git commit -m "Add Alpine 3.19 tag"
```

### Task 3: Remove Deprecated Images

**Steps**:
1. Identify deprecated image
2. Delete file or directory
3. Commit with reason
4. Note in commit message why it's being removed

**Example**:
```bash
rm images/openjdk
git add images/openjdk
git commit -m "Remove openjdk (deprecated upstream)"
```

### Task 4: Troubleshoot Workflow Failures

**Common issues**:
1. **Authentication failure**: Check if `GHCR_PAT` secret is valid
2. **Rate limiting**: Ensure `DOCKERHUB_RO` is set for authenticated pulls
3. **Image not found**: Verify image name and tag exist on Docker Hub
4. **Digest comparison failure**: Source image may have been deleted

**Investigation steps**:
1. Check workflow logs in GitHub Actions
2. Identify which image/tag failed
3. Manually test with Crane:
   ```bash
   crane digest docker.io/[image]:[tag]
   crane digest ghcr.io/psarossy/[image]:[tag]
   ```
4. Fix issue (update tag, remove image, etc.)
5. Re-run workflow or wait for next scheduled run

### Task 5: Update GitHub Actions Dependencies

**Note**: Dependabot handles this automatically, but for manual updates:
1. Check for newer versions of actions
2. Update version numbers in `mirror.yml`
3. Test workflow with `workflow_dispatch`
4. Commit if successful

Current dependencies:
- `actions/checkout@v6`
- `actions/setup-go@v6`
- `docker/login-action@v3`
- `imjasonh/setup-crane@v0.4`

## Special Cases and Edge Cases

### Custom Registry: n8nio/n8n
The `n8nio/n8n` image uses a custom registry (`docker.n8n.io` instead of `docker.io`).

Logic at mirror.yml:41-44:
```bash
repo="docker.io"
if [[ "${{ matrix.image }}" == "n8nio/n8n" ]]; then
  repo="docker.n8n.io"
fi
```

When adding similar images from custom registries:
1. Add conditional logic in workflow
2. Document in commit message
3. Test thoroughly

### Empty or Missing Tags
If an image file is empty or has only whitespace:
- Workflow will process but find no tags
- No error occurs, but no mirroring happens
- Always include at least one tag (typically `latest`)

### Multi-Architecture Images
Crane handles multi-arch images automatically:
- Copies all architectures (amd64, arm64, etc.)
- Preserves manifest lists
- No special configuration needed

## Maintenance and Best Practices

### Regular Maintenance Tasks
1. **Review Dependabot PRs**: Approve and merge dependency updates
2. **Monitor workflow runs**: Check for consistent failures
3. **Update image tags**: Add new stable versions, remove old ones
4. **Clean up deprecated images**: Remove images no longer needed

### Best Practices for AI Assistants
1. **Always check if file exists** before creating new image files
2. **Read existing tags** before modifying to avoid duplicates
3. **Verify image names** on Docker Hub before adding
4. **Use descriptive commit messages** that explain the "why"
5. **Test changes locally** when possible (`find images -type f`)
6. **Follow .editorconfig** rules for consistency
7. **Don't add commented lines** in image tag files (not supported)
8. **Push to claude/ branches** with correct session ID suffix

### What NOT to Do
1. ❌ Don't add images without verifying they exist on Docker Hub
2. ❌ Don't use comments or special syntax in tag files
3. ❌ Don't modify `.github/workflows/mirror.yml` without understanding full impact
4. ❌ Don't add trailing whitespace or missing final newlines
5. ❌ Don't create duplicate tags in the same file
6. ❌ Don't push directly to master (use PRs)
7. ❌ Don't add `latest` tag multiple times (only once per file)

## Useful Commands

### Local Testing
```bash
# List all images that will be mirrored
find images -type f -printf '%P\n'

# Count total images
find images -type f | wc -l

# Check for files with trailing whitespace
find images -type f -exec grep -l ' $' {} \;

# Validate JSON matrix generation (mimics workflow)
find images -type f -printf '%P\n' | jq -R '{"image": .}' | jq -cs '{"include": .}'
```

### Git Operations
```bash
# Check repository status
git status

# Create feature branch (remember claude/ prefix)
git checkout -b claude/add-new-images-[session-id]

# View recent commits
git log --oneline -10

# See what images changed recently
git log --oneline --name-only -- images/

# Push with upstream tracking
git push -u origin claude/add-new-images-[session-id]
```

### Crane Commands (for manual testing)
```bash
# Check image digest
crane digest docker.io/nginx:latest

# List all tags for an image
crane ls docker.io/nginx

# Copy image manually
crane copy docker.io/nginx:latest ghcr.io/psarossy/nginx:latest

# Validate manifest
crane manifest docker.io/nginx:latest
```

## Quick Reference: File Formats

### Official Image (Single File)
**Path**: `images/nginx`
**Content**:
```
latest
stable
alpine
```

### Namespaced Image (Directory)
**Path**: `images/grafana/grafana`
**Content**:
```
latest

9.3.6
```
(Note: Empty lines are OK but not required)

### Multiple Tags with Versions
**Path**: `images/postgres`
**Content**:
```
latest
16
15
14-alpine
13-alpine
```

## Troubleshooting Guide

### Workflow Not Running
- **Check**: Schedule is midnight UTC (verify your timezone)
- **Solution**: Trigger manually via workflow_dispatch

### Image Not Mirroring
- **Check**: Is the tag file empty?
- **Check**: Does the image exist on Docker Hub?
- **Check**: Is there a typo in the image name?
- **Solution**: Verify with `crane ls docker.io/[image]`

### Authentication Errors
- **Check**: Is `GHCR_PAT` secret set and valid?
- **Check**: Does the PAT have `write:packages` permission?
- **Solution**: Regenerate PAT in GitHub settings

### Digest Comparison Failing
- **Check**: Is the source image still available?
- **Check**: Was the image deleted/re-pushed with same tag?
- **Solution**: Let workflow re-copy the image

## Repository Metadata

- **Owner**: psarossy
- **Default Branch**: master
- **License**: Unlicense (public domain)
- **Primary Language**: None (configuration only)
- **Repository Size**: ~344KB
- **Total Images Mirrored**: 43 (as of current commit)
- **Workflow Frequency**: Daily at 00:00 UTC

## Additional Resources

- **Crane Documentation**: https://github.com/google/go-containerregistry/tree/main/cmd/crane
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **GHCR.io Documentation**: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
- **Docker Hub**: https://hub.docker.com
- **EditorConfig**: https://editorconfig.org

## Version History

This CLAUDE.md file documents the repository state as of 2026-01-24. Key recent changes:
- Updated to actions/checkout@v6 and actions/setup-go@v6
- Removed kubectl and deprecated openjdk
- Active Dependabot integration for automated updates
- Clean workflow with efficient digest-based mirroring

---

**Last Updated**: 2026-01-24
**Document Version**: 1.0.0
**For AI Assistant**: Claude Code
