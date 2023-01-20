## docker build . -t "neo4j-5.3-enterprise-zing" -f neo4j-5.3-enterprise-zing.dockerfile

FROM debian:bullseye-slim

# Prepare environment
ARG ZING_DIR=ZVM22.12.0.0
ARG ZING_PACK=zing22.12.0.0-2-jdk17.0.5-linux_x64.tar.gz

ENV JAVA_HOME=/opt/zing/zing17-ca-amd64

RUN apt update \
    && apt install -y curl \
    && mkdir -p ${JAVA_HOME} \
    && curl --fail --silent --show-error --location --remote-name https://cdn.azul.com/zing-zvm/${ZING_DIR}/${ZING_PACK} \
    && tar --strip-components=1 -xvzf ${ZING_PACK} -C ${JAVA_HOME} \
    && rm -f ${ZING_PACK}

ENV PATH="${JAVA_HOME}/bin:${PATH}" \
    NEO4J_SHA256=078aaf4da22ed43eae8164d8446b52c6d3751476db9000b83daa163dcf634bc2 \
    NEO4J_TARBALL=neo4j-enterprise-5.3.0-unix.tar.gz \
    NEO4J_EDITION=enterprise \
    NEO4J_HOME="/var/lib/neo4j"

ARG NEO4J_URI=https://dist.neo4j.org/neo4j-enterprise-5.3.0-unix.tar.gz

RUN addgroup --gid 7474 --system neo4j && adduser --uid 7474 --system --no-create-home --home "${NEO4J_HOME}" --ingroup neo4j neo4j

COPY ./local-package/* /startup/

RUN apt update \
    && apt install -y curl gosu jq tini wget \
    && curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && echo "${NEO4J_SHA256}  ${NEO4J_TARBALL}" | sha256sum -c --strict --quiet \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* "${NEO4J_HOME}" \
    && rm ${NEO4J_TARBALL} \
    && mv "${NEO4J_HOME}"/data /data \
    && mv "${NEO4J_HOME}"/logs /logs \
    && mv "${NEO4J_HOME}"/import /import \
    && chown -R neo4j:neo4j /data \
    && chmod -R 777 /data \
    && chown -R neo4j:neo4j /logs \
    && chmod -R 777 /logs \
    && chown -R neo4j:neo4j /import \
    && chmod -R 777 /import \
    && chown -R neo4j:neo4j "${NEO4J_HOME}" \
    && chmod -R 777 "${NEO4J_HOME}" \
    && ln -s /data "${NEO4J_HOME}"/data \
    && ln -s /logs "${NEO4J_HOME}"/logs \
    && ln -s /import "${NEO4J_HOME}"/import \
    && apt-get -y purge --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*


ENV PATH "${NEO4J_HOME}"/bin:$PATH

WORKDIR "${NEO4J_HOME}"

VOLUME /data /logs /import

EXPOSE 7474 7473 7687

ENTRYPOINT ["tini", "-g", "--", "/startup/docker-entrypoint.sh"]
CMD ["neo4j"]
