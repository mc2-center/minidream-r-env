FROM ubuntu:18.04

RUN apt-get update \
    && apt-get -y install \
        apache2 \
        libapparmor1 \
        libclang-dev \
        libcurl4-openssl-dev \
        libffi-dev \
        libssl-dev \
        libssl1.0.0 \
        libxml2-dev \
        ssl-cert \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY config/proxy.conf /etc/apache2/sites-available/proxy.conf

RUN a2enmod ssl proxy proxy_http rewrite headers

RUN a2ensite proxy

RUN a2dissite 000-default

EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
