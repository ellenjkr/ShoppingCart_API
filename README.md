# Projeto Rails - Carrinho de Compras

## Informações técnicas

### Dependências
- ruby 3.3.1
- rails 7.1.3.2
- postgres 16
- redis 7.0.15
- docker

### Gems adicionais
- redis-session-store
- factory_bot_rails
- byebug

### Como executar o projeto
Para erguer os containers:
```bash
docker compose up -d
```

Caso o servidor não suba devido a processos antigos do Rails, remova o `server.pid`:
```bash
docker compose run --rm web rm -f tmp/pids/server.pid
```

Para acessar a API:  
👉 [http://localhost:3000/](http://localhost:3000/)

Para rodar os testes:
```bash
docker compose run --rm test
```
---
### Soluções de Problemas
Podem ocorrer conflitos com a permissão dos arquivos. Esses conflitos podem ser corrigidos com os comandos abaixo:
```bash
chmod +x bin/*
docker compose -f docker-compose.yml build --no-cache
sudo chown -R $USER:$USER tmp log db db/schema.rb db/migrate
chmod 664 db/schema.rb
chmod -R 777 db log tmp
```

Caso ocorram erros com o CRLF/LF, devido a conversões do Git, é possível resolver aplicando uma dessas configurações:
https://stackoverflow.com/questions/1967370/git-replacing-lf-with-crlf
```bash
git config --system core.autocrlf false            # per-system solution
git config --global core.autocrlf false            # per-user solution
git config --local core.autocrlf false              # per-project solution
```

## Observações:
O teste 'describe "POST /add_items"' no arquivo spec/requests/carts_spec.rb foi modificado:
- **Rota corrigida** para `/add_item`, refletindo a rota real da aplicação.  
- **Carrinho persistido na sessão** com o seguinte trecho:
  ```ruby
  before do
    allow_any_instance_of(ActionDispatch::Request::Session)
      .to receive(:[]).with(:cart_id).and_return(cart.id)
  end
  ```

---





