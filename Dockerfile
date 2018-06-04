FROM rocker/rstudio:3.4.4

COPY config/Rprofile.site /usr/local/lib/R/etc/
COPY util /root/util/

RUN bash /root/util/add_users.sh /root/util/users.csv

RUN groupadd rstudio-admin
RUN groupadd rstudio-user
RUN groupadd student

RUN mkdir /root/shared
RUN cp /root/util/users.csv /root/shared
RUN chgrp student /root/shared
RUN chmod g+r  /root/shared