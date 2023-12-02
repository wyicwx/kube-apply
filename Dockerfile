FROM bitnami/kubectl

ADD envsubst-Linux-x86_64 /usr/local/bin/envsubst
ADD apply.sh /apply.sh
ADD clean.sh /clean.sh

USER root
RUN chmod +x /apply.sh
RUN chmod +x /clean.sh
RUN chmod +x /usr/local/bin/envsubst

ENTRYPOINT ["/apply.sh"]