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
        rsync \
        zlib1g-dev \
        libxt6 \
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

# Install miniconda (required by synasper)
ENV CONDA_DIR /opt/conda
RUN wget --quiet \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Install Python dependencies
RUN pip install \
    pandas \
    requests \
    rpy2 \
    synapseclient

# Install synapser using `install.packages()` (error when installed with install2.r)
RUN R -e "install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"

COPY config/Rprofile.site /usr/local/lib/R/etc/
COPY config/rserver.conf /etc/rstudio/rserver.conf
COPY utils/ /root/utils/

RUN groupadd rstudio-user
RUN groupadd rstudio-admin

RUN bash /root/utils/add_users.sh /root/utils/users.csv

# RUN mkdir /shared

# # This allows for only the admins to read and write to shared
# RUN chgrp rstudio-admin /shared
# RUN chmod g+rw /shared

# MUST CHMOD 750 the ubuntu folder after docker compose is running
