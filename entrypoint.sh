#!/bin/bash

set -eu

if [ ! -d "/data/clamav" ]; then
    mkdir /data/clamav 
    chown clamav:clamav /data/clamav
fi

if [ ! -d "/data/clamav-unofficial-sigs" ]; then
    mkdir /data/clamav-unofficial-sigs
    chown clamav:clamav /data/clamav-unofficial-sigs
fi

if [ ! "$(ls /data/clamav/)" ]; then
    echo "[bootstrap] Initial clam DB download."
    /usr/bin/freshclam

    echo "[bootstrap] Initial clamav-unoffical-sigs setup."
    /usr/local/sbin/clamav-unofficial-sigs.sh --force --verbose
fi

update_clam() {
    echo "[update] Running freshclam"
    /usr/bin/freshclam
    echo "[update] Running clamav-unofficial-sigs"
    /usr/local/sbin/clamav-unofficial-sigs.sh --verbose
}

echo "[bootstrap] Scheduling signature update every 1h..."
(while true; do sleep 1h; update_clam; done) &

echo "[bootstrap] Run clamd"
exec sudo -u clamav /usr/sbin/clamd
