FROM openjdk:21-slim as builder

ARG CEREBRO_VERSION=0.9.4

RUN  apt-get update \
 && apt-get install -y wget \
 && mkdir -p /opt/cerebro/logs \
 && wget -qO- https://github.com/lmenezes/cerebro/releases/download/v${CEREBRO_VERSION}/cerebro-${CEREBRO_VERSION}.tgz \
  | tar xzv --strip-components 1 -C /opt/cerebro \
 && sed -i '/<appender-ref ref="FILE"\/>/d' /opt/cerebro/conf/logback.xml

FROM openjdk:21-slim

COPY --from=builder /opt/cerebro /opt/cerebro

RUN addgroup -gid 1000 cerebro \
 && adduser -q --system --no-create-home --disabled-login -gid 1000 -uid 1000 cerebro \
 && chown -R root:root /opt/cerebro \
 && chown -R cerebro:cerebro /opt/cerebro/logs \
 && chown cerebro:cerebro /opt/cerebro

WORKDIR /opt/cerebro
USER cerebro

# At least with Cerebro 0.9.4 some JVM options are required to run on openjdk 16+. See https://github.com/lmenezes/cerebro/issues/514
ENV JAVA_OPTS "--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/sun.net.www.protocol.file=ALL-UNNAMED"

ENTRYPOINT [ "/opt/cerebro/bin/cerebro" ]
