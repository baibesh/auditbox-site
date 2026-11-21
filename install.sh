#!/bin/sh
# Installs AuditBox on this Linux server. No questions: it downloads the
# program, checks it and runs its installer, which prints a link to finish
# in the browser.
#
#   curl -fsSL https://baibesh.github.io/auditbox-site/install.sh | sudo sh
#   curl -fsSL https://baibesh.github.io/auditbox-site/install.sh | sudo sh -s -- --domain audit.example.kz
#
# With --domain, HTTPS is set up for that name at once (the name must point at
# this server). Run again later, the same command upgrades AuditBox.
set -eu

main() {
  BASE="${AUDITBOX_DOWNLOAD:-https://github.com/baibesh/auditbox-site/releases/latest/download}"
  die() { echo "error: $*" >&2; exit 1; }

  [ "$(id -u)" = 0 ] || die "run it as root: add sudo before sh"
  [ "$(uname -s)" = Linux ] || die "AuditBox is installed on a Linux server"
  case "$(uname -m)" in
    x86_64|amd64) ARCH=x86_64 ;;
    aarch64|arm64) ARCH=aarch64 ;;
    *) die "no build for $(uname -m)" ;;
  esac
  command -v sha256sum >/dev/null 2>&1 || die "sha256sum is missing"
  if command -v curl >/dev/null 2>&1; then get() { curl -fsSL "$1" -o "$2"; }
  elif command -v wget >/dev/null 2>&1; then get() { wget -qO "$2" "$1"; }
  else die "curl or wget is needed"; fi

  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  echo "Downloading AuditBox for $ARCH"
  get "$BASE/auditbox-linux-$ARCH" "$TMP/auditbox" || die "could not download the program"
  get "$BASE/auditbox-linux-$ARCH.sha256" "$TMP/sum" || die "could not download the checksum"
  EXPECTED="$(cut -d' ' -f1 "$TMP/sum")"
  ACTUAL="$(sha256sum "$TMP/auditbox" | cut -d' ' -f1)"
  [ -n "$EXPECTED" ] && [ "$EXPECTED" = "$ACTUAL" ] || die "the downloaded program does not match its checksum"
  chmod 0755 "$TMP/auditbox"
  "$TMP/auditbox" install "$@"
}

# the whole script is read before anything runs: a cut-off download does nothing
main "$@"
