# docker_postgres_mimiciii



## Getting Started



### 1. Clone this repository to the machine where you will run the database.

```
$ git clone https://github.com/duanegoodner/docker_postgres_mimiciii
```



### 2. Obtain MIMIC-III raw data

* A Physionet account with "credentialed" status is required to download the database files. You can go [here](https://physionet.org/) to create an account and find instructions or obtaining "credentialed" access [here](https://mimic.mit.edu/docs/gettingstarted/) and [here](https://physionet.org/settings/credentialing/).

* After obtaining credentialed access, `cd` into directory `docker_postgres_mimiciii/data`, and run the following command . (Replace `physionet_username`  with your actual username). 

  ```
  $ wget -r -N -c -np --user physionet_username --ask-password https://physionet.org/files/mimiciii/1.4/
  ```

* The previous command will download  directory named `physionet.org` containing all raw MIMIC-III files will be downloaded into `docker_postgres_mimiciii/data`. Do not modify this folder or any of its subdirectories.

> **Note** The download process may take 60 to 90 minutes, and the net file size is 6.2 GB. More information on the MIMIC-III database files can be found [here](https://physionet.org/).



### 3. Build the Docker image

From the `docker_postgres_mimiciii/` directory, run:

```
$ ./bin/build_image.sh
```

This will build a Docker image named `postgres_mimiciii`.



### 4. Run a Docker container to automatically build the database

> **Warning** The total size of the database built in this step is 50 GB.

From the `docker_postgres_mimiciii/` directory, run:

```
$ ./bin/run_container.sh
```

A container named `postgres_mimiciii` will run in your terminal foreground and display output as it initializes an instance of PostgreSQL. The first time the container runs, it will automatically build the MIMIC-III database in "named" Docker volume `postgres_mimiciii_data`.  The database build process will likely take 45 to 60 minutes. Various output from this process will display on the terminal. You will know the database build has completed successfully when you see the following output:

```
```

Once the database if fully built, use Ctrl+C to stop the container.



### 5. View metadata of the "named" Docker volume where the database is stored:

Run the following command:

```shell
$ docker volume inspect docker_postgres_mimiciii_data
```

to see output that looks something like this:

```shell
# Example output
# [
#     {
#         "CreatedAt": "2023-05-13T23:44:19-06:00",
#         "Driver": "local",
#         "Labels": {
#             "com.docker.compose.project": "docker",
#             "com.docker.compose.version": "2.17.3",
#             "com.docker.compose.volume": "postgres_mimiciii_data"
#         },
#         "Mountpoint": "/var/lib/docker/volumes/docker_postgres_mimiciii_data/_data",
#         "Name": "docker_postgres_mimiciii_data",
#         "Options": null,
#         "Scope": "local"
#     }
# ]
```



### 6. Use the database...

* #### Option 1: As a service in a multi-container application

* #### Option 2: In a stand-alone container



### 7. Accessing a shell inside the container

It is sometimes useful (esp. when troubleshooting) to run a shell inside a container. The postgres_mimiciii Docker image has sudo-privileged user named `gen_user` . You can start a bash shell under this user in a running postgres_mimiciii container with the command:

```
$ docker exec -it --user gen_user postgres_mimiciii /bin/bash
```

Or, you can start a zsh shell with:

```
docker exec -it --user gen_user postgres_mimiciii /bin/zsh
```

I strongly recommend the second (zsh) option because `gen_user`'s zsh profile uses Oh-My-Zsh with Powerlevel10k formatting that just happens to match what I use in my local dev environment :grinning:.



### 8. Removing the database



