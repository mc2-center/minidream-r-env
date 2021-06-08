FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    apache2 \
    ssl-cert \
    libapache2-mod-python \
    zlib1g-dev \
    libclang-dev \
    libssl-dev \
    libffi-dev \
    libcurl4-openssl-dev \
    libapparmor1 \
    libssl1.0.0 \
    libxml2-dev

COPY config/proxy.conf /etc/apache2/sites-available/proxy.conf

RUN a2enmod ssl proxy proxy_http rewrite python headers

RUN a2ensite proxy

RUN a2dissite 000-default

EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
