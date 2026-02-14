# Scripts de Deploy - Frontend Angular

Este diretório contém scripts e configurações para deploy do frontend na AWS.

## 📁 Arquivos

### Scripts

- **`deploy-frontend.sh`** - Script principal de deploy
- **`quick-deploy-frontend.sh`** - Deploy rápido (apenas arquivos)

### Configurações

- **`nginx-frontend.conf`** - Configuração do Nginx para servir o frontend

## 🚀 Como Usar

### 1. Build da Aplicação

```bash
# No diretório do frontend
cd /home/marcel/projetos/randomize-commander-frontend

# Configure a URL da API (IMPORTANTE!)
# Edite: src/environments/environment.production.ts
# Altere apiUrl para: '/api' (recomendado) ou 'http://SEU-IP/api'

# Build de produção
npm run build
```

### 2. Deploy Completo

```bash
# Execute o script de deploy
./deploy/deploy-frontend.sh ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190
```

### 3. Atualizações Futuras

```bash
# 1. Rebuild
npm run build

# 2. Deploy rápido
./deploy/quick-deploy-frontend.sh ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190
```

## ⚙️ Configuração da API

### Opção 1: Caminho Relativo (Recomendado)

**`environment.production.ts`:**
```typescript
apiUrl: '/api'
```

**Vantagens:**
- ✅ Sem problemas de CORS
- ✅ Funciona em qualquer domínio/IP
- ✅ SSL automático quando frontend usa HTTPS

### Opção 2: URL Absoluta

**`environment.production.ts`:**
```typescript
apiUrl: 'http://34.232.80.190/api'  // Com IP
// ou
apiUrl: 'https://seu-dominio.com/api'  // Com domínio
```

**Desvantagens:**
- ⚠️ Precisa configurar CORS no backend
- ⚠️ Hardcoded para um endereço específico

## 🔧 Comandos Úteis

```bash
# Ver logs do Nginx
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo tail -f /var/log/nginx/randomize-frontend-access.log"

# Reiniciar Nginx
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo systemctl restart nginx"

# Testar configuração
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo nginx -t"
```

## 📊 Estrutura no Servidor

```
/var/www/randomize-commander-frontend/
├── dist/
│   ├── index.html
│   ├── main-*.js
│   ├── polyfills-*.js
│   └── styles-*.css
└── nginx-frontend.conf
```

## 🔗 Documentação

- **Guia Rápido**: `../GUIA_RAPIDO_FRONTEND.md`
- **Guia Completo**: `../DEPLOY_FRONTEND_AWS.md`

## ⚠️ Importante

1. **Sempre faça build antes do deploy**: `npm run build`
2. **Configure a URL da API** em `environment.production.ts`
3. **Atualize CORS no backend** se usar URL absoluta
4. **Teste no navegador** após o deploy

## 🎯 Workflow Típico

```bash
# 1. Fazer alterações no código
vim src/app/...

# 2. Testar localmente
npm start

# 3. Build de produção
npm run build

# 4. Deploy
./deploy/quick-deploy-frontend.sh ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190

# 5. Testar no navegador
curl http://34.232.80.190/
```
