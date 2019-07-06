#!/bin/sh

sign_filter () {
    ${lsbk_real_compress}
    rc=$?
    mypid=$(exec sh -c 'echo $PPID')
    stdout_path="$(readlink -f /proc/$mypid/fd/1)"
    exec > /dev/null
    GPG=$(command -v gpg2 2>/dev/null) || \
    GPG=$(command -v gpg 2>/dev/null)
    GPG_SIGN_HOMEDIR="/var/lib/secureboot/gpg-home"
    GPG_SIGN_KEYID="bootsigner@localhost"
    "$GPG" --quiet --no-permission-warning --homedir "${GPG_SIGN_HOMEDIR}" \
        --detach-sign --default-key "${GPG_SIGN_KEYID}" < "${stdout_path}" \
        > "${stdout_path}.sig" && \
    { >&2 echo "linux-secureboot-kit: successfully signed ramdrive '$outfile'!" ; } || :
    return $rc
}

if [ -z "${compress:-}" ]; then
    compress=${COMPRESS}
else
    COMPRESS=${compress}
fi

[ "${compress}" = lzop ] && compress="lzop -9"
[ "${compress}" = xz ] && compress="xz --check=crc32"

lsbk_real_compress=${compress}
compress=sign_filter
