cask "aks-fleet-dashboard" do
  version "0.7.2"

  # Split per platform rather than one url/sha pair, because the artifacts are
  # different kinds of thing: a .dmg holding an .app on macOS, a bare AppImage
  # on Linux.
  #
  # `depends_on macos:` has to live inside `on_macos` and not at the top level.
  # Homebrew decides whether a cask may install on Linux with
  #
  #   def supports_linux?
  #     return true if depends_on.requires_linux?
  #     !depends_on.requires_macos?
  #   end
  #
  # so a top-level macOS dependency applies on every platform and makes the
  # Linux install abort with "This cask requires macOS."
  on_macos do
    sha256 "193c3840d388cd32084965321b50ca36493c40c3d27657fa94792a5335df319b"
    url "https://github.com/aavishay/aks-multicluster-dashboard/releases/download/v#{version}/AKS-Fleet-Dashboard-#{version}-universal.dmg"

    # Universal build, so one artifact covers both architectures. A bare symbol
    # means "this version or newer".
    #
    # Big Sur rather than Tauri v2's actual floor of macOS 10.15: Homebrew moved
    # :catalina into DISABLED_MACOS_VERSIONS, so declaring it now aborts the
    # install outright. Big Sur is the oldest symbol still accepted, and the gap
    # costs nothing in practice — Homebrew itself does not run on Catalina, so
    # nobody could reach this cask from there anyway.
    depends_on macos: :big_sur

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

  on_linux do
    sha256 "c95667b77f7c93c96b873d7793d18626bc42a5604e2261a840fdc064c0b590be"
    url "https://github.com/aavishay/aks-multicluster-dashboard/releases/download/v#{version}/AKS-Fleet-Dashboard-#{version}-x86_64.AppImage"

    # x86-64 only for now; there is no arm64 Linux build to point at.
    depends_on arch: :x86_64

    # The target deliberately carries no version. Homebrew's own audit rejects a
    # versioned `app_image` target: a self-updater that renames the file would
    # leave the Caskroom's back-symlink dangling, whereas a version-less target
    # is overwritten in place.
    app_image "AKS-Fleet-Dashboard-#{version}-x86_64.AppImage",
              target: "AKS-Fleet-Dashboard.AppImage"

    # Same reasoning as the macOS list: nothing here is written by the app
    # itself, which only ever reads ~/.kube/config. These are WebKitGTK's XDG
    # directories, keyed by the bundle identifier.
    #
    # An AI provider key is not among them — on Linux it lives in the D-Bus
    # secret service, which a cask cannot reach. Remove it with your keyring
    # tool (seahorse, `secret-tool clear`) if you want it gone.
    zap trash: [
      "~/.config/io.github.aavishay.aks-fleet-dashboard",
      "~/.local/share/io.github.aavishay.aks-fleet-dashboard",
      "~/.cache/io.github.aavishay.aks-fleet-dashboard",
    ]

    caveats <<~EOS
      Installed to ~/Applications/AKS-Fleet-Dashboard.AppImage, which is
      Homebrew's default appimagedir. Run it from there, or wire it into your
      launcher yourself — a cask does not write .desktop entries.

      Saving a key for one of the AI providers needs a running D-Bus secret
      service (gnome-keyring, kwallet). Without one, saving fails and
      everything else still works; an exported ANTHROPIC_API_KEY (or the
      equivalent for your provider) is honoured either way.

      The app needs a working kubectl context per cluster. It reads your existing
      ~/.kube/config and stores no credentials of its own:

        az aks get-credentials --resource-group <rg> --name <cluster> --merge
    EOS
  end

  name "AKS Fleet Dashboard"
  desc "Multi-cluster Kubernetes dashboard for Azure AKS fleets"
  homepage "https://github.com/aavishay/aks-multicluster-dashboard"

  livecheck do
    url :url
    strategy :github_latest
  end
end
