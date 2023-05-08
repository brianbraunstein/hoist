#!/bin/bash -eu

cd "$(dirname "$(readlink -f "$0")")"

(
  cd repo
  helm package ../chart
  helm repo index .
)

