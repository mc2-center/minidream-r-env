FROM rocker/rstudio:3.4.4

COPY config/Rprofile.site /usr/local/lib/R/etc/
COPY util /root/util/

RUN groupadd rstudio-admin
RUN groupadd rstudio-user
RUN groupadd student

RUN bash /root/util/add_users.sh /root/util/users.csv

RUN mkdir /shared
RUN cp /root/util/users.csv /shared
RUN chgrp student /shared
RUN chmod g+r  /shared