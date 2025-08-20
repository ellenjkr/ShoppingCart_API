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
Tornar arquivos executáveis:
```bash
chmod +x bin/docker-entrypoint
chmod +x bin/rails
chmod -R +x bin
```

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
