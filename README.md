# docker_postgres_mimiciii



## Usage

#### 1. Clone this repository to the machine where you will run the database.

```
$ git clone https://github.com/duanegoodner/docker_postgres_mimiciii
```

#### 2. Obtain MIMIC-III raw data

* A Physionet account with "credentialed" status is required to download the database files. You can go [here](https://physionet.org/) to create an account and find instructions or obtaining "credentialed" access [here](https://mimic.mit.edu/docs/gettingstarted/) and [here](https://physionet.org/settings/credentialing/).

* After obtaining credentialed access, `cd` into directory `docker_postgres_mimiciii/data`, and run the following command . (Replace `physionet_username`  with your actual username). 

  ```
  $ wget -r -N -c -np --user physionet_username --ask-password https://physionet.org/files/mimiciii/1.4/
  ```

* The previous command will download  directory named `physionet.org` containing all raw MIMIC-III files will be downloaded into `docker_postgres_mimiciii/data`. Do not modify this folder or any of its subdirectories.

> The download process may take 45 to 90 minutes. More information on the MIMIC-III database files can be found [here](https://physionet.org/).

#### 3. Build the Docker image

From the `docker_postgres_mimiciii/` directory, run:

```
$ ./bin/build_image.sh
```

This will build a Docker image named `postgres_mimiciii`.

#### 4. Run a Docker container to automatically build the database

From the `docker_postgres_mimiciii/` directory, run:

```
$ ./bin/run_container.sh
```

A container named `postgres_mimiciii` will run in your terminal foreground and display output as it initializes an instance of PostgreSQL. The first time the container runs, it will automatically build the MIMIC-III database in named Docker volume `postgres_mimiciii_data`. 



#### 4. Build the Docker image

From directory `docker_postgres_mimiciii/docker` run:

```
$ docker compose build 
```

#### 5. Run the container to build the database

From directory `docker_postgres_mimiciii/docker` run:

```
$ docker compose up
```

This will run a Docker container and start a PostgreSQL instance inside the container. The first time the container runs, it will build the MIMIC-III database, and this process can be time-consuming (~60 minutes on my laptop).
