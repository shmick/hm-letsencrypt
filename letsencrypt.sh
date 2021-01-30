#!/bin/sh

VER="2021-01-30-r03"

HOST="$1"
FORCEOPT="$2"
ACMEDIR="/opt/acme"
ACMEBIN="$ACMEDIR/acme.sh"
ACMEURL="https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh"
KEYFILE="/root/.acme.sh/$HOST/$HOST.key"
UHTTPD="/etc/init.d/uhttpd"
UHTTPD_CRT=$(uci get uhttpd.main.cert)
UHTTPD_KEY=$(uci get uhttpd.main.key)

if [ "$1" == "stop_uhttpd" ]; then
  # Try regular way
  $UHTTPD stop
  alive=$(pgrep uhttpd)
  # If it didn't stop cleanly, kill the uhttpd PID
  if [ "$?" == "0" ]; then
    for i in $(pgrep uhttpd); do kill $i; done
  fi
  exit 0
fi

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

# Issue or renew the cert
$ACMEBIN --alpn "$MODE" \
  --key-file "$UHTTPD_KEY" \
  --fullchain-file "$UHTTPD_CRT" \
  --pre-hook "$0 stop_uhttpd" \
  -d "$HOST" $FORCEOPT

CMD=$(pgrep uhttpd)
STATUS="$?"
if [ "$STATUS" != "0" ]; then
  $UHTTPD start
fi
