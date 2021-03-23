# Payara for OTD DP on Docker with zulu jdk
FROM azul/zulu-openjdk:8u282 as payara-test

# Maintainer
LABEL maintainer="Fabian Schoeneborn <fabian.schoeneborn@sulzer.de"

# Set environment variables and default password for user 'admin'
ENV PAYARA_HOME=/payara41 \
    PATH=$PATH:/payara41/bin

ARG PASSWORD=admin
ARG JDK_VERSION=8u282
ARG PAYARA_VERSION=4.1.2.181
ARG DOMAIN_HOME=/payara41/glassfish/domains/test


USER root

# Install packages, download and extract Payara
RUN apt-get update && \
    apt-get install -y unzip

WORKDIR /
# Download payara
ADD https://repo1.maven.org/maven2/fish/payara/distributions/payara/${PAYARA_VERSION}/payara-${PAYARA_VERSION}.zip payara-${PAYARA_VERSION}.zip
RUN unzip -o payara-${PAYARA_VERSION}.zip && \
    rm payara-${PAYARA_VERSION}.zip


RUN echo "--- Create the domain ---" && \
    asadmin create-domain --portbase 7000 --keytooloptions CN=payara-test.docker --user admin --nopassword true test

ADD target/payara-property-bug-1.0-SNAPSHOT.war /test.war
RUN echo "--- Start server for running remote commands ---" && \
    asadmin start-domain test && \
    # switch property order if you want to see the difference
    asadmin --port 7048 create-system-properties 'test.payara.property.first=http\://\${test.payara.property.second}/test' && \
    asadmin --port 7048 create-system-properties 'test.payara.property.second=my.simple.domain' && \
    asadmin --port 7048 deploy --contextroot '/test' /test.war && \
    echo "--- Setup the password file ---" && \
    echo "AS_ADMIN_PASSWORD=" > /tmp/glassfishpwd && \
    echo "AS_ADMIN_NEWPASSWORD=${PASSWORD}" >> /tmp/glassfishpwd  && \
    echo "--- Enable DAS, change admin password, and secure admin access ---" && \
    asadmin --port 7048 --user=admin --passwordfile=/tmp/glassfishpwd change-admin-password --domain_name test && \
    echo "AS_ADMIN_ADMINPASSWORD=${PASSWORD}" > /tmp/glassfishpwd && \
    asadmin --port 7048 --user=admin --passwordfile=/tmp/glassfishpwd enable-secure-admin && \
    asadmin --port 7048 --user=admin stop-domain test

RUN echo " --- clean up  ---" && \
    apt-get remove -y unzip && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*
RUN groupadd -r test && useradd --no-log-init -r -g test test && \
    chown -R test:test /payara41 && \
    usermod -d /payara41 test

##squashing image
FROM scratch
COPY --from=payara-test / /
# Ports being exposed
EXPOSE 7048 7080 7201 7009
USER test
WORKDIR /payara41
# Start asadmin console and the domain
ENTRYPOINT ["/payara41/bin/asadmin", "start-domain", "-v", "--debug", "test"]