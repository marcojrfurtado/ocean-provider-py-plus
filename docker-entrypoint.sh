#!/bin/sh

export CONFIG_FILE=/ocean-provider/config.ini
envsubst < /ocean-provider/config.ini.template > /ocean-provider/config.ini

if [ "${DEPLOY_CONTRACTS}" = "true" ]; then
  while [ ! -f "/ocean-contracts/artifacts/ready" ]; do
    sleep 2
  done
fi

/bin/cp -up /ocean-provider/artifacts/* /usr/local/artifacts/ 2>/dev/null || true

gunicorn -b ${OCEAN_PROVIDER_URL#*://} -w ${OCEAN_PROVIDER_WORKERS} -t ${OCEAN_PROVIDER_TIMEOUT} ocean_provider.run:app &

gunicorn -b ${PROXY_SERVER_HOST}:${PROXY_SERVER_PORT} -w ${PROXY_SERVER_WORKERS} -t ${PROXY_SERVER_TIMEOUT} osmosis_streaming_driver.proxy_server.run:app

tail -f /dev/null
