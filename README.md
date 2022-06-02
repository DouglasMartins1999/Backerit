# Backerit - Secure Backup using Docker & Git



## O que é?

O Backerit é uma leve e simples ferramenta self-hosted que possibilita fazer cópias de arquivos (backups) criptografados à repositórios git remotos por meio de um container docker. O Backerit tanto é capaz de monitorar mudanças em arquivos quanto agendar backups periódicos, mantém intactas as permissões e suporta conexão a repositórios git tanto por HTTPS quanto por SSH. Disponível tanto para arquitetura x86-x64 quanto para arm64 - ou seja, é possível usar o Backerit até mesmo em um Raspberry Pi :)



## Como usar?

Esse repositório disponibiliza um docker-compose.yml de exemplo. Em essência, a configuração do Backerit é bem simples: basta você definir algumas variáveis de ambiente e mapear as pastas que deseja copiar da máquina host como volumes para dentro do container. 

No entanto, para fazer a criptografia dos arquivos, é necessário uma chave privada (usada para decriptografar) e um certificado (usado na criptografia). Se estiver em um PC com o openssl instalado, esse comando deve ser suficiente para gerar os arquivos:

```shell
openssl req -nodes -newkey rsa:2048 -x509 -keyout backup.key -out backup.crt
```

> **Atenção**: Mantenha esses arquivos em local seguro. Não será possível restaurar os backups sem eles


Para disponibilizar os arquivos dentro do container, mapeie o certificado para `/workspace/config/keys/backup.crt` e a chave privada para `/workspace/config/keys/backup.key`. Não se esqueça de definir as permissões restritas para acesso dos arquivos.

> Não é necessário - **nem recomendado** - que os dois arquivos estejam mapeados dentro do container ao mesmo tempo - se não precisa restaurar o backup, mapeie apenas o certificado; se quer apenas restaurar, mapeie apenas a chave privada.



#### Pastas de backup

Dentro do container, o backup é feito a partir de duas pastas. A pasta `/workspaces/backup/monitoring` irá salvar uma nova versão a cada mudança nos arquivos dentro dela. O Backerit monitora os eventos de criação, exclusão e escrita de arquivos, bem como a alteração de metadados (permissões, por ex), e a movimentação de arquivos entre as pastas. 

Para fazer backups periódicos, o volume deve ser montado dentro de  `/workspaces/backup/scheduleds`. Para definir a periodicidade dos backups, é necessário mapear um arquivo .csv, cuja primeira coluna representa a pasta dentro do container que deverá ser salva - relativa a `/workspaces/backup/scheduleds` , e a segunda coluna representa uma expressão POSIX *cron* com a frequência das cópias. A primeira linha é ignorada, pois deve conter o header do csv. O arquivo deve ser mapeado para dentro do container e o caminho absoluto deve ser informado na variável de ambiente `SCHED_FILE`.



#### Configuração do Git

Há três variáveis de ambiente que são obrigatórias para a configuração do git: `GIT_EMAIL`, `GIT_USERNAME`, `GIT_REMOTE_URL`, contendo respectivamente, o email e nome de usuário salvos nos commits, e a URL do repositório remoto. Para acesso via HTTP, o nome de usuário e senha deve ser informado na URL. Por ex: https://username:password@github.com/username/repository/

Para acesso SSH, a URL deve iniciar com ssh://, e a chave deve ser mapeada para `/workspace/config/keys/ssh.key`. Você pode, opcionalmente, informar o nome da branch a ser usada no backup definindo a variável `GIT_BRANCH`, que por padrão tem o valor *main*. Por fim, se o repositório remoto não tiver nenhum arquivo backup, você pode definir a variável `SYNC_ON_INIT` como true para que o Backerit force o backup e push de todos os arquivos ao iniciar.



#### Como restaurar o backup?

