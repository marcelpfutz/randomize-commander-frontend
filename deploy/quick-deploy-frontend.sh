#!/bin/bash

# Script de Deploy Rápido - Frontend
# Use após fazer alterações no código e rebuild
# Uso: ./quick-deploy-frontend.sh <chave.pem> <usuario@ip-servidor>

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [ "$#" -ne 2 ]; then
    print_error "Uso: $0 <chave.pem> <usuario@ip-servidor>"
    exit 1
fi

SSH_KEY=$1
SERVER=$2
APP_DIR="/var/www/randomize-commander-frontend"

# Determinar diretório do projeto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_DIR/dist/browser"

# Verificar se o build existe
if [ ! -d "$DIST_DIR" ]; then
    print_error "Diretório de build não encontrado: $DIST_DIR"
    print_error "Execute 'npm run build' antes de fazer o deploy"
    exit 1
fi

print_info "Deploy rápido iniciado..."

# Copiar arquivos
print_info "Copiando arquivos..."
rsync -avz --delete -e "ssh -i $SSH_KEY" \
    "$DIST_DIR/" "$SERVER:$APP_DIR/dist/"

# Recarregar Nginx
print_info "Recarregando Nginx..."
ssh -i "$SSH_KEY" "$SERVER" "sudo systemctl reload nginx"

print_info "Deploy rápido concluído! ✓"
print_info "Acesse: http://$(echo $SERVER | cut -d'@' -f2)/"
