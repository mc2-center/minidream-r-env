<h1 align="center">
  miniDREAM R-Environment
</h1>

<h3 align="center">
  Resources for setting up and managing an RStudio environment for interactive 
  miniDREAM activities
</h3>
<br/>

## 🛠️ Setup

### AWS

1. Choose an Ubuntu-based instance, as Ubuntu readily comes with `apt-get` and
   Python. We recommend researching Ubuntu's ideal version with its
   [end of life plot](https://www.ubuntu.com/info/release-end-of-life). For
   example: `v16.04` is ideal for the year 2018.

2. AWS Security groups need to have a TCP rule to open port number 8787.

### RStudio Server

1. Install [Docker-CE](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository)
   onto the instance if it's not already available.

2. Allow for [non-root users to manage Docker](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).

3. Install `docker compose` by installing the [Compose plugin](https://docs.docker.com/compose/install/linux/#install-the-plugin-manually):

   ```
   DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
   mkdir -p $DOCKER_CONFIG/cli-plugins
   curl -SL https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-linux-x86_64 \
      -o $DOCKER_CONFIG/cli-plugins/docker-compose
   chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
   ```

   You can test the installation with `docker compose version`

4. Clone the repository containing the miniDREAM course modules onto the
   instance. For example:

   ```shell
   git clone --branch minidream2023 https://github.com/mc2-center/minidream-challenge.git
   ```

   When building the server, it will expect the directory of course
   materials to be named `minidream-challenge`. If you are not using
   [minidream-challenge](https://github.com/mc2-center/minidream-challenge.git)
   as the source of course materials, edit `docker-compose.yml` so that the
   correct volume is mounted. See [Shared Files](#shared-files) for more details.

5. Clone **this** repository onto the instance:

   ```shell
   git clone https://github.com/mc2-center/minidream-r-env.git
   ```

6. Switch to the `minidream-r-env` directory and start the server:

   ```shell
   cd minidream-r-env/
   docker compose up --build -d
   ```

   It will take around 15-20 minutes to build the server for the first time.
   Once complete, you should see the following:

   ```shell
   ...
   [+] Running 3/3
   ✔ Network minidream-r-env_default  Created                            0.0s
   ✔ Container rstudio                Started                            1.6s
   ✔ Container proxy                  Started                            0.6s
   ```

**Congrats!** 🎉 The interactive RStudio environment is now available at
http://minidream.synapse.org/.

From this point forward, you can:

- start the server with:

  ```shell
  docker compose up -d
  ```

- stop the server with:

  ```shell
  docker compose down
  ```

   > **Note**: stopping the server will reset the RStudio contents, e.g.
   > modules will be removed, etc.

### Packages/Libraries

The RStudio server will come pre-installed with the following packages/libraries:

* BiocManager
* bitops
* caTools
* clusterProfiler
* DOSE
* getPass
* here
* imager
* org.Hs.eg.db
* pathview
* revealjs
* survival
* tidyverse
* tsne

To install a new package to the server, do:

```
docker compose exec -it rstudio R -e "install.packages('<package name>')"
```

> **Note**: to ensure the latest packages are installed, replace
> `options(repos = c(CRAN='https://mran.microsoft.com/snapshot/XX'), download.file.method = 'libcurl')`
> within `rstudio/config/Rprofile.site` with the latest date.


### Shared Files

By default, the server is configured to bind-mount `minidream-challenge` as
`/shared` in the `rstudio` container:

**docker-compose.yml**

```
...
volumes:
   - ../minidream-challenge:/shared
```

If you list the files of `/shared` with `docker compose exec -it rstudio ls -l /shared`,
the files listed will match the `minidream-challenge` directory.

When a volume is mounted, it will preserve the same permissions it has on the
host. For example, let's say `minidream-challenge` has read-write-execute
enabled for everyone (user, group, other) on the host; when it gets mounted,
`/shared` will also have read-write-execute enabled for everyone.

To ensure that only the admins are allowed editing rights to the course
materials on RStudio, change the group ownership as well as their permissions:

```
docker compose exec rstudio chgrp -R rstudio-admin /shared \
   && docker compose exec rstudio chmod g+rw /shared
```

Check the group ownership of `/shared` (just in case) with `docker compose exec -it rstudio ls -l /shared`

---

## 👤 Users

When the server is first built, two default users are added - one instructor
(admin), one student:

```csv
admin,changeme,rstudio-user;rstudio-admin
student,changeme,rstudio-user
```

where:

- the first field is the username, e.g. `admin`
- the second field is the password, e.g. `changeme`
- the third field is the user's group(s), e.g. `rstudio-user;rstudio-admin`

### Configure the User List

1. Assuming you are still in the `minidream-r-env` directory, remove
   `rstudio/utils/users.csv` (which is currently a symbolic link of
   `users.csv.template`):

   ```
   rm rstudio/utils/users.csv
   ```

2. Create a new `users.csv` within the `rstudio/utils/` directory. Each line
   should contain 3 fields, delimited by a comma (no spaces!):

   - username
   - password
   - group(s)

   If the user is a student, their group should be `rstudio-user`. If the user
   is an admin, their groups should be `rstudio-user;rstudio-admin`. See the
   default users list above for an example.

3. Stop the server and rebuild:

   ```shell
   docker compose down
   docker compose up --build -d
   ```

   This time, the server should be ready in less than a minute (assuming no
   changes have been made to the server Dockerfile). Once ready, go to
   http://minidream.synapse.org/ and try:

   - Logging in as a student
   - Logging in as an admin
   - Changing the password of a sample user with `passwd` (in the terminal)

### Adding New Users

If the course is already in progress, you can add new users with the `add_users`
tool.

1. Create a new CSV file, following the same format as above.

2. Copy the CSV into the `rstudio` container:

   ```
   docker cp <new user list> rstudio:<new user list>
   ```

   You can check that the file has been copied over with:

   ```
   docker compose exec -it rstudio ls
   ```

3. Add the new users to the server:

   ```
   docker compose exec rstudio /root/utils/add_users.sh <new user list>
   ```

   You should now be able to log in as one of the newly added users.

---

## 📚 Modules

When the server is first built, none of the modules from the `minidream-challenge`
directory will be available on RStudio - each module will need to be shared
with the users. We recommend sharing one module at a time, following the same
pace as the miniDREAM course.

### Broadcasting a Module

Let's go through an exercise of broadcasting a module to RStudio, starting
with Module 0.

For a quick overview, list the available modules that can be broadcasted. For
example:

```
$ docker compose exec -it rstudio ls -l /shared/modules
total 32
drwxrwxr-x 4 admin rstudio-admin 4096 May 25 23:09 module0
drwxrwxr-x 3 admin rstudio-admin 4096 May 23 17:07 module1
drwxrwxr-x 3 admin rstudio-admin 4096 May 23 17:07 module2
drwxrwxr-x 3 admin rstudio-admin 4096 May 23 17:07 module3
drwxrwxr-x 3 admin rstudio-admin 4096 May 23 17:07 module4
drwxrwxr-x 3 admin rstudio-admin 4096 May 23 17:07 module5
drwxrwxr-x 3 admin rstudio-admin 4096 May 23 17:07 module6
drwxrwxr-x 3 admin rstudio-admin 4096 May 23 17:07 welcome
```

1. Assuming you are in the `minidream-r-env` directory, run the `broadcast_module`
   tool:

   ```
   docker compose exec rstudio root/utils/broadcast_module.sh \
      shared/modules/module0 \
      rstudio-user
   ```

   This will share the contents of `shared/modules/module0` to all users
   belonging to the `rstudio-user` group (which should be all of the users
   in RStudio). A `modules` directory should now be available in the Files
   pane in RStudio.

2. (One-time only) Some course materials are dependent on scripts located at
   `/home/shared/R`, which does not exist when the server is first built. Create
   a symbolic link in the `rstudio` container so that this filepath exists:

   ```
   docker compose exec -it rstudio ln -s /shared /home/shared
   ```

**Congrats!** 🎉 You just launched your first module!

### Updating a Module

1. From the home directory, pull the changes:

   ```
   git pull minidream-challenge
   ```

   Alternatively, changes can be directly applied inside the directory on the
   instance:

   ```
   vim minidream-challenge/modules/<module name>/<notebook>
   ```

2. Copy the new module contents to the container. For example:

   ```
   docker cp \
      minidream-challenge/modules/module0/intro-to-RStudio.Rmd \
      fc9ac0f0f15f:/shared/modules/module0/.
   ```

3. Switch to the `minidream-r-env` directory and re-broadcast the module:

   ```
   docker compose exec rstudio root/utils/broadcast_module.sh \
      shared/modules/module0 \
      rstudio-user
   ```

---

## 🔄 Scoring Harness

> **Note**: this section will assume you are using `minidream-challenge` as
> the source for course materials.

### Setup

1. In either the same instance or a new one, install the latest version of Miniconda:

   ```
   mkdir -p ~/miniconda3
   wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
   bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 \
      && rm -rf ~/miniconda3/miniconda.sh
   miniconda3/bin/conda init bash
   ```

2. Exit the instance (to apply the changes), then log back in.

3. Assuming you are in the home directory, create a new environment from file:

   ```
   conda env create -f minidream-challenge/environment.yml
   ```

   This will create a virtual environment called `minidream` that will contain
   all of the necessary Python and R libraries to run the scoring harness.

4. Activate the virtual environment.

   ```
   conda activate minidream
   ```

5. In the home directory, create a new file called `.synapseConfig`, which
   will contain a Synapse Personal Access Token (PAT) needed to run the
   submission system:

   ```
   [authentication]
   authtoken=YOUR-PERSONAL-ACCESS-TOKEN-HERE
   ```

   Credentials used should have editing rights to the miniDREAM challenge
   site. [Go here to generate a new PAT](https://www.synapse.org/#!PersonalAccessTokens:).

### Configure the Workflow

Within `minidream-challenge`, edit the following scripts:

* `scoring_harness/challenge_eval.sh`

   - Update the absolute path to the conda virtual environment on your machine

* `scoring_harness/challenge_config.py`

   - Update CHALLENGE_SYN_ID to the synID of the project for the challenge site.
   - Update CHALLENGE_NAME
   - Update the list of ADMIN_USER_IDS to contain the user IDs of 
   - Update the evaluation IDs in `evaluation queues`:

      ```
      evaluation_queues = [
         {
            'id': <need to be updated>,
            'scoring_func': score,
         }
      ]
      ```

* `R/submission_helpers`
   - Update the folder synIDs where module submissions will be uploaded:

      ```
      submission_folder <- switch(
        module,
        "0" = "syn000",
        "1" = "syn111",
        "2" = "syn222",
        "3" = "syn333",
        "4" = "syn444",
        "5" = "syn555",
        "6" = "syn666",
        "7" = "syn777"
      )
      ```

   - update the evaluation ID for the `synSubmit` function:

      ```
      submission <- synSubmit(evaluation = "<need to be updated>",
                           entity = activity_submission)
      ```

### Conduct Dry-runs

1. If it's not already active, activate the `minidream` virtual environment. 

2. Assuming you are in the `minidream-challenge` directory, test whether you
   can run `challenge.py` without any errors:

   ```
   python scoring_harness/challenge.py -h
   ```

3. We also recommend testing out one of the commands as well, ideally, the
   same one listed in `challenge_eval.sh`, e.g.

   ```
   python scoring_harness/challenge.py score --all
   ```

   If it's working properly (and assuming there are no pending submission to
   be evaluated yet), you should get some logs in STDOUT like this:

   ```
   ===========================================================================
   2023-06-03T07:12:24.821643


   Scoring: 9615336 - 2023 miniDREAM Module Submissions
   ------------------------------------------------------------


   done:  2023-06-03T07:12:25.028427
   =========================================================================== 
   ```

### Automate the Process

Once you are sure the scoring harness is working as expected, set up a 
[Cron job](https://help.ubuntu.com/community/CronHowto#Starting_to_Use_Cron)
so that it will run every minute of every day.

1. Open up the crontab:

   ```
   crontab -e
   ```

2. Add the following task to the file:

   ```
   * * * * * /home/<your username>/minidream-challenge/scoring_harness/challenge_eval.sh
   ```

3. Save and exit the file.  Assuming it's working properly, logs will be saved
   into `scoring_harness/log/score.log`

> **Note**: if errors are noted in the log file, we recommend stopping the cron
> job so that you can address the errors in the interim. You can temporarily stop
> the job by commenting out the task with #.


**Congrats!** 🎉 You just finished setting up the challenge infrastructure for miniDREAM!

---

## Helpful Resources

- `rstudio-server --help`

  For example: `rstudio-server suspend-all` will remove the message: "ERROR
  session hadabend" from an R session console after each service 'reboot'.

- https://hub.docker.com/u/rocker/
- [Bruno's RStudio environment walkthrough](https://www.synapse.org/#!Synapse:syn29616137/wiki/617456)
- [Milen's repo and documentation](https://github.com/milen-sage/minidream-r-env)
- [Bruno's repo and documentation](https://github.com/Sage-Bionetworks/minidream-r-env/tree/bgrande/minidream-2021)

## Miscellaneous

1. Check out leader board
   Check out the course page wiki. Check "scoreboards" section, and click on the relevant module. Then, click on "Wiki tools" widget -> "Edit Project Wiki". You should be able to uncomment the line related to leaderboard.

2. Clear submission
   After testing out your own submission, you might want to clear out previous submission. To do that, please use the `challengeutils` package [here](https://github.com/Sage-Bionetworks/challengeutils)

After installing `challengeutils` package, you could use `challengeutils delete-submission <submission id>` for deleting a certain submission.

3. Update submission helpers
   Check out file `submission_helpers.R` under folder R. This file by default could only edited by root user. You could edit it by following the steps:

- Interact with the docker container as a root user `docker exec -it rstudio bin/bash`
- Go to `/shared/R` folder
- Update `submission_helpders.R` there by using `nano`
  _Note_: To save a file in nano, use `^O` (`ctrlO` on Mac)

4. Grant sudo access
   This could be done by using `sudo usermod -a -G sudo username`

5. Add users to docker group (Run docker commands without sudo)
   To be able to run docker without using `sudo`, we will have to add users to the docker group.

6. Check existing users in docker group

```
getent group docker
```

2. Add a new user to docker group

```
sudo usermod -a -G docker username
```

_Note_: make sure that you are using jumpcloud username
You should be able to see something like:

```
docker:x:999:ubuntu,username
```

3. To activate the changes to the docker group without restarting docker daemon:

```
newgrp docker
```

_Note_: If the user is still getting error after the above steps, we might want to change group ownership of the `/var/run/docker.sock file` by using: `sudo chown root:docker /var/run/docker.sock`.
Reference could be found [here](https://linuxhandbook.com/docker-permission-denied/) and [here](https://askubuntu.com/questions/477551/how-can-i-use-docker-without-sudo#:~:text=I%20still%20had%20to%20give%20the%20/var/run/docker.sock%20socket%20and%20/var/run/docker%20directory%20the%20proper%20permissions%20to%20make%20it%20work%3A)

6. Update forum link in `minidream-challenge/scoring_harness/messages.py`
   After students submit their work, they would get a message from the system. You could update `support_forum_url` and `challenge_instructions_url`
