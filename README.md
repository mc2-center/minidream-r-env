<h1 align="center">
  miniDREAM R-Environment
</h1>

<h3 align="center">
  Resources for setting up and managing an RStudio environment for interactive miniDREAM activities
</h3>
<br/>



## 🛠️ Setup

### AWS

1. Choose an Ubuntu-based instance, as Ubuntu readily comes with `apt-get` and Python. We recommend researching Ubuntu's ideal version with its [end of life plot](https://www.ubuntu.com/info/release-end-of-life). For example: `v16.04` is the most ideal in the year 2018.

2. AWS Security groups need to have a TCP rule to open port number 8787.

### RStudio Server

1. Install [Docker-CE](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository) onto the instance if it's not already available.

2. Allow for [non-root users to manage Docker](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).

3. Install `docker compose` by installing the [Compose plugin](https://docs.docker.com/compose/install/linux/#install-the-plugin-manually):

   ```
   DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
   mkdir -p $DOCKER_CONFIG/cli-plugins
   curl -SL https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-linux-x86_64 \
      -o $DOCKER_CONFIG/cli-plugins/docker-compose
   chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
   ```

   You can test the installation with `docker compose version`.

4. Clone the repository containing the miniDREAM course modules onto the instance. For example:

   ```shell
   git clone --branch minidream2023 https://github.com/mc2-center/minidream-challenge.git
   ```

5. Clone **this** repository onto the instance:

   ```shell
   git clone https://github.com/mc2-center/minidream-r-env.git
   ```

6. Switch to the `minidream-r-env` directory and start the server:

   ```shell
   cd minidream-r-env/
   docker compose up --build -d
   ```

   It will take around 15 minutes to build the server for the first time. Once complete, you should see the following:

   ```shell
   ...
   [+] Running 3/3
   ✔ Network minidream-r-env_default  Created                            0.0s
   ✔ Container rstudio                Started                            1.6s
   ✔ Container proxy                  Started                            0.6s
   ```

**Congrats!** 🎉 The interactive RStudio environment is now available at http://minidream.synapse.org/.

From this point forward, you can:

* start the server with:

   ```shell
   docker compose up -d
   ```
 
* stop the server with:

   ```shell
   docker compose down
   ```

---

## Users

When the server is first built, two users are added as default - one admin, one student:

```
admin,changeme,rstudio-user;rstudio-admin
student,changeme,rstudio-user
```

To add other users:

1. Change directories to `rstudio/utils`.

2. Remove `users.csv` which is currently a symbolic link of `users.csv.template`:

   ```
   rm users.csv
   ```

3. Create a new `users.csv` within the `rstudio/utils` directory. Each line should contain 3 fields, delimited by a comma (do not include spaces!):

   - username
   - password
   - group

   If the user is a student, `group` should be `rstudio-user`. If the user is an admin, `group` should be `rstudio-user;rstudio-admin`. See the default users list above for an example.

   > Leave en empty line at the end of the file to ensure the last user gets added

4. Get the `CONTAINER ID` of the `rstudio` container with `docker ps`. For example:

   ```
   $ docker ps
   CONTAINER ID   IMAGE
   fc9ac0f0f15f   minidream-r-env-rstudio
   d070e1f30b37   minidream-r-env-reverse_proxy
   ```

   The container ID would be `fc9ac0f0f15f`.

5. Copy `users.csv` into the container:

   ```
   docker cp users.csv <container id>:users.csv
   ```

   You can check that the file has been copied over with:

   ```
   docker compose exec -it rstudio ls
   ```

6. Add the users to the server:

    ```
    docker compose exec rstudio /root/utils/add_users.sh users.csv
    ```

    You should now be able to log in as one of the newly added users.

✅ **You should now try:**

- Logging in as a student
- Logging in as an admin
- Changing the password of a sample user with `passwd` (in the terminal)

### Other Useful Resources

- `rstudio-server --help`
  
  For example: `rstudio-server suspend-all` will remove the message: "ERROR session hadabend" from an R session console after each service 'reboot'.
- https://hub.docker.com/u/rocker/
- [Bruno's RStudio environment walkthrough](https://www.synapse.org/#!Synapse:syn29616137/wiki/617456)

---

## Modules

### Explanation of "shared" folder in Rstudio container

1. Try interacting with R studio container by using the following command:
    ```
    docker exec -it rstudio bin/bash
    ```

2. You should be able to find `shared` folder by doing `ls`. You should also be able to find `broadcast_module.sh` in `root/utils` folder and `module0` in `shared/modules` folder

3. Then, you could `cd shared` and find out that the content within `shared` folder is the same as `minidream-challenge` repo. If you create a new test file by using `touch test`, you would notice that this `test` file gets sync to `minidream-challenge` repo as well. This is because in our `docker-compose.yml`, we have the following:

    ```
    volumes:
      - ../minidream-challenge:/shared
    ```

4. Exit the container interactive environment by doing: `exit`

### Broadcasting module

1. `cd minidream-r-env`
2. Try broadcast module 0 to rstudio-user:

```
docker compose exec rstudio root/utils/broadcast_module.sh shared/modules/module0 rstudio-user
```

3. For updating module content, try to interact with docker container by doing: `docker exec -it rstudio bin/bash`, and then copy new module content to `/shared/modules/<module_name>` (i.e. via scp). After making all the changes, try re-broadcast the content by repeating step 1 and 2.

### Relevant tests

- Broadcast module 0 to rstudio-users
- Update module content

### Adding symbolic link to docker container

Open `rstudio-overview_activity.rmd` of folder `module 0` in R studio environment. We could see the following code in the beginning:

```
data_dir <- "/home/shared/data"
scripts_dir <- "/home/shared/R"
source(file.path(scripts_dir, "submission_helpers.R"))
```

To make sure that all file paths are valid, we could create a symbolic link in R studio container by doing the following:

- `docker compose exec -it -w /root/utils rstudio ls`
- `ln -s /shared /home/shared`

_Note_: `/shared` is the source folder, and `/home/shared` is the symbolic link.

### Module submission and cron job

1. Install mini conda on EC2 instance

- Make a folder for `miniconda 3`: `mkdir miniconda3`
- Get the latest version:
  `wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda3/miniconda.sh`
- unpack the package:
  `bash miniconda3/miniconda.sh -b -u`
- remove `.sh` script:
  `rm -rf miniconda3/miniconda.sh`
- For bash use:
  `miniconda3/bin/conda init bash`
- `miniconda3/bin/conda init zsh`
  See the source (here)[https://engineeringfordatascience.com/posts/install_miniconda_from_the_command_line/]

2. Create an virtual environment called `minidream-2022` by using existing `environment.yml` in `minidream-challenge`

- Edit `environment.yml` to ensure that it reflects your new environment name `minidream-2022`
- Create the environment by using `conda env create -f environment.yml`
- activate the virtual env: `conda activate minidream-2022`

3. Module submission:
   [A cron job](https://help.ubuntu.com/community/CronHowto#Starting_to_Use_Cron) calls `minidream-challenge/scoring_harness/challenge_eval.sh` and runs every day every minute to capture submission. `minidream-challenge/scoring_harness/challenge_eval.sh` then calls `challenge.py` for scoring, and `challenge.py` calls `challenge_config.py`.

Update the following scripts:

1. `challenge_eval.sh`

- Make sure that the virtual environment has the correct path
- Make sure that you added youself for receiving email messages (add `-u "<Your synapse username>"`) after `python3 $script_dir/challenge.py`

2. `challenge_config.py`

- Update CHALLENGE_SYN_ID. This should point to the challenge page. For year 2022, it is `2022 CSBC PS-ON mini-DREAM Challenge`
- Update CHALLENGE_NAME
- Update ADMIN_USER_IDS. This should be your found on your profile page. (Example, for Lingling, this is the [profile page](https://www.synapse.org/#!Profile:3443707/profile))
- Update evaluation queues

  - for Year 2022, you could find the evaluation queue number [here](https://www.synapse.org/#!Synapse:syn29616137/challenge/)

  - see the line here:

  ```
  evaluation_queues = [
  {
    'id':<need to be updated>,
    'scoring_func':score,
  }
  ]
  ```

3. `R/submission_helpers`
   - update `syn id` of modules.
   ```
   submission_folder <- switch(
    module,
    "0" = "syn18818751",
    "1" = "syn18818752",
    "2" = "syn18818753",
    "3" = "syn18818755",
    "4" = "syn18818756",
    "5" = "syn18818757",
    "7" = "syn18818759"
    "0" = "syn25653272",
    "1" = "syn25653301",
    "2" = "syn25653326",
    "3" = "syn25653327",
    "4" = "syn25653347",
    "5" = "syn25653365",
    "7" = "syn25653405")
   ```
   - update evaluation ID:

```
    submission <- synSubmit(evaluation = "<need to be updated>",
                          entity = activity_submission)
```

_Note_: Double check if there's anything else that needs to be changed by checking into the `diff` between this year and last year. Here's an example of [diff](https://github.com/BrunoGrandePhD/minidream-challenge/commit/6209b57ab59555886ea7f0f4ccc27d33cce3ffc5#diff-c5cf203954ce9d9b80620f61683ed8b2f5cd43f55de42b4cb1b491f15eba7e12) between year 2020 and year 2021

4. activate `minidream-2022` conda virtual environment and see if you could run the following line in `challenge_eval.sh` without errors:

- After defining `script_dir` here: `export script_dir="$HOME/minidream-challenge/scoring_harness"`
- Run the script without errors

```
python3 $script_dir/challenge.py
```

5. Check out intro of cron job [here](https://help.ubuntu.com/community/CronHowto#Starting_to_Use_Cron)

6. Run the following to set up cron job for running every day, every minute:

```
crontab -e
```

If you don't have any cron jobs running, this command would prompt you to set up one. You could then put the following line:

```
* * * * * /home/<your username>/minidream-challenge/scoring_harness/challenge_eval.sh
```

_Note_: You have to use an absolute path to `challenge_eval.sh`

7. Check out the log here: `scoring_harness/log/score.log`

### Relevant tests:

- Broadcast module 0 in R studio environment
- Update an module and re-broadcast it
- Run cron job and see leaderboard gets reflected. To see the leaderboard, click on `wiki tools` -> Edit project Wiki -> uncomment the line related to `leaderboard` on [2022 CSBC PS-ON mini-DREAM Challenge](https://www.synapse.org/#!Synapse:syn29616137/wiki/617459)

_Note_: You might also need to ensure that the leader board is using the right query. To check out the query, click on the `$(leaderboard?XXX` part after clicking on "edit project wiki", and then click on "Edit synapse widget". You should be able to check out the query there. See an example here:
`select * from evaluation_<evaluation queue ID>  where module == "Module 2" `You want to make sure the evaluation Queue ID here as well as the column names are up to date.

## Other important changes

1. Update `Rprofile.site`
   Check out `minidream-r-env` folder and find `Rprofile.site`. To ensure that the latest packages get installed, please replace `options(repos = c(CRAN='https://mran.microsoft.com/snapshot/XX'), download.file.method = 'libcurl')` with the latest date.

2. To install packages globally (for all users), you could do it interactively. See an example here:
   `docker exec rstudio install2.r ggfortify factoextra GGally`

> Notes: the packages that get installed are: `install2.r, ggfortify, factoextra GGally`. The container is serving as an environment for students. After the container gets launched, a better way to install packages is to install them interactively like above. Otherwise, student's home directory would get wiped out.

For installing the latest dataset, you could do:

`docker exec rstudio R -q -e 'remotes::install_github("allisonhorst/palmerpenguins")`

> Notes: the dataset on CRAN might be outdated. The GitHub version might contain the latest version of the dataset.

## Other resources

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
