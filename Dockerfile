FROM rocker/rstudio:3.4.4

COPY config/Rprofile.site /usr/local/lib/R/etc/
COPY util /root/util/

RUN groupadd rstudio-admin
RUN groupadd rstudio-user
RUN groupadd student

RUN bash /root/util/add_users.sh /root/util/users.csv

RUN mkdir /shared
RUN cp /root/util/users.csv /shared
#This allows for only the admins to read and write to shared
RUN chgrp rstudio-admin /shared
RUN chmod g+rw  /shared

#MUST CHMOD 770 the ubuntu folder after docker compose is running