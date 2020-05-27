#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

OUREARTHD=${OUREARTHD:-$SRCDIR/ourearthd}
OUREARTHCLI=${OUREARTHCLI:-$SRCDIR/ourearth-cli}
OUREARTHTX=${OUREARTHTX:-$SRCDIR/ourearth-tx}
OUREARTHQT=${OUREARTHQT:-$SRCDIR/qt/ourearth-qt}

[ ! -x $OUREARTHD ] && echo "$OUREARTHD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
OEVER=($($OUREARTHCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$OUREARTHD --version | sed -n '1!p' >> footer.h2m

for cmd in $OUREARTHD $OUREARTHCLI $OUREARTHTX $OUREARTHQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${OEVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${OEVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m