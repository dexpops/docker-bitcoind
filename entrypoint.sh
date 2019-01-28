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

  sed -i "s/{{BITCOIN_PRUNE}}/1/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_RESCAN}}/0/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_TXINDEX}}/0/g" $BITCOIN_BASE_DIR/client.conf

  while [ ! -f "$BITCOIN_DATA_DIR/.fast_synced" ]
  do
    echo "Waiting for $BITCOIN_DATA_DIR/.fast_synced to be ready..."
    sleep 2
  done

else

  sed -i "s/{{BITCOIN_PRUNE}}/0/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_RESCAN}}/1/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_TXINDEX}}/1/g" $BITCOIN_BASE_DIR/client.conf

fi

exec /app/bin/bitcoind -conf=/app/client.conf