ARG VERSION
FROM elasticsearch:${VERSION:-9.0.1}

USER root

RUN microdnf install -y openssl && microdnf clean all

RUN mkdir -p /usr/share/elasticsearch/config/certs && \
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config/certs

COPY elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY entrypoint.sh create_users.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/create_users.sh

USER elasticsearch

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]