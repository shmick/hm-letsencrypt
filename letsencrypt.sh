#!/bin/sh

VER="2021-01-30-r00"

HOST="$1"
FORCEOPT="$2"
ACMEDIR="/opt/acme"
ACMEBIN="$ACMEDIR/acme.sh"
ACMEURL="https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh"
KEYFILE="/root/.acme.sh/$HOST/$HOST.key"
UHTTPD="/etc/init.d/uhttpd"

if [ $1 == "stop_uhttpd" ]; then
  for i in $(pgrep uhttpd); do kill $i; done
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
  --key-file /etc/uhttpd.key \
  --fullchain-file /etc/uhttpd.crt \
  --pre-hook "$0 stop_uhttpd" \
  -d "$HOST" $FORCEOPT

CMD=$(pgrep uhttpd)
STATUS="$?"
if [ "$STATUS" != "0" ]; then
  $UHTTPD start
fi
