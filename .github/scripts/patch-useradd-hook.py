#!/usr/bin/env python3
"""
OSLin Auto-Repair: Patch useradd hook to filter missing groups.

Usage: python3 patch-useradd-hook.py <hook_path>

If the hook uses a hardcoded group list like:
    useradd -m -s /bin/bash -G sudo,adm,...,lpadmin,scanner oslin
replaces it with a version that filters groups via getent.
"""
import sys
import os

def main():
    if len(sys.argv) < 2:
        print("Usage: patch-useradd-hook.py <hook_path>", file=sys.stderr)
        sys.exit(1)

    hook_path = sys.argv[1]
    if not os.path.exists(hook_path):
        print(f"Hook not found: {hook_path}", file=sys.stderr)
        sys.exit(1)

    with open(hook_path, 'r') as f:
        content = f.read()

    if 'getent group' in content:
        print("Hook already patched - nothing to do.")
        return 0

    old = "useradd -m -s /bin/bash -G sudo,adm,cdrom,audio,video,plugdev,netdev,bluetooth,lpadmin,scanner oslin"
    new = (
        'SUPP_GROUPS=""\n'
        '            for g in sudo adm cdrom audio video plugdev netdev bluetooth lpadmin scanner; do\n'
        '                if getent group "$g" >/dev/null 2>&1; then\n'
        '                    SUPP_GROUPS="${SUPP_GROUPS:+$SUPP_GROUPS,}$g"\n'
        '                fi\n'
        '            done\n'
        '            if [ -n "$SUPP_GROUPS" ]; then\n'
        '                useradd -m -s /bin/bash -G "$SUPP_GROUPS" oslin\n'
        '            else\n'
        '                useradd -m -s /bin/bash oslin\n'
        '            fi'
    )

    if old in content:
        content = content.replace(old, new)
        with open(hook_path, 'w') as f:
            f.write(content)
        print("Hook patched for missing-group safety.")
        return 0
    else:
        print(f"Pattern not found in {hook_path} - manual review needed.", file=sys.stderr)
        return 2

if __name__ == '__main__':
    sys.exit(main())
