# Releasing gotenberg 🥂

This document explains releasing process for all gotenberg gems.

### Releasing

For releasing new version of `gotenberg`, this is the procedure:

1. Update `CHANGELOG.md`
2. Update `VERSION` file with target version
3. Run `rake release:commit_version`
4. Create pull request with all that ([example](https://github.com/SELISEdigitalplatforms/l3-ruby-gem-gotenberg/pull/69))
5. Merge the pull request when CI is green
6. Ensure you have latest changes locally
7. Run `rake release:tag_version`
8. Push tag to upstream
9. Run `rake release:watch` and watch GitHub Actions push to RubyGems.org

### Packaging
<!-- TODO -->
### Packaging and installing locally
<!-- TODO -->