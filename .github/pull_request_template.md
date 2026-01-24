## Description

Please describe the changes in this PR.

## Type of Change

- [ ] New image(s) added
- [ ] Image tag(s) updated
- [ ] Image(s) removed
- [ ] Workflow improvement
- [ ] Documentation update
- [ ] Other (please describe)

## Checklist

### For New Images or Tag Updates

- [ ] I have verified the image/tags exist on Docker Hub (or specified registry)
- [ ] Image name follows the correct format (lowercase, matches Docker Hub exactly)
- [ ] For official images: created single file in `images/` directory
- [ ] For namespaced images: created `images/publisher/image-name` file structure
- [ ] Tags are listed one per line with no comments or special syntax
- [ ] File follows `.editorconfig` rules (LF line endings, no trailing whitespace, final newline)
- [ ] I tested locally with `find images -type f -printf '%P\n'` to verify the file is detected

### For Custom Registry Images

- [ ] Updated `.github/workflows/mirror.yml` with custom registry logic (if needed)
- [ ] Documented custom registry in commit message

### General

- [ ] Commit message follows project conventions (descriptive, imperative mood)
- [ ] No sensitive information included
- [ ] Reviewed [CLAUDE.md](../CLAUDE.md) for guidelines

## Testing

Please describe how you tested these changes:

- [ ] Verified image exists: `crane ls docker.io/[image]` (or equivalent)
- [ ] Checked file is detected: `find images -type f -printf '%P\n'`
- [ ] Other (please describe)

## Additional Notes

Add any additional context or screenshots here.
