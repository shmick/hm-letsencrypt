#!/bin/sh

VER="2021-01-31-r01"

HOST="$1"
FORCEOPT="$2"
ACMEDIR="/opt/acme"
ACMEBIN="$ACMEDIR/acme.sh"
ACMEURL="https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh"
KEYFILE="/root/.acme.sh/$HOST/$HOST.key"
UHTTPD="/etc/init.d/uhttpd"
UHTTPD_CRT=$(uci get uhttpd.main.cert)
UHTTPD_KEY=$(uci get uhttpd.main.key)

if [ -z "$HOST" ]; then
  echo "Usage: $0 mybbq.example.com"
  exit 1
fi

if [ -n "$FORCEOPT" ]; then
  FORCEOPT="--force"
else
  FORCEOPT=""
fi

# Download the acme.sh script if missing
if [ ! -f "$ACMEBIN" ]; then
  mkdir -p "$ACMEDIR"
  curl -o "$ACMEBIN" "$ACMEURL"
  chmod +x "$ACMEBIN"
fi

# If a key exists, renew, otherwise issue a new cert
if [ -f "$KEYFILE" ]; then
  MODE="--renew"
else
  MODE="--issue"
fi

# Allows the openssl listener to start on port 443 to vaalidate the cert
echo "[$(date)] Removing HTTPS listener from uhttpd"
uci -q delete uhttpd.main.listen_https
$UHTTPD reload

# Issue or renew the cert
$ACMEBIN --alpn "$MODE" \
  --key-file "$UHTTPD_KEY" \
  --fullchain-file "$UHTTPD_CRT" \
  -d "$HOST" $FORCEOPT

# Add the HTTPS listener back to uttpd
echo "[$(date)] Adding HTTPS listener to uhttpd"
uci add_list uhttpd.main.listen_https="0.0.0.0:443"
uci add_list uhttpd.main.listen_https="[::]:443"
$UHTTPD reload
