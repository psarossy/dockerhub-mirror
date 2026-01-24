# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive CLAUDE.md documentation for AI assistants
- GitHub Issue template for new image requests
- Pull request template with validation checklist
- Image validation GitHub Action workflow
- Helper scripts for listing tags and local validation
- Enhanced README with usage examples, architecture details, and contributing guidelines
- CHANGELOG.md for tracking notable changes

### Changed
- README.md expanded with comprehensive documentation
- Improved documentation structure

## [1.0.0] - 2024-01-XX

### Changed
- Updated actions/checkout from v5 to v6
- Updated actions/setup-go from v5 to v6

### Removed
- Removed kubectl image (no stable tag)
- Removed openjdk image (deprecated upstream)

## [0.9.0] - 2024-01-XX

### Changed
- Refactored mirroring workflow for improved speed
- Moved authentication logic earlier in workflow
- Disabled Go cache to prevent "go.sum not found" warnings

### Fixed
- kubectl image configuration issues
- Various typo fixes in workflow configuration

## [0.8.0] - 2023-XX-XX

### Changed
- Switched to dynamic matrix generation using folder structure
- Updated image list building process

### Added
- Support for namespaced images via directory structure

## Earlier Releases

Earlier changes were not formally tracked in a changelog.

---

## Categories

- **Added**: New features or images
- **Changed**: Changes to existing functionality or images
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features or images
- **Fixed**: Bug fixes
- **Security**: Security-related changes

## Image Changes

For detailed information about which images are being mirrored, see the [`images/`](images/) directory.

Notable image additions are tracked in git history:
```bash
git log --oneline --name-only -- images/
```
