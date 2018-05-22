#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

BJORNCD=${LITECOIND:-$SRCDIR/bjorncd}
BJORNCCLI=${LITECOINCLI:-$SRCDIR/bjornc-cli}
BJORNCTX=${LITECOINTX:-$SRCDIR/bjornc-tx}
BJORNCQT=${LITECOINQT:-$SRCDIR/qt/bjornc-qt}

[ ! -x $BJORNCD ] && echo "$BJORNCD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
XBJVER=($($LITECOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$BJORNCD --version | sed -n '1!p' >> footer.h2m

for cmd in $BJORNCD $BJORNCCLI $BJORNCTX $BJORNCQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${XBJVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${XBJVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
