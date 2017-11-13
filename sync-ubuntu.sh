#!/bin/bash
#
# Calls debmirror to mirror an Ubuntu release to your local system
#
# This script is a bit more complicated than necessary, but works
#

VER='16.04.3'
RELEASE=xenial-security,xenial-updates,xenial-backports
# Upstream repository server
HOST='archive.ubuntu.com'
HOSTPATH=/ubuntu


# Sections to download
section=main,restricted,universe,multiverse

# Method of mirroring, http, https, or rsync
proto=http

# Your destination path to mirror stuff to
DESTBASE='/mnt/dist/ubuntu/'

export GNUPGHOME=${DESTBASE?}/keys

if [ ! -d "${DESTBASE?}" ]; then
  echo "Error: base destination directory does not exist. Is the repo mounted?" 
  exit 1
fi

[ -d "${GNUPGHOME}" ] || mkdir -p "${GNUPGHOME}"
chmod 0700 ${GNUPGHOME}

for arch in amd64; do
  echo "*** Processing arch: ${arch}"
  DEST="${DESTBASE}/${VER}/${arch}"
  [ -d "${DEST}" ] || mkdir -p ${DEST}

  debmirror -a ${arch} --no-source -s ${section} -h ${HOST} \
    -r ${HOSTPATH} --progress -e ${proto} -d ${RELEASE} ${DEST} \
    --i18n

  echo
done
