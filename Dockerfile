FROM debian:stretch-slim

ARG KM_VERSION
ARG DCOS_URL
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && mkdir -p /usr/share/man/man1/ \
 && apt-get install --no-install-recommends -y openjdk-8-jdk unzip git wget

# Install kafka-manager
RUN mkdir -p /app \
 && mkdir -p /tmp \
 && cd /tmp \
 && git clone https://github.com/yahoo/kafka-manager \
 && cd /tmp/kafka-manager \
 && git checkout tags/${KM_VERSION} \
 && ./sbt clean dist \
 && unzip -d /tmp ./target/universal/kafka-manager-${KM_VERSION}.zip \
 && mv /tmp/kafka-manager-${KM_VERSION}/* /app/ \
 && rm -rf /tmp/kafka-manager* \
 && rm -rf /app/share/doc

# Add dcos-ca cert to cacerts
RUN mkdir ${MESOS_SANDBOX}/security \
 && cd ${MESOS_SANDBOX}/security \
 && wget ${DCOS_URL}/ca/dcos-ca.crt \
 && keytool -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts -noprompt -storepass changeit -alias CARoot -importcert -file dcos-ca.crt

# Clean up
RUN apt-get remove -y unzip git wget \
 && apt-get autoremove -y \
 && apt-get clean

COPY entrypoint.sh /app/
COPY application.conf /app/conf/
COPY logback.xml /app/conf/

WORKDIR /app
EXPOSE 9000
ENTRYPOINT ["./entrypoint.sh"]
