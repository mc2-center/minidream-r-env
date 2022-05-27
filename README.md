# minidream-r-env
Resources for setting up and managing an RStudio environment for interactive mini-DREAM activities

## AWS instance setup & dependencies:
1. Choose an Ubuntu based instance (Ubuntu comes with apt-get and python). Make sure to look into Ubuntu's ideal version using the end of life plot: https://www.ubuntu.com/info/release-end-of-life (ex. 2018: v16.04)
2. AWS Security groups need to have a TCP rule to open port number 8787.


## Launching R studio on EC2 instance
1. Install Docker-CE on Ubuntu EC2 instance: https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository

*Note*: If you have the following error after running `sudo apt-get update` : Conflicting values set for option Signed-By regarding source https://download.docker.com/linux/ubuntu/ bionic: /usr/share/keyrings/docker-archive-keyring.gpg != The list of sources could not be read, please remove `docker.list` in `/etc/apt/sources.list.d`

If you are seeing: 
```
/etc/apt/sources.list.d$ ls

docker.list  download_docker_com_linux_ubuntu.list
```

You could try removing `docker.list` and run `sudo apt-get update` command again

2. Allow for non-root user to manage docker: https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user
3. Install docker-compose on Ubuntu https://docs.docker.com/compose/install/#install-compose.  (Do not do `apt-get install docker-compose`)

*Note*: Run `docker compose --version` to see if `docker compose` has been installed. 

4. Clone the repository with the modules you'll be using for your mini-DREAM course — for example:

```shell
git clone https://github.com/Sage-Bionetworks/minidream-challenge-2018
```

5. Clone **this** repository onto the EC2 instance and `cd minidream-r-env`. See an example command: 
```shell
git clone --branch bgrande/minidream-2021 https://github.com/Sage-Bionetworks/minidream-r-env.git
```

6. Run the command `docker-compose up --build -d` to launch the RStudio server. If it worked, you should see a message that looks like this:

```shell
  Creating minidream-r-env_rstudio_1 ... done
```
*Note* `-d` starts the containers in the background and leaves them running.

7. To allow for user hierarchy creation on login, after launching the server with `docker-compose`, change the `/home` volume permissions to `chmod 777 /home`. If this isn't done, you will get an error upon logging into rstudio: `Unable to connect to service`
8. Check out Rstudio by using the link [here](http://minidream.synapse.org/)
*Note*: To check if containers are running, use command `docker container ls -a` This should show you the container ID of `rstudio` and `proxy`. 


## Add students and admins to R studio environment
Example: Adding a new student
1. Create new csv file: example.csv
`catherine,2222,rstudio-user;`
*Note* for admin, you could try something like: 
`linglp,<Your default password>,rstudio-user;rstudio-admin`

2. Get the container id of `rstudio` by using: `docker ps`

3. `docker cp example.csv containerId:/example.csv`

4. `docker compose exec rstudio /root/util/add_users.sh /example.csv`

5. You should be able to log in as `catherine` now by using password `2222`

Or you could try to add students by using `add_students.sh`:
`docker-compose exec rstudio /root/util/add_students.sh student`
*Note*: check `add_students.sh` for default password of the added students

#### Useful-commands and mics. 
`rstudio-server --help` ex. `rstudio-server suspend-all` will remove the message: "ERROR session hadabend" from an R session console after each service 'reboot'.

#### Useful-links 
- https://hub.docker.com/u/rocker/
- [Bruno's video](https://www.synapse.org/#!Synapse:syn29616137/wiki/617456)showing how to access R studio environment


#### Relevant tests
- Logging in as a student
- Logging in as a admin
- Changing password in R studio environment after you log in by following the steps below: 
  - open a terminal in R studio
  - Type `passwd`

## Broadcasting and updating modules 
### Explanation of "shared" folder in rstudio container
1. Try interacting with R studio container by using the following command: 
`docker exec -it rstudio bin/bash`
2. You could see the `shared` directory there. Then, you could `cd shared` and find out that the content within `shared` folder is the same as `minidream-challenge` repo. If you create a new test file by using `touch test`, you would notice that this `test` file gets sync to `minidream-challenge` repo as well. This is because in our `docker-compose.yml`, we have the following: 
```
    volumes:
      - ../minidream-challenge:/shared
```

## Broadcasting module
1. Try broadcast module 0 to rstudio-user: 
```
docker compose exec rstudio root/utils/broadcast_module.sh /shared/modules/module0 rstudio-user
```
2. For updating module content, try to copy new module content to `./home/shared/modules/<module_name>` (i.e. via scp) and then re-broadcast the content by repeating step 1 

### Relevant tests
- Broadcast module 0 to rstudio-users
- Update module content 

## Module submission and cron job
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
    "7" = "syn25653405"
  )
   ```

   - update evaluation ID:
  ```
      submission <- synSubmit(evaluation = "9614774", 
                            entity = activity_submission)
  ```

*Note*: Double check if there's anything else that needs to be changed by checking into the `diff` between this year and last year. Here's an example of [diff](https://github.com/BrunoGrandePhD/minidream-challenge/commit/6209b57ab59555886ea7f0f4ccc27d33cce3ffc5#diff-c5cf203954ce9d9b80620f61683ed8b2f5cd43f55de42b4cb1b491f15eba7e12) between year 2020 and year 2021

4. activate `minidream-2022` conda virtual environment and see if you could run the following line in `challenge_eval.sh` without errors: 
  - After defining `script_dir` here: `export script_dir="$HOME/minidream-challenge/scoring_harness"`
  - Run the script without errors
  ```
  python3 $script_dir/challenge.py
  ```

5. Check out intro of cron job[here](https://help.ubuntu.com/community/CronHowto#Starting_to_Use_Cron)

6. Run the following to set up cron job for running every day, every minute: 
```
crontab -e
```

If you don't have any cron jobs running, this command would prompt you to set up one. You could then put the following line: 

```
* * * * * /home/<your username>/minidream-challenge/scoring_harness/challenge_eval.sh
```
*Note*: You have to use an absolute path to `challenge_eval.sh`

7. Check out the log here: `scoring_harness/log/score.log`

### Relevant tests:
- Broadcast module 0 in R studio environment
- Update an module and re-broadcast it
- Run cron job and see leaderboard gets reflected. To see the leaderboard, click on `wiki tools` -> Edit project Wiki -> uncomment the line related to `leaderboard` on [2022 CSBC PS-ON mini-DREAM Challenge](https://www.synapse.org/#!Synapse:syn29616137/wiki/617459)

# Other resources
 - [Milen's repo and documentation](https://github.com/milen-sage/minidream-r-env)
 - [Bruno's repo and documentation](https://github.com/Sage-Bionetworks/minidream-r-env/tree/bgrande/minidream-2021)






