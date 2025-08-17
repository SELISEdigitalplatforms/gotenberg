# Releasing gotenberg 🥂

This document explains the release process for the gotenberg gem.

## Automated Release Process

The easiest way to release a new version is to use the automated release script:

```bash
bin/release
```

This script will:
1. ✅ Check that you're on the main branch
2. ✅ Verify your working directory is clean
3. 📝 Prompt you for the new version number
4. 🔄 Update the version in `lib/gotenberg/version.rb`
5. 📝 Update the changelog with the new version and today's date
6. 📝 Commit all changes
7. 🏷️ Create and push a git tag
8. 📦 Build the gem and push it to RubyGems.org

## Manual Release Process

If you prefer to release manually, follow these steps:

1. Update `CHANGELOG.md` with your changes
2. Update `lib/gotenberg/version.rb` with the target version
3. Commit your changes
4. Create and push a git tag: `git tag -a v1.0.4 -m "Release version 1.0.4"`
5. Push the tag: `git push origin v1.0.4`
6. Build the gem: `gem build gotenberg.gemspec`
7. Push to RubyGems: `gem push gotenberg-1.0.4.gem`

## Prerequisites

- You must be on the `main` branch
- Your working directory must be clean (no uncommitted changes)
- You must have write access to the repository
- You must have RubyGems credentials configured

## Version Format

Versions should follow semantic versioning: `x.y.z`
- `x` - Major version (breaking changes)
- `y` - Minor version (new features, backward compatible)
- `z` - Patch version (bug fixes, backward compatible)