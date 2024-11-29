FROM registry.access.redhat.com/ubi8/ubi:8.6

COPY docker /tmp/repo
RUN sh /tmp/repo/build-image.sh \
  && sed -i "s/enabled=1/enabled=0/" /etc/dnf/plugins/subscription-manager.conf \
  && dnf update -y \
  && dnf module install nginx:1.22 -y \
  && dnf install -y iproute lsof procps-ng vim-enhanced \
  && dnf clean all \
  && sed -i "s/80/32780/g;45i \ \
        \n\
        location /repo/ {\n\
            allow all;\n\
            sendfile on;\n\
            sendfile_max_chunk 1m;\n\
            autoindex on;\n\
            autoindex_exact_size off;\n\
            autoindex_format html;\n\
            autoindex_localtime on;\n\
        }" /etc/nginx/nginx.conf \
  && { \
    echo "alias ls='ls --color=auto'"; \
    echo "alias ll='ls -l --color=auto'"; \
    echo "alias la='ls -Al --color=auto'"; \
  } >> ~/.bashrc

CMD ["sh", "/tmp/repo/docker-start.sh"]
