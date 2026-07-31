# 🔒 Security Notes

## GitHub Token Security

This repository's GitHub Actions workflow uses the **built-in `GITHUB_TOKEN`**
automatically provided by GitHub Actions. **No Personal Access Token (PAT) is
stored in the repo or required for builds.**

The auto-generated `GITHUB_TOKEN` has the following permissions
(declared in `.github/workflows/build-iso.yml`):

```yaml
permissions:
  contents: write   # create releases + upload ISO assets
  packages: write   # (reserved for future container registry pushes)
  actions: write    # trigger retry builds
```

If you ever need to revoke or rotate tokens, visit:
<https://github.com/settings/tokens>

## What is committed to the repo

- ❌ No tokens, passwords, or secrets in any file
- ❌ No `.env` files
- ✅ Only public build configuration and scripts

## What stays in GitHub Secrets

If you later add features that need credentials (e.g. signing keys, external
API tokens), add them under **Settings → Secrets and variables → Actions**
and reference them in the workflow as `${{ secrets.YOUR_SECRET }}`.

## Reporting a vulnerability

Open an issue at <https://github.com/salom600/oslin/issues> with the
`security` label, or email the maintainer directly.
