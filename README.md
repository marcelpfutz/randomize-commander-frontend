# Randomize Commander - Frontend

Aplicação Angular para visualizar comandantes aleatórios de Magic: The Gathering.

## 🚀 Deploy em Produção (AWS)

### Guias Disponíveis

- **[📖 GUIA_RAPIDO_FRONTEND.md](GUIA_RAPIDO_FRONTEND.md)** - Deploy em 3 passos simples
- **[📚 DEPLOY_FRONTEND_AWS.md](DEPLOY_FRONTEND_AWS.md)** - Documentação completa
- **[✅ CHECKLIST_FRONTEND.md](CHECKLIST_FRONTEND.md)** - Checklist detalhado
- **[📁 deploy/](deploy/)** - Scripts e configurações

### Deploy Rápido

```bash
# 1. Configure a URL da API
# Edite: src/environments/environment.production.ts
# Deixe: apiUrl: '/api'

# 2. Build + Deploy em um comando
./deploy/build-and-deploy.sh ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190
```

**Veja o [GUIA_RAPIDO_FRONTEND.md](GUIA_RAPIDO_FRONTEND.md) para instruções detalhadas.**

---

## 🛠️ Desenvolvimento Local

### Requisitos

- Node.js 18+
- npm 9+

### Instalação

```bash
# Instalar dependências
npm install

# Rodar servidor de desenvolvimento
npm start

# Acessar em: http://localhost:4200
```

### Scripts Disponíveis

```bash
# Desenvolvimento
npm start              # Servidor de desenvolvimento (porta 4200)
npm run watch          # Build incremental com watch

# Build
npm run build          # Build de produção (dist/browser/)

# Testes
npm test               # Executar testes
```

---

## 📦 Estrutura do Projeto

```
src/
├── app/
│   ├── _components/
│   │   ├── home/              # Componente principal
│   │   └── commander-detail/  # Detalhes do comandante
│   ├── _services/
│   │   └── commander.service.ts  # Service da API
│   ├── app.ts                 # Componente raiz
│   └── app.routes.ts          # Rotas
├── environments/
│   ├── environment.ts              # Desenvolvimento
│   ├── environment.local.ts        # Local
│   └── environment.production.ts   # Produção
├── index.html
├── main.ts
└── styles.css
```

---

## ⚙️ Configuração

### Ambientes

**Desenvolvimento** (`environment.ts`):
```typescript
apiUrl: 'http://127.0.0.1:8000/api'
```

**Produção** (`environment.production.ts`):
```typescript
apiUrl: '/api'  // Proxy via Nginx
```

### Build de Produção

```bash
npm run build
```

Gera arquivos otimizados em `dist/browser/`:
- Minificação
- Tree-shaking
- AOT compilation
- Lazy loading

---

## 🚀 Deploy

### Pré-requisitos

1. Backend deployado na mesma instância
2. Nginx instalado
3. Build de produção criado

### Processo

```bash
# 1. Build
npm run build

# 2. Deploy
./deploy/deploy-frontend.sh ~/.ssh/sua-chave.pem ubuntu@IP

# 3. Verificar
curl http://IP/
```

### Estrutura no Servidor

```
/var/www/randomize-commander-frontend/
└── dist/
    ├── index.html
    ├── main-*.js
    ├── polyfills-*.js
    └── styles-*.css
```

---

## 🌐 URLs

### Desenvolvimento
- Frontend: `http://localhost:4200`
- Backend: `http://localhost:8000`

### Produção
- Frontend: `http://SEU-IP/`
- API (via proxy): `http://SEU-IP/api/`

---

## 📝 Dependências Principais

- **Angular**: 20.3.0
- **RxJS**: 7.8.0
- **Tailwind CSS**: 3.4.18
- **TypeScript**: 5.9.2

Veja `package.json` para lista completa.

---

## 🧪 Testes

```bash
# Executar testes unitários
npm test

# Testes com coverage
npm test -- --code-coverage
```

---

## 🎨 Estilização

- **Framework CSS**: Tailwind CSS
- **Configuração**: `tailwind.config.js`
- **Estilos globais**: `src/styles.css`

---

## 🔧 Comandos Úteis de Deploy

```bash
# Build + Deploy
./deploy/build-and-deploy.sh ~/.ssh/chave.pem ubuntu@IP

# Deploy rápido (sem rebuild)
./deploy/quick-deploy-frontend.sh ~/.ssh/chave.pem ubuntu@IP

# Ver logs
ssh -i ~/.ssh/chave.pem ubuntu@IP "sudo tail -f /var/log/nginx/access.log"
```

---

## 🐛 Troubleshooting

### Erro ao conectar com API

**Problema**: API não responde

**Solução**:
1. Verifique se backend está rodando: `sudo systemctl status randomize-backend`
2. Teste API diretamente: `curl http://localhost:8000/api/commander`
3. Verifique logs: `sudo journalctl -u randomize-backend -f`

---

### Erro 404 ao recarregar página

**Problema**: Nginx não redireciona rotas para index.html

**Solução**: Configuração do Nginx já inclui `try_files $uri $uri/ /index.html;`

Se persistir:
```bash
sudo nginx -t
sudo systemctl restart nginx
```

---

### Erros de CORS

**Problema**: Backend bloqueando requisições

**Solução**: Use `apiUrl: '/api'` em `environment.production.ts` (recomendado)

Ou adicione origem no backend:
```python
allow_origins=["http://SEU-IP"]
```

---

## 📚 Recursos

- [Angular Documentation](https://angular.io/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [RxJS](https://rxjs.dev/)

---

## 🤝 Contribuindo

1. Clone o repositório
2. Instale dependências: `npm install`
3. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
4. Faça suas alterações
5. Teste localmente: `npm start`
6. Commit: `git commit -m "Descrição"`
7. Push: `git push origin feature/nova-funcionalidade`
8. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT.

---

## 🔗 Links Relacionados

- [Backend Repository](../randomize-commander-backend/)
- [Scryfall API](https://scryfall.com/docs/api)
- [EDHREC](https://edhrec.com)
