#!/bin/bash
# Rode este script na VM Oracle Cloud após o primeiro git clone
# Uso: bash setup-oracle.sh

set -e

echo "==> Instalando Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

echo "==> Instalando Docker Compose plugin..."
sudo apt-get update -y
sudo apt-get install -y docker-compose-plugin

echo "==> Abrindo portas no firewall do Ubuntu..."
sudo ufw allow 8000/tcp
sudo ufw allow 8001/tcp
sudo ufw --force enable

echo ""
echo "IMPORTANTE: edite o arquivo backend/.env e troque a SECRET_KEY antes de continuar!"
echo "Use: nano backend/.env"
echo ""
echo "Depois rode: docker compose up -d"
echo "E acompanhe os modelos: docker compose logs -f ollama-init"
