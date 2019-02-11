#!/bin/bash

# Set default FAST_SYNC_MODE
if [ -z $FAST_SYNC_MODE ]
then
  FAST_SYNC_MODE="1"
fi

if [ -z $BITCOIN_PORT ]
then
  BITCOIN_PORT="8333"
fi

if [ -z $BITCOIN_RPCPORT ]
then
  BITCOIN_RPCPORT="8332"
fi

if [ -z $BITCOIN_RPCALLOWIP ]
then
  BITCOIN_RPCALLOWIP="127.0.0.1"
fi

if [ -z $BITCOIN_BINDIP ]
then
  BITCOIN_BINDIP="127.0.0.1"
fi

if [ -z $BITCOIN_RPCUSER ]
then
  BITCOIN_RPCUSER=""
fi

if [ -z $BITCOIN_RPCPASSWORD ]
then
  BITCOIN_RPCPASSWORD=""
fi

sed -i "s/{{BITCOIN_DATA_DIR}}/${BITCOIN_DATA_DIR//\//\\/}/g" $BITCOIN_BASE_DIR/client.conf

# Set default FAST_SYNC_MODE
if [ $FAST_SYNC_MODE=="1" ]
then

  echo "Started bitcoind in FastSync mode"

  # Set UTXO file
  if [ -z $BITCOIN_UTXO_SNAPSHOT ]
  then
    BITCOIN_UTXO_SNAPSHOT="/utxo/utxo-snapshot.tar"
  fi

  # Set UTXO marker
  if [ -z $BITCOIN_UTXO_MARKER ]
  then
    BITCOIN_UTXO_MARKER="/utxo/.finished_utxo"
  fi

  while [ ! -f $BITCOIN_UTXO_MARKER ]
  do
    echo "$(date): Waiting for $BITCOIN_UTXO_MARKER to be ready..."
    sleep 5
  done

  echo "Found $BITCOIN_UTXO_MARKER!"
  echo "Replacing vars in $BITCOIN_BASE_DIR/client.conf"

  sed -i "s/{{BITCOIN_PRUNE}}/1/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_RESCAN}}/0/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_TXINDEX}}/0/g" $BITCOIN_BASE_DIR/client.conf

  # If file does not exist, then resync with new file
  if [ ! -f "$BITCOIN_DATA_DIR/.fast_synced" ]
  then
    rm -rf "$BITCOIN_DATA_DIR/blocks"
    rm -rf "$BITCOIN_DATA_DIR/chainstate"
    echo "Extracting utxo snapshot from tarball: $BITCOIN_UTXO_SNAPSHOT to: $BITCOIN_DATA_DIR"
    tar -xf $BITCOIN_UTXO_SNAPSHOT -C $BITCOIN_DATA_DIR/
    touch $BITCOIN_DATA_DIR/.fast_synced
  fi

else

  sed -i "s/{{BITCOIN_PRUNE}}/0/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_RESCAN}}/1/g" $BITCOIN_BASE_DIR/client.conf
  sed -i "s/{{BITCOIN_TXINDEX}}/1/g" $BITCOIN_BASE_DIR/client.conf

fi

sed -i "s/{{BITCOIN_RPCPASSWORD}}/0/g" $BITCOIN_BASE_DIR/client.conf
sed -i "s/{{BITCOIN_RPCUSER}}/0/g" $BITCOIN_BASE_DIR/client.conf
sed -i "s/{{BITCOIN_RPCALLOWIP}}/0/g" $BITCOIN_BASE_DIR/client.conf
sed -i "s/{{BITCOIN_RPCPORT}}/0/g" $BITCOIN_BASE_DIR/client.conf
sed -i "s/{{BITCOIN_PORT}}/0/g" $BITCOIN_BASE_DIR/client.conf
sed -i "s/{{BITCOIN_BINDIP}}/0/g" $BITCOIN_BASE_DIR/client.conf

exec /app/bin/bitcoind -conf=/app/client.conf