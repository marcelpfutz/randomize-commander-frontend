# ✅ Checklist de Deploy - Frontend Angular

## Pré-Deploy

- [ ] Backend deployado e funcionando
- [ ] Nginx instalado no servidor (já foi no setup do backend)
- [ ] Node.js instalado localmente
- [ ] Chave SSH disponível
- [ ] IP público anotado

## Configuração Local

- [ ] Editar `src/environments/environment.production.ts`
- [ ] Configurar `apiUrl` corretamente:
  - [ ] Opção 1: `/api` (recomendado - sem CORS)
  - [ ] Opção 2: `http://SEU-IP/api` ou `https://dominio.com/api`
- [ ] Salvar alterações

## Build

- [ ] Instalar dependências: `npm install`
- [ ] Executar build: `npm run build`
- [ ] Verificar se `dist/browser/` foi criado
- [ ] Verificar se `dist/browser/index.html` existe

## Deploy

- [ ] Executar script: `./deploy/deploy-frontend.sh ~/.ssh/note-pessoal.pem ubuntu@IP`
- [ ] Aguardar conclusão do script
- [ ] Verificar se não houve erros

## Verificação

- [ ] Acessar site no navegador: `http://SEU-IP/`
- [ ] Verificar se a página carrega corretamente
- [ ] Testar navegação entre rotas
- [ ] Testar funcionalidade que chama a API
- [ ] Verificar console do navegador (sem erros)
- [ ] Testar em diferentes navegadores (Chrome, Firefox)

## API e CORS

Se usou URL absoluta (`http://SEU-IP/api`):
- [ ] Editar `app/main.py` no backend
- [ ] Adicionar IP/domínio do frontend em `allow_origins`
- [ ] Deploy do backend: `./deploy/quick-deploy.sh ...`
- [ ] Reiniciar backend: `sudo systemctl restart randomize-backend`

## Nginx

- [ ] Verificar status: `sudo systemctl status nginx`
- [ ] Testar configuração: `sudo nginx -t`
- [ ] Ver logs sem erros: `sudo tail /var/log/nginx/error.log`

## Testes Funcionais

- [ ] Página inicial carrega
- [ ] Botão "Randomizar" funciona
- [ ] Dados do comandante aparecem
- [ ] Imagem do comandante carrega
- [ ] Tags/links aparecem corretamente
- [ ] Sem erros no console do navegador
- [ ] Sem erros 404 ou 500

## Segurança (Opcional)

- [ ] Configurar domínio no Route 53 (se aplicável)
- [ ] Instalar SSL com Let's Encrypt
- [ ] Atualizar `apiUrl` para HTTPS
- [ ] Rebuild e redeploy
- [ ] Testar com HTTPS

## Pós-Deploy

- [ ] Documentar credenciais e URLs
- [ ] Testar do celular/tablet
- [ ] Compartilhar URL com usuários de teste
- [ ] Monitorar logs por alguns dias
- [ ] Configurar backup automático

## Troubleshooting

Se algo der errado:

### Site não carrega (404)
```bash
# Verificar arquivos
ssh -i ~/.ssh/note-pessoal.pem ubuntu@IP \
  "ls -la /var/www/randomize-commander-frontend/dist/"

# Verificar Nginx
ssh -i ~/.ssh/note-pessoal.pem ubuntu@IP "sudo nginx -t"
ssh -i ~/.ssh/note-pessoal.pem ubuntu@IP "sudo systemctl status nginx"
```

### API não responde
```bash
# Testar backend
ssh -i ~/.ssh/note-pessoal.pem ubuntu@IP \
  "curl http://localhost:8000/api/commander"

# Verificar backend
ssh -i ~/.ssh/note-pessoal.pem ubuntu@IP \
  "sudo systemctl status randomize-backend"
```

### Erro 404 ao recarregar
- Configuração do Nginx deve ter `try_files $uri $uri/ /index.html;`
- Já está incluído no `nginx-frontend.conf`

### Erros de CORS
- Se usando URL absoluta, adicione origem no backend
- Ou use `/api` (caminho relativo) no `environment.production.ts`

## Comandos Rápidos

```bash
# Ver logs Nginx
ssh -i ~/.ssh/note-pessoal.pem ubuntu@IP \
  "sudo tail -f /var/log/nginx/randomize-frontend-access.log"

# Reiniciar Nginx
ssh -i ~/.ssh/note-pessoal.pem ubuntu@IP \
  "sudo systemctl restart nginx"

# Testar site
curl http://IP/

# Testar API
curl http://IP/api/commander

# Deploy rápido
npm run build && ./deploy/quick-deploy-frontend.sh ~/.ssh/note-pessoal.pem ubuntu@IP
```

## URLs Importantes

- **Frontend**: `http://34.232.80.190/`
- **API**: `http://34.232.80.190/api/`
- **Backend Health**: `http://34.232.80.190/health`

## Custos Mensais

- t3.small: ~$15
- Storage (30GB): ~$3
- **Total**: ~$20/mês (backend + frontend na mesma instância)

---

**Dica**: Salve este checklist e marque os itens conforme avança! ✅
