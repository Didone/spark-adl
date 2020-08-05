# Azure Spark

Disponível no repoistório padrão do [Docker Hub](https://hub.docker.com/r/didone/spark-adl), a imagem pode ser baixada atrés do comando abaixo:

```sh
docker pull didone/spark-adl
```

## Build

Caso queira fazer seu proprio build, execute o comando abaixo, a partir do diretório de checkout do projeto

```sh
docker image build -t spark-adl .
```

## Execute

Crie um arquivo `.env` para armazenar as credenciais da Azure que serão utilziadas pelo Sparck para conexão ao Data Lake Storage.

```env
AZ_CLIENT_ID=<your-oauth2-client-id>
AZ_CLIENT_SECRET=<your-oauth2-credential>
AZ_TOKEN_ENDPOINT=https://login.microsoftonline.com/<your-directory-id>/oauth2/token
```

Uma vez configuradas as chaves de acesso ao *cloud storage*  você pode acessar o console do Spark com o comando abaixo:

```sh
docker run --env-file .env -it --rm -p 4040:4040 didone/spark-adl
```

```log
Spark context Web UI available at http://ff12ea874804:4040
Spark context available as 'sc' (master = local[*], app id = local-1596643921689).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.0.0
      /_/

Using Scala version 2.12.10 (OpenJDK 64-Bit Server VM, Java 1.8.0_265)
Type in expressions to have them evaluated.
Type :help for more information.

scala>
```

O console do Spark UI ficará acessível através da porta `4040` do seu *localhost*

### SQL

Para a execução de consultas pode ser utilizado o console `spark-sql`

```sh
docker run --env-file .env -it --rm -p 4040:4040 didone/spark-adl spark-sql
```

Ou então inicializar o *Thrift Server* para realizar consultar através de um conector *JDBC* no endereço `jdbc:hive2://127.0.0.1:10000/default`

```sh
docker run --env-file .env -it --rm -p 4040:4040 -p 10000:10000 didone/spark-adl start-thriftserver.sh
```

> É necessário mapear a porta **10000** para que seja possível a conexão com o servidor *Thrift*

```sql
SELECT *
  FROM parquet.`adl://my.azuredatalakestore.net/table/partition/0395a2d514ef-c000.snappy.parquet`
;
```
