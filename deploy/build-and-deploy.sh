#!/bin/bash

# Script completo: Build + Deploy
# Uso: ./build-and-deploy.sh <chave.pem> <usuario@ip-servidor>

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [ "$#" -ne 2 ]; then
    print_error "Uso: $0 <chave.pem> <usuario@ip-servidor>"
    print_error "Exemplo: $0 ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190"
    exit 1
fi

SSH_KEY=$1
SERVER=$2

# Determinar diretório do projeto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

print_info "======================================"
print_info "Build + Deploy - Frontend Angular"
print_info "======================================"
print_info ""

# Navegar para o diretório do projeto
cd "$PROJECT_DIR"

# Build
print_step "Executando build de produção..."
if npm run build; then
    print_info "Build concluído com sucesso! ✓"
else
    print_error "Falha no build"
    exit 1
fi

# Deploy
print_step "Iniciando deploy..."
if "$SCRIPT_DIR/deploy-frontend.sh" "$SSH_KEY" "$SERVER"; then
    print_info ""
    print_info "======================================"
    print_info "Build + Deploy concluído! ✓"
    print_info "======================================"
    print_info ""
    print_info "🌐 Acesse: http://$(echo $SERVER | cut -d'@' -f2)/"
else
    print_error "Falha no deploy"
    exit 1
fi
