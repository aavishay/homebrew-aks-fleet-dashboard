# homebrew-aks-fleet-dashboard

Homebrew tap for [AKS Fleet Dashboard](https://github.com/aavishay/aks-multicluster-dashboard) —
a native multi-cluster Kubernetes dashboard for Azure AKS fleets.

## Install

Homebrew requires third-party casks to be trusted once before first install:

```bash
brew trust aavishay/aks-fleet-dashboard
brew install --cask aavishay/aks-fleet-dashboard/aks-fleet-dashboard
```

The app is ad-hoc signed rather than signed with an Apple Developer ID, so
macOS quarantines it on first launch. Either clear the flag once after
installing:

```bash
xattr -dr com.apple.quarantine "/Applications/AKS Fleet Dashboard.app"
```

…or install with `--no-quarantine` to skip that step:

```bash
brew install --cask --no-quarantine aavishay/aks-fleet-dashboard/aks-fleet-dashboard
```

## Upgrade

```bash
brew upgrade --cask aks-fleet-dashboard
```
