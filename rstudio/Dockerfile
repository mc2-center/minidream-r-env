# rocker/tidyverse was built on rocker/rstudio (so, it includes RStudio)
FROM rocker/tidyverse:4.2.2

# Install OS-level dependencies
# rsync needed for `broadcast_*` scripts
# libffi-dev and zlib1g-dev needed for `synapser`
# libglpk-dev needed for imager and clusterProfiler
# python3-pip needed for installing Python packages
RUN apt-get update \
    && apt-get -y install \
        libffi-dev \
        libglpk-dev \
        python3-pip \
        python3.10-venv \
        rsync \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages from CRAN (tidyverse pre-installed in base image)
RUN install2.r \
    BiocManager \
    bitops \
    caTools \
    getPass \
    here \
    imager \
    revealjs \
    survival \
    tsne

# Install R packages from Bioconductor (using littler utility script)
RUN /usr/local/lib/R/site-library/littler/examples/installBioc.r \
    clusterProfiler \
    DOSE \
    org.Hs.eg.db \
    pathview

# Install synapser directly from source
RUN R -e "remotes::install_github(repo='https://github.com/generalui/synapser/tree/reticulate', ref='reticulate')"

# Install Python dependencies
RUN pip3 install \
    pandas \
    requests \
    rpy2 \
    synapseclient

COPY config/Rprofile.site /usr/local/lib/R/etc/
COPY config/rserver.conf /etc/rstudio/rserver.conf
COPY utils/ /root/utils/

RUN groupadd rstudio-user
RUN groupadd rstudio-admin

RUN bash /root/utils/add_users.sh /root/utils/users.csv

RUN mkdir /shared

# This allows for only the admins to read and write to shared
RUN chgrp rstudio-admin /shared
RUN chmod g+rw /shared

# MUST CHMOD 750 the ubuntu folder after docker compose is running
