#!/bin/bash
#
# Creates metadata and indexes for a local Ubuntu/apt repository on a CentOS
# system
#
# Run this script in the top level of your repo directory
#
# Metadata is signed by a GPG key you must create and manage. This prevents
# Ubuntu from warning about unauthenticated packages, which may block
# your packages from being installed (especially during automated installs)
# To perform automated signing, you'll need to remove the key passphrase or
# create a key without it.

# Name of your signing GPG key
GPG_NAME=6D0310D7
# Path to directory containing your key for signing the repo
export GNUPGHOME=/mnt/dist/keys

# Name of your repo/suite
REPONAME=stable

# Name of your organization and name of your repo
ORIGIN="Your Company, Inc."
LABEL="Your Company repository"

for bindir in `find dists/${REPONAME} -type d -name "binary*"`; do
    arch=`echo $bindir|cut -d"-" -f 2`
    echo "Processing ${bindir} with arch ${arch}"

    overrides_file=/tmp/overrides
    package_file=$bindir/Packages
    release_file=$bindir/Release

    # Create simple overrides file to stop warnings
    cat /dev/null > $overrides_file
    for pkg in `ls pool/main/ | grep -E "(all|${arch})\.deb"`; do
        pkg_name=`/usr/bin/dpkg-deb -f pool/main/${pkg} Package`
        echo "${pkg_name} Priority extra" >> $overrides_file
    done

    # Index of packages is written to Packages which is also zipped
    dpkg-scanpackages -a ${arch} pool/main $overrides_file > $package_file
    # The line above is also commonly written as:
    # dpkg-scanpackages -a ${arch} pool/main /dev/null > $package_file
    gzip -9c $package_file > ${package_file}.gz
    bzip2 -c $package_file > ${package_file}.bz2

    # Cleanup
    rm $overrides_file
done

# Release info goes into Release & Release.gpg which includes an md5 & sha1 hash of Packages.*
# Generate & sign release file
pushd dists/${REPONAME}
cat > Release <<ENDRELEASE
Suite: ${REPONAME}
Component: main
Origin: ${ORIGIN}
Label: ${LABEL}
Architecture: i386 amd64
Date: `date -R -u`
ENDRELEASE

# Generate hashes
echo "MD5Sum:" >> Release
for hashme in `find main -type f`; do
    md5=`openssl dgst -md5 ${hashme}|cut -d" " -f 2`
    size=`stat -c %s ${hashme}`
    echo " ${md5} ${size} ${hashme}" >> Release
done
echo "SHA1:" >> Release
for hashme in `find main -type f`; do
    sha1=`openssl dgst -sha1 ${hashme}|cut -d" " -f 2`
    size=`stat -c %s ${hashme}`
    echo " ${sha1} ${size} ${hashme}" >> Release
done
echo "SHA256:" >> Release
for hashme in `find main -type f`; do
    sha256=`openssl dgst -sha256 ${hashme}|cut -d" " -f 2`
    size=`stat -c %s ${hashme}`
    echo " ${sha256} ${size} ${hashme}" >> Release
done

# Sign!
gpg --yes -u $GPG_NAME --digest-algo SHA512 --sign -bao Release.gpg Release
popd
