# minidream-r-env
Resources for setting up and managing an RStudio environment for interactive mini-DREAM activities

#### AWS instance setup & dependencies:
1. Choose an Ubuntu based instance (Ubuntu comes with apt-get and python). Make sure to look into Ubuntu's ideal version using the end of life plot: https://www.ubuntu.com/info/release-end-of-life (ex. 2018: v16.04)
2. AWS Security groups need to have a TCP rule to open port number 8787.
3. Install Docker-CE on Ubuntu: https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository
4. Allow for non-root user to manage docker: https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user
5. Install docker-compose on Ubuntu https://docs.docker.com/compose/install/#install-compose.  (Do not do `apt-get install docker-compose`)
6. Clone the repository with the modules you'll be using for your mini-DREAM course — for example:

```shell
git clone https://github.com/Sage-Bionetworks/minidream-challenge-2018
```

7. Clone **this** repository onto the EC2 instance and `cd minidream-r-env`.
8. Run the command `docker-compose up --build -d` to launch the RStudio server. If it worked, you should see a message that looks like this:

```shell
  Creating minidream-r-env_rstudio_1 ... done
```

9. To allow for user hierarchy creation on login, after launching the server with `docker-compose`, change the `/home/ubuntu` volume permissions to `chmod 750 /home/ubuntu`.
10. Log into Rstudio www.replacewithec2address.com:8787

#### Editting the Rstudio instance
Example: Adding a new student
1. Create new csv file: example.csv
`student,2222,rstudio-user;student`
2. Get the container id: `docker ps`

3. `docker cp example.csv containerId:/example.csv`

4. `docker-compose exec rstudio /root/util/add_users.sh /example.csv`

5. You should be able to log in as student now.

Or:
`docker-compose exec rstudio /root/util/add_students.sh student`

#### Useful-commands and mics. 
`rstudio-server --help` ex. `rstudio-server suspend-all` will remove the message: "ERROR session hadabend" from an R session console after each service 'reboot'.

#### Useful-links 
- https://hub.docker.com/u/rocker/










