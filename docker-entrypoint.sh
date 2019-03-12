#!/bin/bash
set -e

echo "Starting up with $1"

if [[ "$1" == "bitcoin-cli" || "$1" == "bitcoin-tx" || "$1" == "bitcoind" || "$1" == "test_bitcoin" ]]; then

	mkdir -p "$BITCOIN_DATA"

	CONFIG_PREFIX=""
	if [[ "${BITCOIN_NETWORK}" == "regtest" ]]; then
		CONFIG_PREFIX=$'regtest=1\n[regtest]'
	fi
	if [[ "${BITCOIN_NETWORK}" == "testnet" ]]; then
		CONFIG_PREFIX=$'testnet=1\n[test]'
	fi
	if [[ "${BITCOIN_NETWORK}" == "mainnet" ]]; then
		CONFIG_PREFIX=$'mainnet=1\n[main]'
	fi

	# Fast sync mode
	if [[ ! -v BITCOIN_SNAPSHOT ]]
	then
		echo "Normal startup"
		echo $BITCOIN_SNAPSHOT
	else
		echo "Check fastsync startup?"
	  if [ ! -f "$BITCOIN_DATA/.fast_synced" ]
	  then
	    echo "Extracting utxo snapshot from tarball: $BITCOIN_SNAPSHOT to: $BITCOIN_DATA"
	    tar -xf $BITCOIN_SNAPSHOT -C $BITCOIN_DATA/
	    touch $BITCOIN_DATA/.fast_synced
			BITCOIN_PRUNE_MODE=$'prune=1\nrescan=0\ntxindex=0'
	  fi
	fi

	cat <<-EOF > "$BITCOIN_DATA/bitcoin.conf"
	${CONFIG_PREFIX}
	printtoconsole=1
	rpcallowip=::/0
	${BITCOIN_EXTRA_ARGS}
	${BITCOIN_PRUNE_MODE}
	EOF
	chown bitcoin:bitcoin "$BITCOIN_DATA/bitcoin.conf"


	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R bitcoin "$BITCOIN_DATA"
	ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin
	chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin

	exec gosu bitcoin "$@"
else
	exec "$@"
fi