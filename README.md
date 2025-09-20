# Frame and Circle API

Este repositório é um teste de código simulando uma API.

## Rodando o projeto

Há 3 formas de executar o projeto:
- [Dev Containers](#dev-container) (**recomendado**)
- [Docker compose](#docker-compose)
- [Local](#local) (**não recomendado**)

### Dev Container

Rodar o projeto dentro de um devcontainer é a forma mais prática de ter todas as dependências instaladas e configuradas.
Se você usa o [VScode](https://code.visualstudio.com/), ele mesmo executa e configura o devcontainer, mas você pode utilizar o [Devcontainer CLI](https://github.com/devcontainers/cli) para executar o container pelo terminal ou em outra IDE.

Para iniciar o container, basta executar o comando:
```bash
$ devcontainer up --workspace-folder .
```

Com o container configurado e rodando, basta utilizar o comando `exec` para interagir com o Rails:
```bash
$ devcontainer exec --workspace-folder . bin/rails dev
```

### Docker compose

Para executar o projeto via Docker, basta executar o comando:

```bash
$ docker compose up
```

### Local

Rodar o projeto localmente pode depender das dependências e pacotes instalados no seu sistema operacional. Tendo a versão correta do Ruby e o PostgresSQL server instalado, basta executar o comando `bin/rails setup` para configurar o ambientes.

## Documentação da API

A documentação da API é gerada através dos testes e da gem `rswag`, e se encontra em http://localhost:3000/api-docs

Após alterar a API, é necessário gerar a documentação novamente:

```bash
$ bin/rake rswag:specs:swaggerize
```

## Testes

Os testes são feitos via `rspec`:

```bash
$ bundle exec rspec
```

O teste gera a cobertura de código automaticamente, bastando acessar o relatório em `coverage/index.html`.
