cask "aks-fleet-dashboard" do
  version "0.4.0"
  sha256 "f1c6dbfb6753fdf96eccea57daa73684f017954ebc91d40ad2fa7228f3c897a3"

  url "https://github.com/aavishay/aks-multicluster-dashboard/releases/download/v#{version}/AKS-Fleet-Dashboard-#{version}-universal.dmg"
  name "AKS Fleet Dashboard"
  desc "Multi-cluster Kubernetes dashboard for Azure AKS fleets"
  homepage "https://github.com/aavishay/aks-multicluster-dashboard"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Universal build, so one artifact covers both architectures. Tauri v2's
  # floor is macOS 10.15; a bare symbol means "this version or newer" (the
  # `">= :catalina"` string form is deprecated).
  depends_on macos: :catalina

  app "AKS Fleet Dashboard.app"

  # The app reads ~/.kube/config and keeps no credentials of its own; these are
  # just the WebView's own state (theme, UI scale, sidebar) plus the standard
  # macOS per-bundle directories.
  zap trash: [
    "~/Library/Application Support/io.github.aavishay.aks-fleet-dashboard",
    "~/Library/Caches/io.github.aavishay.aks-fleet-dashboard",
    "~/Library/HTTPStorages/io.github.aavishay.aks-fleet-dashboard",
    "~/Library/Preferences/io.github.aavishay.aks-fleet-dashboard.plist",
    "~/Library/Saved Application State/io.github.aavishay.aks-fleet-dashboard.savedState",
    "~/Library/WebKit/io.github.aavishay.aks-fleet-dashboard",
  ]

  caveats <<~EOS
    This build is ad-hoc signed rather than signed with an Apple Developer ID,
    so macOS quarantines it and will refuse to open it on first launch. Clear
    the quarantine flag once:

      xattr -dr com.apple.quarantine "#{appdir}/AKS Fleet Dashboard.app"

    To skip that step on future installs, pass --no-quarantine:

      brew install --cask --no-quarantine aks-fleet-dashboard

    The app needs a working kubectl context per cluster. It reads your existing
    ~/.kube/config and stores no credentials of its own:

      az aks get-credentials --resource-group <rg> --name <cluster> --merge
  EOS
end
