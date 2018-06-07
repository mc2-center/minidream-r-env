FROM rocker/rstudio:3.4.4

RUN apt-get update && apt-get -y install rsync

COPY config/Rprofile.site /usr/local/lib/R/etc/
COPY config/rserver.conf /etc/rstudio/rserver.conf
COPY util /root/util/

RUN groupadd rstudio-admin
RUN groupadd rstudio-user

RUN bash /root/util/add_users.sh /root/util/users.csv

RUN mkdir /shared

# This allows for only the admins to read and write to shared
RUN chgrp rstudio-admin /shared
RUN chmod g+rw  /shared

# MUST CHMOD 750 the ubuntu folder after docker compose is running
