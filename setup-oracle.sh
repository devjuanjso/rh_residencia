#!/bin/bash
# Setup da VM Oracle Cloud Free Tier (Ubuntu 22.04 ARM)
# Rode uma única vez após criar a VM:
#   bash setup-oracle.sh

set -e

echo "==> Atualizando sistema..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "==> Instalando Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"
sudo apt-get install -y docker-compose-plugin

echo "==> Abrindo portas no firewall do Ubuntu..."
sudo ufw allow OpenSSH
sudo ufw allow 8000/tcp
sudo ufw --force enable

echo ""
echo "=========================================="
echo "  Docker instalado!"
echo "=========================================="
echo ""
echo "PRÓXIMOS PASSOS:"
echo ""
echo "1. Crie o arquivo de variáveis de ambiente:"
echo "   cp backend/.env.example backend/.env"
echo "   nano backend/.env"
echo ""
echo "2. Suba todos os serviços:"
echo "   newgrp docker"
echo "   docker compose up -d --build"
echo ""
echo "3. Acompanhe o download dos modelos de IA (pode demorar ~10 min):"
echo "   docker compose logs -f ollama-init"
echo ""
echo "IMPORTANTE: abra também a porta 8000 no painel Oracle Cloud:"
echo "  Networking > Virtual Cloud Networks > Security Lists > Add Ingress Rule"
echo "  Protocolo: TCP | Porta de destino: 8000 | Origem: 0.0.0.0/0"
echo "=========================================="
