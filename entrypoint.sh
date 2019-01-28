#!/bin/bash

if [ -f $BITCOIN_DATA_DIR/.fast_synced ]
then

  echo "Already fast_synced"

else

  [ -d "$BITCOIN_DATA_DIR/blocks" ] && rm -rf "$BITCOIN_DATA_DIR/blocks"
  [ -d "$BITCOIN_DATA_DIR/chainstate" ] && rm -rf "$BITCOIN_DATA_DIR/chainstate"

  echo "Extracting..."

  if ! tar -xf "$UTXO_TAR" -C "$BITCOIN_DATA_DIR"; then
    echo "$UTXO_TAR to $BITCOIN_DATA_DIR"
    exit 1
  fi

  touch $BITCOIN_DATA_DIR/.fast_synced

fi

exec /app/bin/bitcoind -conf=/app/client.conf