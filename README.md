# App

## Rodando o projeto

Há 3 formas de executar o projeto, por ordem de:
- [Dev Containers](#install-devcontainer) (**recomendado**)
- [Docker compose](#install-docker)
- [Local](#install-local) (**não recomendado**)

### Dev Containers {#install-devcontainer}

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

### Docker compose {#install-docker}

TODO: Finalizar docker composer

### Local {#install-local}

Rodar o projeto não é oficialmente suportado, mas você pode executar o comando `bin/setup` e instalar as dependências necessárias conforme necessário.
