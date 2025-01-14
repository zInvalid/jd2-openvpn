#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Make sure mandatory directories exist.
mkdir -p /config/logs /config/libs/

if [ ! -f /config/JDownloader.jar ]; then
    cp /defaults/JDownloader.jar /config
    cp -r /defaults/cfg /config/
fi

cp -rf /defaults/patches/7zip/sevenzipjbinding1509.jar /config/libs/sevenzipjbinding.jar
cp -rf /defaults/patches/7zip/sevenzipjbinding1509Linux.jar /config/libs/sevenzipjbindingLinux.jar

# Take ownership of the config directory content.
find /config -mindepth 1 -exec chown $USER_ID:$GROUP_ID {} \;

# Take ownership of the output directory.
if ! chown $USER_ID:$GROUP_ID /output; then
    # Failed to take ownership of /output.  This could happen when,
    # for example, the folder is mapped to a network share.
    # Continue if we have write permission, else fail.
    if s6-setuidgid $USER_ID:$GROUP_ID [ ! -w /output ]; then
        log "ERROR: Failed to take ownership and no write permission on /output."
        exit 1
    fi
fi

# vim: set ft=sh :
