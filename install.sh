#!/usr/bin/env bash
set -euo pipefail

# Firewall Center demo installer
# - Generates self-signed certs in ./certs
# - Builds images and runs docker-compose up -d
# Usage:
#   sudo ./install.sh [--mode docker-compose|systemd] [--no-start]
# Defaults: mode=docker-compose

MODE="docker-compose"
NO_START=0

print_help() {
  cat <<EOF
Usage: $0 [--mode docker-compose|systemd] [--no-start] [--help]
  --mode          installer mode (docker-compose or systemd). Default: docker-compose
  --no-start      prepare artifacts but do not start containers/services
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"; shift 2;;
    --no-start)
      NO_START=1; shift;;
    --help)
      print_help; exit 0;;
    *)
      echo "Unknown arg: $1"; print_help; exit 1;;
  esac
done

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

echo "Installer mode: $MODE"

if [[ "$MODE" == "docker-compose" ]]; then
  if ! command_exists docker; then
    echo "ERROR: docker is required. Install docker and re-run."
    exit 2
  fi
  # Compose plugin detection
  if docker compose version >/dev/null 2>&1; then
    DCMD="docker compose"
  elif command_exists docker-compose; then
    DCMD="docker-compose"
  else
    echo "ERROR: docker-compose is required (or docker compose plugin). Install it and re-run."
    exit 2
  fi
else
  echo "Only docker-compose mode is supported in this demo installer."
  exit 1
fi

# Create needed directories
mkdir -p certs data/controller data/agent

# Generate self-signed certs for demo if not present
if [[ ! -f certs/ca.key ]]; then
  echo "Generating demo CA and certs (certs/)..."
  openssl genrsa -out certs/ca.key 2048
  openssl req -x509 -new -nodes -key certs/ca.key -subj "/CN=FirewallCenter Demo CA" -days 3650 -out certs/ca.crt
fi

if [[ ! -f certs/controller.key ]]; then
  echo "Generating controller key/csr..."
  openssl genrsa -out certs/controller.key 2048
  openssl req -new -key certs/controller.key -subj "/CN=controller.local" -out certs/controller.csr
  openssl x509 -req -in certs/controller.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/controller.crt -days 365
fi

if [[ ! -f certs/agent.key ]]; then
  echo "Generating agent key/csr..."
  openssl genrsa -out certs/agent.key 2048
  openssl req -new -key certs/agent.key -subj "/CN=agent.local" -out certs/agent.csr
  openssl x509 -req -in certs/agent.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/agent.crt -days 365
fi

echo "Certificates ready in ./certs"

if [[ $NO_START -eq 1 ]]; then
  echo "Artifacts prepared. Exiting because --no-start was passed."
  exit 0
fi

echo "Building images and starting services..."
$DCMD build --pull --no-cache
$DCMD up -d

echo "Done. Controller should be available at http://localhost:8080 (if ports are free)."
echo "To watch agent logs: $DCMD logs -f agent"
