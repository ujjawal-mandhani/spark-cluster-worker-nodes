FROM openjdk:8
ENV SCALA_VERSION 2.13.6
ENV SCALA_HOME /usr/local/share/scala
RUN curl -fL "https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz" | tar xfz - -C /usr/local/share && \
    mv "/usr/local/share/scala-$SCALA_VERSION" "$SCALA_HOME" && \
    ln -s "$SCALA_HOME/bin/"* "/usr/local/bin/"
RUN apt-get update -y && apt-get install apt-transport-https curl gnupg -yqq && echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && curl -L "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import && chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg && apt-get update -y && apt-get install sbt -y

ENV SPARK_VERSION 3.3.1
ENV SPARK_HOME /usr/local/share/spark
RUN curl -fL "https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop3.tgz" | tar xfz - -C /usr/local/share && \
    mv "/usr/local/share/spark-$SPARK_VERSION-bin-hadoop3" "$SPARK_HOME"
ENV PATH "$PATH:$SPARK_HOME/bin"
COPY ./infinite/ /home/infinite
RUN apt-get update && apt-get install -y openssh-server
COPY sshd_config /etc/ssh/sshd_config
COPY ssh_config /etc/ssh/ssh_config
COPY spark-env.sh /usr/local/share/spark/conf/spark-env.sh
COPY slaves /usr/local/share/spark/conf/slaves
CMD [ "sh", "-c", "service ssh start && python3 /home/infinite/infinite.py"]

# commands to execute
# docker build . -t scala_image
# docker run -it -v "./Volume/:/home" --name=scala_cont scala_image
# spark-shell --driver-memory 1g --executor-memory 1g --packages org.postgresql:postgresql:42.1.1,com.microsoft.sqlserver:mssql-jdbc:9.4.0.jre8