Para restaurar, o git deve estar corretamente configurado, e a chave privada gerada junto ao certificado deve estar mapeada dentro do container para o caminho correto. A restauração do backup irá copiar e decriptografar o repositório remoto para a pasta `/workspace/restore`, criando as pastas monitoring e scheduleds. Crie os volumes necessários das subpastas para as pastas originais na máquina host. Por fim, execute o comando `restore` dentro do container:

```shell
docker exec -it [nome_do_container] back-restore
```



#### Como forçar a sicronização do backup?

O git deve estar configurado corretamente e o certificado de criptografia deve estar mapeado no container. Execute o comando sync dentro do container:

```shell
docker exec -it [nome_do_container] back-sync
```

Isso fará o pull do repositório remoto para uma pasta temporária dentro do container, criptografará o conteúdo das pastas monitoring e scheduleds e fará um commit com as alterações.



### Variáveis de Ambiente

A maior parte das pastas e nomes de arquivos do container podem ser customizados usando variáveis de ambiente, no entanto, tal modificação deve ser feita apenas se necessário e com compreensão de seus efeitos. Abaixo, uma tabela com as variáveis de ambiente disponíveis, sua função e valor padrão:


| VARIÁVEL       | FUNÇÃO                                                       | VALOR PADRÂO                      |
| -------------- | :----------------------------------------------------------- | --------------------------------- |
| GIT_BRANCH     | Definir nome da branch a ser usada nos backups               | main                              |
| GIT_WORK_TREE  | Diretório com repositório git dentro do container            | /workspace/config/repo            |
| GIT_DIR        | Diretório .git dentro do container                           | /workspace/config/repo/.git       |
| GIT_EMAIL      | Email usado nos commits                                      |                                   |
| GIT_USERNAME   | Nome usado nos commits                                       |                                   |
| GIT_REMOTE_URL | URL do repositório remoto                                    |                                   |
| GIT_SSH_KEY    | Localização da Chave SSH para acesso remoto do repositório   | /workspace/config/keys/ssh.key    |
| SYNC_ON_INIT   | Caso definida, o Backerit fará push dos arquivos locais a cada inicialização |                                   |
| MONITOR_PATH   | Diretório com os arquivos a monitorar por mudanças           | /workspace/backup/monitoring      |
| SCHED_PATH     | Diretório raiz dos arquivos a serem salvos por agendamentos  | /workspace/backup/scheduleds      |
| RESTORE_PATH   | Diretório a restaurar o backup                               | /workspace/restore                |
| KEYS_DIR       | Diretório a salvar temporariamente as chaves simétricas de criptografia | /workspace/config/.keys           |
| CRON_FILE      | Localização do arquivo do crontab criado automaticamente usando o csv | /workspace/config/.cron           |
| SCHED_FILE     | Localização do arquivo .csv para criar programação de backup |                                   |
| SYNC_MAIN      | Localização da chave privada principal de criptografia       | /workspace/config/keys/backup.key |
| SYNC_CERT      | Localização do certificado de criptografia                   | /workspace/config/keys/backup.crt |



### Como funciona o Backerit?

O Backerit é uma ferramenta escrita inteiramente em Shell Script `[#!/bin/sh]` usando como base uma imagem [docker do Ubuntu 22.04](https://hub.docker.com/_/ubuntu?tab=tags). Ele usa o [inotify-tools](https://linux.die.net/man/1/inotifywait) para monitorar os arquivos em uma pasta específica, ou o [crontab](https://linux.die.net/man/1/crontab) aliado ao [cron](https://en.wikipedia.org/wiki/Cron), para indicar ao [rsyncrypto](https://rsyncrypto.lingnu.com/index.php?title=Main_Page) que deve copiar os arquivos de uma pasta X para Y, criptografando-os no processo - sendo a pasta Y um repositório git [com hooks configurados](https://github.com/dr4Ke/git-preserve-permissions/) para manter as permissões dos arquivos ao enviar ou receber arquivos do repositório remoto.