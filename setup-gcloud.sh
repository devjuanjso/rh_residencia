#!/bin/bash
# Setup da VM Google Cloud (Ubuntu 22.04)
# Rode uma única vez após conectar na VM:
#   bash setup-gcloud.sh

set -e

echo "==> Atualizando sistema..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "==> Instalando Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"
sudo apt-get install -y docker-compose-plugin git

echo "==> Abrindo porta 8000 no firewall do Ubuntu..."
sudo ufw allow OpenSSH
sudo ufw allow 8000/tcp
sudo ufw --force enable

echo ""
echo "=========================================="
echo "  Setup concluído!"
echo "=========================================="
echo ""
echo "PRÓXIMOS PASSOS:"
echo ""
echo "1. Clone o projeto:"
echo "   git clone https://github.com/devjuanjso/rh_residencia.git"
echo "   cd rh_residencia"
echo ""
echo "2. Crie o .env:"
echo "   cp backend/.env.example backend/.env"
echo "   nano backend/.env"
echo "   --> troque SEU_IP_EXTERNO_GOOGLE_CLOUD pelo IP da VM"
echo ""
echo "3. Aplique as permissões e suba tudo:"
echo "   newgrp docker"
echo "   docker compose up -d --build"
echo ""
echo "4. Acompanhe o download dos modelos (~10-15 min):"
echo "   docker compose logs -f ollama-init"
echo ""
echo "IMPORTANTE: abra também a porta 8000 no Google Cloud Console:"
echo "  VPC Network > Firewall > Create Firewall Rule"
echo "  - Nome: allow-8000"
echo "  - Direção: Entrada (Ingress)"
echo "  - Destino: All instances"
echo "  - IP de origem: 0.0.0.0/0"
echo "  - Protocolo TCP, porta 8000"
echo "=========================================="
