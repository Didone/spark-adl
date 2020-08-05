#!/usr/bin/env bash
# Configure Azure Datalake Storage Support
if [[ ! -z "$AZ_TOKEN_ENDPOINT" ]] && [[ ! -z "$AZ_CLIENT_ID" ]] && [[ ! -z "$AZ_CLIENT_SECRET" ]]; then
    echo "Azure DLS Support: true" && echo -e "#Azure DLS Support
spark.hadoop.fs.adl.impl org.apache.hadoop.fs.adl.AdlFileSystem
spark.hadoop.fs.AbstractFileSystem.adl.impl org.apache.hadoop.fs.adl.Adl
spark.hadoop.dfs.adls.oauth2.access.token.provider.type ClientCredential
spark.hadoop.dfs.adls.oauth2.access.token.provider org.apache.hadoop.fs.adls.oauth2.ConfCredentialBasedAccessTokenProvider
spark.hadoop.dfs.adls.oauth2.refresh.url ${AZ_TOKEN_ENDPOINT}
spark.hadoop.dfs.adls.oauth2.client.id ${AZ_CLIENT_ID}
spark.hadoop.dfs.adls.oauth2.credential ${AZ_CLIENT_SECRET}
" >> ${SPARK_HOME}/conf/spark-defaults.conf
fi
# Start thrift for JDBC Connections
# $SPARK_HOME/sbin/start-thriftserver.sh
# Continue
exec "$@"
