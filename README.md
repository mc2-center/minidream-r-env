# minidream-r-env
Resources for setting up and managing an RStudio environment for interactive mini-DREAM activities

#### AWS instance setup & dependencies:
1. Choose an Ubuntu based instance (Ubuntu comes with apt-get and python). Make sure to look into Ubuntu's ideal version using the end of life plot https://www.ubuntu.com/info/release-end-of-life (ex. 2018: v16.04)
2. AWS Security groups would need to have a TCP rule to open port number 8787.
3. Install Docker-CE on Ubuntu https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1
4. To allow for user hierarchy creation on login, after executing `docker-compose up --build` change the /home volume permissions to `chmod 777 /home`

#### Useful-commands and mics. 
`rstudio-server --help` ex. `rstudio-server suspend-all` will remove the message: "ERROR session hadabend" from an R session console after each service 'reboot'.

#### Useful-links 
- https://hub.docker.com/u/rocker/










