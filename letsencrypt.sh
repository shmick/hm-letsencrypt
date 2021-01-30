#!/bin/sh

HOST="$1"
ACMEDIR="/opt/acme"
ACMEBIN="$ACMEDIR/acme.sh"
ACMEURL="https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh"
KEYFILE="/root/.acme.sh/$HOST/$HOST.key"
UHTTPD="/etc/init.d/uhttpd"

if [ -z "$HOST" ]; then
    echo "Usage: $0 mybbq.example.com"
    exit 1
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
    --pre-hook "for i in $(pgrep uhttpd) ; do kill $i ; done" \
    -d "$HOST"

CMD=$(pgrep uhttpd)
STATUS="$?"
if [ "$STATUS" != "0" ]; then
    $UHTTPD start
fi
