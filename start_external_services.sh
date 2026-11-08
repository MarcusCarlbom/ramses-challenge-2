#!/bin/bash
# Starts RAMSES's payment and delivery services locally, because the originals on vercel.app are offline.
# Put this file in SEAMS24_artifact_package/bash_scripts/execute/ and call it from RUN_ALL.sh.
SERVICES="$(cd "$(dirname "$0")/../../third-party-services" && pwd)" || exit 1
docker image inspect python:3.12-alpine > /dev/null 2>&1 || docker pull -q python:3.12-alpine > /dev/null

for kind in payment delivery; do
  for i in 1 2 3; do
    name="${kind}-proxy-${i}-service-backend"
    docker rm -f "$name" > /dev/null 2>&1
    docker run -d --name "$name" --network ramses-sas-net -e PORT=48090 python:3.12-alpine \
      python -u -c "$(sed 's/HTTPServer((/ThreadingHTTPServer((/; s/import BaseHTTPRequestHandler, HTTPServer$/import BaseHTTPRequestHandler, HTTPServer, ThreadingHTTPServer/' \
        "$SERVICES/${kind}Service/${kind}service${i}.py")" > /dev/null || exit 1
  done
done
echo "Started payment and delivery services 1-3"
