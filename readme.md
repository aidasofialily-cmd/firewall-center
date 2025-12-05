# Firewall Center Installer (demo)

This scaffold provides a minimal "Firewall Center" installer that deploys a demo controller and a demo agent using Docker Compose.

Purpose
- Quick demo and installer flow to bootstrap a controller + agent environment.
- Safe: the agent prints policy actions instead of modifying system firewall rules.
- Extendable: you can replace the controller and agent logic with production code (nft/iptables/WFP) and expand the installer to produce OS packages.

Contents
- install.sh — installer script to prepare certs, build images, and run docker-compose.
- docker-compose.yml — local Compose file that builds `controller` and `agent`.
- controller/ — demo controller Flask app.
- agent/ — demo agent Flask app.
- systemd/firewall-center-agent.service — example unit file for native agent install.

Requirements (for this demo)
- Linux (recommended). macOS / WSL may work for Docker but systemd unit is Linux-only.
- Docker Engine (20.x+) and docker-compose (or Compose V2 plugin).
- Bash, openssl.

Quick start (demo)
1. Make script executable:
   chmod +x install.sh

2. Run the installer (default: docker-compose):
   sudo ./install.sh

3. After install:
   - Controller UI/API: http://localhost:8080
     - Health: GET /health
     - Policies: GET/POST /api/v1/policies
   - Agent logs:
     docker-compose logs -f agent
   - To tear down:
     docker-compose down

Notes & Next steps
- The demo agent only prints policies. For production replace agent/app.py logic to apply nftables/iptables/WFP rules and implement reconciliation.
- For production installer options:
  - Create distribution packages (deb/rpm) for the agent.
  - Use systemd unit to run agent as a service and make it auto-update.
  - Use proper TLS (CA-signed certs) and mTLS for agent <-> controller authentication.
  - Harden image builds and scanning, enable RBAC and OIDC in the controller, and persist data to Postgres.
- If you want, I can:
  - Extend the installer to produce deb/rpm packages (fpm-based).
  - Add systemd/service install flow and auto-start configuration.
  - Replace demo policy printing with real nftables calls and safe dry-run mode.
  - Add Helm charts for Kubernetes deployment.

If you want me to push this to a GitHub repo, tell me the owner/name and I will prepare a push (I'll need explicit repo info and permission). Below are the scaffolded files.
