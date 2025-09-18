class UnifyDesktopAssistant < Formula
  desc "Unify Desktop Assistant CLI"
  homepage "https://github.com/unifyai/unify-desktop-assistant"

  # Use HEAD for development installs until a tagged release is available.
  head "https://github.com/unifyai/unify-desktop-assistant.git", branch: "macos"

  license "MIT"

  depends_on "node" # required for npm/npx and ts-node

  def install
    libexec.install "install.sh", "remote.sh", "tunnel.sh", "liveview.sh"
    # Vendor agent-service if present in the repo (preserve directory)
    libexec.install "agent-service" if File.directory?("agent-service")
    chmod 0755, Dir[libexec/"*.sh"]

    (bin/"unify-desktop-assistant").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      SCRIPTDIR="#{libexec}"
      cmd="${1:-}"
      case "$cmd" in
        install) exec bash "$SCRIPTDIR/install.sh" ;;
        start)   exec bash "$SCRIPTDIR/remote.sh" ;;
        tunnel)  exec bash "$SCRIPTDIR/tunnel.sh" ;;
        liveview) exec bash "$SCRIPTDIR/liveview.sh" ;;
        version|-v|--version) echo "#{version}" ;;
        ""|-h|--help|help)
          echo "Usage: unify-desktop-assistant {install|start|tunnel|liveview}"
          exit 0
          ;;
        *)
          echo "Unknown command: $cmd" >&2
          echo "Usage: unify-desktop-assistant {install|start|tunnel|liveview}" >&2
          exit 1
          ;;
      esac
    EOS
    chmod 0755, bin/"unify-desktop-assistant"
  end

  test do
    output = shell_output("#{bin}/unify-desktop-assistant 2>&1", 0)
    assert_match "Usage: unify-desktop-assistant", output
  end
end


