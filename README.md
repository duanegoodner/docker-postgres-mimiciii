# docker_postgres_mimiciii

This repository contains a `docker-compose.yml` and other Docker-related files for integrating PostgreSQL [MIMIC-III Clinical Database](https://physionet.org/content/mimiciii/1.4/) build scripts from the  [MIT-LCP / mimic-code repository](https://github.com/MIT-LCP/mimic-code) into a multi-container Docker application. A Docker image built using this his `docker-compose.yml` file will also contain a sudo-privileged, non-root user with a custom `zsh` profile (to make the dev environment more pleasant if we need to `exec` into the container).



## Getting Started

### 1. Clone this repository to the machine where you will run the database.

```
git clone https://github.com/duanegoodner/docker_postgres_mimiciii
```



### 2. Obtain MIMIC-III raw data

* A Physionet account with "credentialed" status is required to download the database files. You can go [here](https://physionet.org/) to create an account and find instructions or obtaining "credentialed" access [here](https://mimic.mit.edu/docs/gettingstarted/) and [here](https://physionet.org/settings/credentialing/).

* After obtaining credentialed access, `cd` into directory `docker_postgres_mimiciii/postgres`, and run the following command . (Replace `physionet_username`  with your actual username). 

  ```
  wget -r -N -c -np -P data --user physionet_username --ask-password https://physionet.org/files/mimiciii/1.4/
  ```

* The previous command will download  the 26 `.csv.gz` files that constitute the raw data for the entire MIMIC-III database  into `docker_postgres_mimiciii/postgres/data/physionet.org/files/mimiciii/1.4/` .

> **Note** As of December, 2023, the download speed from physionet.org maxes out at ~ 1 MB/s, so it takes a minimum of ~60 minutes download the net file size of 6.2 GB. More information on the MIMIC-III database files can be found [here](https://physionet.org/).

### 3. Add a `.env` file

Create file `docker_postgres_mimiciii/postgres/.env` and set values for the following environment variables 

```
MIMIC_PASSWORD=
POSTGRES_PASSWORD=
MIMICIII_RAW_DIR=
LOCAL_DB_PORT=
```

 `MIMIC_PASSWORD` is for a database user named `mimic` with read-only access to the MIMIC-III database, and `POSTGRES_PASSWORD` is for a database superuser with username `postgres`.  `MIMICIII_RAW_DIR` is the directory containing the `.csv.gz` files downloaded in Step 2. Here is an example of a set of valid values:

```
MIMIC_PASSWORD=mimic
POSTGRES_PASSWORD=postgres
MIMICIII_RAW_DIR=./data/physionet.org/files/mimiciii/1.4
LOCAL_DB_PORT=5555
```



### 4. Build the Docker image

From the `docker_postgres_mimiciii/postgres/` directory, run the following command to build a Docker image named `postgres_mimiciii`.

```
docker compose build
```



### 5. Run a Docker container to automatically build the database

> **Warning** The total size of the database built in this step is 50 GB.

From the `docker_postgres_mimiciii/postgres/` directory, run:

```
docker compose up
```

This will cause a container named `postgres_mimiciii` to run in your terminal foreground and display output as it initializes an instance of PostgreSQL. The first time the container runs, it will automatically build the MIMIC-III database in "named" Docker volume `postgres_mimiciii_db`.  (Docker generates this name by concatenating the  `postgres` directory name, and volume name `mimiciii_db` in `docker_postgres_mimiciii/postgres/docker-compose.yml`)  The database build process will likely take 45 to 60 minutes. Various output will display on the terminal during the build. You will know the database build has completed successfully when you see the following output:

```
postgres_mimiciii_setup  |         tbl         | expected_count | observed_count | row_count_check 
postgres_mimiciii_setup  | --------------------+----------------+----------------+-----------------
postgres_mimiciii_setup  |  admissions         |          58976 |          58976 | PASSED
postgres_mimiciii_setup  |  callout            |          34499 |          34499 | PASSED
postgres_mimiciii_setup  |  caregivers         |           7567 |           7567 | PASSED
postgres_mimiciii_setup  |  chartevents        |      330712483 |      330712483 | PASSED
postgres_mimiciii_setup  |  cptevents          |         573146 |         573146 | PASSED
postgres_mimiciii_setup  |  datetimeevents     |        4485937 |        4485937 | PASSED
postgres_mimiciii_setup  |  d_cpt              |            134 |            134 | PASSED
postgres_mimiciii_setup  |  diagnoses_icd      |         651047 |         651047 | PASSED
postgres_mimiciii_setup  |  d_icd_diagnoses    |          14567 |          14567 | PASSED
postgres_mimiciii_setup  |  d_icd_procedures   |           3882 |           3882 | PASSED
postgres_mimiciii_setup  |  d_items            |          12487 |          12487 | PASSED
postgres_mimiciii_setup  |  d_labitems         |            753 |            753 | PASSED
postgres_mimiciii_setup  |  drgcodes           |         125557 |         125557 | PASSED
postgres_mimiciii_setup  |  icustays           |          61532 |          61532 | PASSED
postgres_mimiciii_setup  |  inputevents_cv     |       17527935 |       17527935 | PASSED
postgres_mimiciii_setup  |  inputevents_mv     |        3618991 |        3618991 | PASSED
postgres_mimiciii_setup  |  labevents          |       27854055 |       27854055 | PASSED
postgres_mimiciii_setup  |  microbiologyevents |         631726 |         631726 | PASSED
postgres_mimiciii_setup  |  noteevents         |        2083180 |        2083180 | PASSED
postgres_mimiciii_setup  |  outputevents       |        4349218 |        4349218 | PASSED
postgres_mimiciii_setup  |  patients           |          46520 |          46520 | PASSED
postgres_mimiciii_setup  |  prescriptions      |        4156450 |        4156450 | PASSED
postgres_mimiciii_setup  |  procedureevents_mv |         258066 |         258066 | PASSED
postgres_mimiciii_setup  |  procedures_icd     |         240095 |         240095 | PASSED
postgres_mimiciii_setup  |  services           |          73343 |          73343 | PASSED
postgres_mimiciii_setup  |  transfers          |         261897 |         261897 | PASSED
postgres_mimiciii_setup  | (26 rows)
postgres_mimiciii_setup  | 
postgres_mimiciii_setup  | GRANT
postgres_mimiciii_setup  | GRANT
postgres_mimiciii_setup  | Done!
```

The database will then shutdown and restart. Once the database has successfully restarted, you should see the message:

```
LOG:  database system is ready to accept connections
```

The name of our freshly created database is `mimic`, and the schema we are interested in is `mimiciii`.   

Once the database is fully built, and has successfully restarted use `Ctrl+C` to stop the container.



### 6. Run tests to confirm image, database, and Docker volume were created properly:

From the `docker_postgres_mimiciii/postgres/` directory:

Start a container instance of our Docker image in the background

```
docker compose up -d
```

`docker exec` into the container as the non-root sudo user:

```
docker exec -it --user gen_user postgres_mimiciii_setup /bin/zsh
```

This should take you to `gen_user`'s `zsh` prompt inside the container. From there run the following:

```
psql -U postgres -d mimic -c "\dn"
```

The output should be:

```
       List of schemas
   Name   |       Owner       
----------+-------------------
 mimiciii | postgres
 public   | pg_database_owner
(2 rows)
```

Then exit the container to return to your local shell prompt:

```
exit
```

Next, run `docker volume ls` to confirm that the named volume where we intended to save the PostgreSQL database indeed exests:

```
docker volume ls
```

Among the output, you should see a line that says:

```
local     postgres_mimiciii_db
```

Check the metadata for this named volume:

```
docker volume inspect postgres_mimiciii_db
```

The output should look something like this:

```
[
    {
        "CreatedAt": "2023-05-27T23:16:02-06:00",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "postgres",
            "com.docker.compose.version": "2.17.3",
            "com.docker.compose.volume": "mimiciii_db"
        },
        "Mountpoint": "/var/lib/docker/volumes/postgres_mimiciii_db/_data",
        "Name": "postgres_mimiciii_db",
        "Options": null,
        "Scope": "local"
    }
]
```

To confirm that the size of the volume is what we expect for the MIMIC-III database, use `sudo du -sh <path value of the "Mountpoint" key>`. For example, with the mountpoint path shown above, we run:

```
sudo du -sh /var/lib/docker/volumes/postgres_mimiciii_db/_data
```

And get the following output, confirming that we have a 50 GB volume:

```
50G	/var/lib/docker/volumes/postgres_mimiciii_db/_data
```

Now that we've finished our tests, stop the container with:

```
docker compose down
```



### 7. Use the database...

#### Option 1: As a standalone service:

From the `docker_postgres_mimiciii/postgres/` directory, run:

```1
docker compose up
```

You can then connect to the database as read-only user `mimic` or super-user `postgres` using the password and port values you added to the `.env` file in Step 3.



#### Option 2: As a service in a multi-container application run through docker compose

In the following `docker-compose.yml` example, the postgres_mimiciii container's standard postgres data folder is mapped to the named volume storing the database we created in Step 4.

```docker
# docker-compose.yml

version: "3.8"

services:
  my_app:
    image: my_app_image
    container_name: my_app
    volumes: /my/local/path:/some/app/container/path
    depends_on:
      - postgres_mimiciii

  postgres_mimiciii:
    image: postgres_mimiciii
    container_name: postgres_mimiciii_for_app
    volumes:
      - postgres_mimiciii_db:/var/lib/postgresql/data
    ports:
      - 5555:5432
    init: true
    stdin_open: true
    tty: true

volumes:
  postgres_mimiciii_db:
    external: true
```

See the [lstm_adversarial_attack project repository](https://github.com/duanegoodner/lstm_adversarial_attack/tree/main) for an example of an actual multi-container project that uses a container from the `postgres_mimiciii` Docker image.

### 8. Accessing a shell inside the container

The `postgres_mimiciii` Docker image has sudo-privileged user named `gen_user` . When troubleshooting / exploring a container, it may be useful to run a shell as this user inside the container. You can start a `zsh` shell under this user in a running `postgres_mimiciii` container with the command:

```
docker exec -it --user gen_user postgres_mimiciii /bin/zsh
```



### 9. Removing the database

> [!NOTE]
>
> Deleting the database will free up 50 GB of disk space. Re-building from the 6 GB raw `.csv.gz` files (downloaded in Step 2) takes ~20 - 40 minutes on a typical system. If you are done using the database for now, but may want to use it again later, removing the database (i.e. deleting the docker named volume) but keeping the raw `.csv.gz` files is a reasonable trade-off.

To delete the named volume where Docker stores the database, you first need to stop the container (if it's running):

```
docker compose down
```

Then delete the container:

```
docker container rm postgres_mimiciii_setup
```

And finally delete the named volume:

```shell
docker volume rm postgres_mimiciii_db
```



### 10. References

* [Official PostGreSQL Image on Docker Hub](https://hub.docker.com/_/postgres)
*  [MIMIC-III Clinical Database](https://physionet.org/content/mimiciii/1.4/)
* [MIT-LCP / mimic-code repository](https://github.com/MIT-LCP/mimic-code)
