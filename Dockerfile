FROM ubuntu:xenial
MAINTAINER Karsten Kaj Jakobsen <karsten@karstenajkobsen.dk>

ENV BITCOIN_VERSION 0.17.1
ENV BITCOIN_DOWNLOAD_PATH https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}
ENV BITCOIN_DOWNLOAD_FILENAME bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV BITCOIN_RELEASES_KEY 01EA5486DE18A882D4C2684590C8019E36C2E964
ENV BITCOIN_DATA_DIR /app
ENV UTXO_DIR /utxo-sets
ENV UTXO_TAR $UTXO_DIR/utxo-snapshot-bitcoin-mainnet-551636.tar

RUN apt-get update && apt-get install -y --no-install-recommends \
		wget \
    ca-certificates \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget $BITCOIN_DOWNLOAD_PATH/$BITCOIN_DOWNLOAD_FILENAME \
	&& wget $BITCOIN_DOWNLOAD_PATH/SHA256SUMS.asc \
	&& wget https://bitcoin.org/laanwj-releases.asc

RUN gpg --import laanwj-releases.asc \
	&& gpg --fingerprint $BITCOIN_RELEASES_KEY \
	&& gpg --verify SHA256SUMS.asc \
	&& grep -o "$(sha256sum $BITCOIN_DOWNLOAD_FILENAME)" SHA256SUMS.asc \
  && mkdir $BITCOIN_DATA_DIR \
  && tar -xzvf $BITCOIN_DOWNLOAD_FILENAME -C $BITCOIN_DATA_DIR --strip-components=1 \
	&& rm -Rfv bitcoin-* *.asc

RUN chmod -R +x $BITCOIN_DATA_DIR/bin/bitcoin*

COPY files/ $BITCOIN_DATA_DIR/

EXPOSE 8333 8332

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir $BITCOIN_DATA_DIR/data

VOLUME ["$UTXO_DIR"]

ENTRYPOINT [ "/entrypoint.sh" ]