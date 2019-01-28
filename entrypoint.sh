#!/bin/bash

# Set default FAST_SYNC_MODE
if [ -z $FAST_SYNC_MODE ]
then
  FAST_SYNC_MODE="1"
fi

sed -i "s/{{BITCOIN_DATA_DIR}}/${BITCOIN_DATA_DIR//\//\\/}/g" $BITCOIN_BASE_DIR/client.conf

# Set default FAST_SYNC_MODE
if [ $FAST_SYNC_MODE=="1" ]
then

  # Set UTXO file
  if [ -z $BITCOIN_UTXO_SNAPSHOT ]
  then
    BITCOIN_UTXO_SNAPSHOT="/utxo/utxo-snapshot.tar"
  fi

  while [ ! -f $BITCOIN_UTXO_SNAPSHOT ]
  do
    echo "$(date): Waiting for utxo snapshot to be ready on $BITCOIN_UTXO_SNAPSHOT..."
    sleep 5
  done

  sed -i "s/{{BITCOIN_PRUNE}}/1/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_RESCAN}}/0/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_TXINDEX}}/0/g" $BITCOIN_BASE_DIR/client.conf

  # If file does not exist, then resync with new file
  if [ ! -f "$BITCOIN_DATA_DIR/.fast_synced" ]
  then
    rm -rf "$BITCOIN_DATA_DIR/blocks"
    rm -rf "$BITCOIN_DATA_DIR/chainstate"
    tar -xf $BITCOIN_UTXO_SNAPSHOT -C $BITCOIN_DATA_DIR/
    touch $BITCOIN_DATA_DIR/.fast_synced
    ls -lastr $BITCOIN_DATA_DIR
  fi

else

  sed -i "s/{{BITCOIN_PRUNE}}/0/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_RESCAN}}/1/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_TXINDEX}}/1/g" $BITCOIN_BASE_DIR/client.conf

fi

exec /app/bin/bitcoind -conf=/app/client.conf