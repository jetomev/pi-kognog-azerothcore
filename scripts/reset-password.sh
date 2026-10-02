#!/usr/bin/env bash
# Reset a game account's password while the realm keeps running.
# Works with the worldserver console switched off (Console.Enable=0): it writes
# a new SRP6 salt + verifier straight into the auth database, the same way
# `account set password` does. The password is never shown, logged or stored.
# Usage, on the Pi:  bash reset-password.sh <account>
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$here/logs"
log="$here/logs/reset-password-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee "$log") 2>&1
ln -sfn "$(basename "$log")" "$here/logs/reset-password-latest.log"

conf="${ACORE_CONF:-/mnt/nvme/azerothcore-wotlk/env/dist/etc/authserver.conf}"
acct="$(printf '%s' "${1:?usage: reset-password.sh <account>}" | tr '[:lower:]' '[:upper:]')"
[[ "$acct" =~ ^[A-Z0-9]{1,17}$ ]] || { echo "Account names are letters and numbers only."; exit 1; }

IFS=';' read -r h p u pw db <<<"$(grep -E '^LoginDatabaseInfo' "$conf" | cut -d'"' -f2)"
export MYSQL_PWD="$pw"
q() { mysql -h "$h" -P "$p" -u "$u" "$db" -N -B -e "$1"; }

if [ -z "$(q "SELECT id FROM account WHERE username='$acct'")" ]; then
  echo "There is no account called $acct. The accounts on this realm are:"
  q "SELECT username FROM account ORDER BY id"
  exit 1
fi
echo "Account found: $acct"

read -rs -p "New password (up to 16 characters): " P1 </dev/tty; echo
read -rs -p "Type it again: " P2 </dev/tty; echo
[ "$P1" = "$P2" ] || { echo "The two passwords are different. Nothing changed."; exit 1; }
[ "${#P1}" -ge 1 ] && [ "${#P1}" -le 16 ] || { echo "Use 1 to 16 characters. Nothing changed."; exit 1; }

srp='
import os, sys, hashlib
N = int("894B645E89E1535BBDAD5B8B290650530801B18EBFBF5E8FAB3C82872A3E9BB7", 16)
user, pw = os.environ["A"].upper(), os.environ["P"].upper()
salt = bytes.fromhex(sys.argv[1]) if len(sys.argv) > 1 else os.urandom(32)
h = hashlib.sha1(f"{user}:{pw}".encode()).digest()
x = int.from_bytes(hashlib.sha1(salt + h).digest(), "little")
print(salt.hex(), pow(7, x, N).to_bytes(32, "little").hex())
'
read -r salt ver <<<"$(A="$acct" P="$P1" python3 -c "$srp")"
q "UPDATE account SET salt=UNHEX('$salt'), verifier=UNHEX('$ver'), failed_logins=0 WHERE username='$acct'"

# Prove it: read back what the database now holds and check the password against it.
read -r dbsalt dbver <<<"$(q "SELECT HEX(salt), HEX(verifier) FROM account WHERE username='$acct'")"
read -r _ check <<<"$(A="$acct" P="$P1" python3 -c "$srp" "$dbsalt")"
unset P1 P2
if [ "${check^^}" != "$dbver" ]; then echo "FAIL: the stored password does not match. Try again."; exit 1; fi
echo "The new password is saved and checks out against the database."
echo "OK"
