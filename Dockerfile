FROM debian
LABEL maintainer="didone"
LABEL project="GetNet"
RUN echo "Update SO"
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    curl git wget gnupg2 build-essential software-properties-common apt-transport-https ca-certificates
# Java
RUN echo "Install Java" && \
    wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
    apt-get update && apt-get install -y adoptopenjdk-8-hotspot
ENV JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64
# Azure
RUN echo "Install Azure Tools" && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null && \
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" && \
    apt-get update && apt-get install --no-install-recommends -y azure-cli
# Paths
ENV SPARK_HOME=/usr/local/spark\
    HADOOP_HOME=/usr/local/hadoop\
    MAVEN=https://repo1.maven.org/maven2\
    APACHE=https://archive.apache.org/dist
# Versions
ENV SPARK=3.0.0\
    DELTA=0.7.0\
    SCALA=2.12\
    SBT=0.13.17\
    HADOOP=3.2
# Spark
ENV SPARK_BIN="${APACHE}/spark/spark-${SPARK}/spark-${SPARK}-bin-hadoop${HADOOP}.tgz"
RUN echo "Install Spark ${SPARK}" && echo "Downloading Spark from ${SPARK_BIN}" && \
    curl --retry 3 "${SPARK_BIN}"| tar -xz -C /usr/local/ && \
    ln -s /usr/local/spark-${SPARK}-bin-hadoop${HADOOP} ${SPARK_HOME}
ENV PATH=$PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
# Scala
RUN echo "Install Scala ${SCALA}" && \
    wget -q -c "https://downloads.lightbend.com/scala/${SCALA}.10/scala-${SCALA}.10.deb" && dpkg -i "scala-${SCALA}.10.deb"
# Configs
RUN echo "spark.jars.packages \
io.delta:delta-core_${SCALA}:${DELTA},\
org.apache.hadoop:hadoop-common:${HADOOP}.0,\
org.apache.hadoop:hadoop-azure-datalake:${HADOOP}.0\n\
spark.sql.extensions io.delta.sql.DeltaSparkSessionExtension\n\
spark.sql.catalog.spark_catalog org.apache.spark.sql.delta.catalog.DeltaCatalog\n\
" > ${SPARK_HOME}/conf/spark-defaults.conf
RUN echo "System.exit(0)" > init && spark-shell -i init
# Sbt
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add && \
    apt-get update && apt-get install sbt -y && sbt --version
# Start script
ADD scripts/*.sh ${SPARK_HOME}/sbin
ENTRYPOINT ["adls.sh"]
CMD ["spark-shell"]