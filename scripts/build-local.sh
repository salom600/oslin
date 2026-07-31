#!/bin/bash
# ============================================
# OSLin - Local Build Script
# Run on a Debian/Ubuntu machine with live-build installed
# Usage: ./scripts/build-local.sh [--clean] [--debug]
# ============================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

CLEAN=0
DEBUG=0
for arg in "$@"; do
    case "$arg" in
        --clean) CLEAN=1 ;;
        --debug) DEBUG=1 ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

echo "=========================================="
echo " OSLin Local Build"
echo "=========================================="

# Check dependencies
for cmd in lb debootstrap xorriso; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $cmd"
        echo "Install with: sudo apt install live-build debootstrap xorriso"
        exit 1
    fi
done

# Make all hooks and scripts executable
echo "[1/5] Ensuring scripts are executable..."
chmod +x config/hooks/normal/*.hook.chroot 2>/dev/null || true
chmod +x config/hooks/live/*.hook.chroot 2>/dev/null || true
chmod +x config/includes.chroot/usr/local/bin/* 2>/dev/null || true

if [ "$CLEAN" -eq 1 ]; then
    echo "[2/5] Cleaning previous build..."
    lb clean --purge 2>/dev/null || true
    rm -rf .build out
fi

echo "[3/5] Configuring live-build..."
lb config noauto \
    --distribution bookworm \
    --architectures amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --iso-volume "OSLin 2026.1" \
    --iso-application "OSLin Hybrid Distribution" \
    --iso-publisher "OSLin Project" \
    --iso-preparer "OSLin Local Build" \
    --bootappend-live "boot=live components username=oslin hostname=oslin locales=en_US.UTF-8,ar_SA.UTF-8 keyboard-layouts=us,ar timezone=Africa/Lagos quiet splash" \
    --bootloader syslinux \
    --debian-installer live \
    --chroot-filesystem squashfs \
    --compression xz \
    --checksums sha256 \
    --source false

if [ "$DEBUG" -eq 1 ]; then
    echo "[4/5] Building (DEBUG mode)..."
    lb build
else
    echo "[4/5] Building ISO (this takes 30-90 minutes)..."
    lb build 2>&1 | tee build.log
fi

ISO_FILE=$(ls live-image-*.hybrid.iso 2>/dev/null | head -1 || true)
if [ -z "$ISO_FILE" ]; then
    echo "ERROR: Build failed — no ISO produced"
    exit 1
fi

echo "[5/5] Finalizing..."
mkdir -p out
VERSION="2026.1-$(date +%Y%m%d)-local"
OUTPUT_NAME="oslin-${VERSION}-amd64.iso"
mv "$ISO_FILE" "out/$OUTPUT_NAME"
(cd out && sha256sum "$OUTPUT_NAME" > SHA256SUMS)
cp build.log out/ 2>/dev/null || true

echo ""
echo "✅ Build complete!"
echo "   ISO: out/$OUTPUT_NAME"
echo "   Size: $(du -h out/$OUTPUT_NAME | cut -f1)"
echo "   SHA256: see out/SHA256SUMS"
echo ""
echo "Flash to USB:"
echo "   sudo dd if=out/$OUTPUT_NAME of=/dev/sdX bs=4M status=progress && sync"
echo "   (replace /dev/sdX with your USB device)"
