# docker_postgres_mimiciii

This repository contains:

* Docker-related files for integrating PostgreSQL MIMIC-III Clinical Database build scripts from the  [MIT-LCP / mimic-code repository](https://github.com/MIT-LCP/mimic-code) into a multi-container Docker application.

* Dockerfile and supporting shell scripts that build a PostgreSQL MIMIC-III image containing a sudo-privileged, non-root user with a custom `zsh` profile (to make the dev environment more pleasant if we need to `exec` into the container).

  

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

* The previous command will download  directory named `physionet.org`. The 26`.csv.gz` that constitute the raw data for the entire MIMIC-III database  will be in directory `physionet.org/files/mimiciii/1.4/` . I like to put them in `docker_postgres_mimiciii/data/mimiciii_raw`, but it is fine to put them wherever you want. Just take note of their location. 

> **Note** The download process may take 60 to 90 minutes, and the net file size is 6.2 GB. More information on the MIMIC-III database files can be found [here](https://physionet.org/).

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
MIMICIII_RAW_DIR=/directory/containing/the/gz/files/downloaded/in/part2
LOCAL_DB_PORT=5555
```



### 4. Build the Docker image

From the `docker_postgres_mimiciii/postgres/` directory, run the following command to build a Docker image named `postgres_mimiciii`.

```
$ docker compose build
```



### 5. Run a Docker container to automatically build the database

> **Warning** The total size of the database built in this step is 50 GB.

From the `docker_postgres_mimiciii/postgres/` directory, run:

```
$ docker compose up
```

This will cause a container named `postgres_mimiciii` to run in your terminal foreground and display output as it initializes an instance of PostgreSQL. The first time the container runs, it will automatically build the MIMIC-III database in "named" Docker volume `postgres_mimiciii_db`.  (Docker generates this name by concatenating the  `postgres` directory name, and volume name `mimiciii_db` in `docker_postgres_mimiciii/postgres/docker-compose.yml`)  The database build process will likely take 45 to 60 minutes. Various output will display on the terminal during the build. You will know the database build has completed successfully when you see the following output:

```
postgres_mimiciii_initialize  |         tbl         | expected_count | observed_count | row_count_check 
postgres_mimiciii_initialize  | --------------------+----------------+----------------+-----------------
postgres_mimiciii_initialize  |  admissions         |          58976 |          58976 | PASSED
postgres_mimiciii_initialize  |  callout            |          34499 |          34499 | PASSED
postgres_mimiciii_initialize  |  caregivers         |           7567 |           7567 | PASSED
postgres_mimiciii_initialize  |  chartevents        |      330712483 |      330712483 | PASSED
postgres_mimiciii_initialize  |  cptevents          |         573146 |         573146 | PASSED
postgres_mimiciii_initialize  |  datetimeevents     |        4485937 |        4485937 | PASSED
postgres_mimiciii_initialize  |  d_cpt              |            134 |            134 | PASSED
postgres_mimiciii_initialize  |  diagnoses_icd      |         651047 |         651047 | PASSED
postgres_mimiciii_initialize  |  d_icd_diagnoses    |          14567 |          14567 | PASSED
postgres_mimiciii_initialize  |  d_icd_procedures   |           3882 |           3882 | PASSED
postgres_mimiciii_initialize  |  d_items            |          12487 |          12487 | PASSED
postgres_mimiciii_initialize  |  d_labitems         |            753 |            753 | PASSED
postgres_mimiciii_initialize  |  drgcodes           |         125557 |         125557 | PASSED
postgres_mimiciii_initialize  |  icustays           |          61532 |          61532 | PASSED
postgres_mimiciii_initialize  |  inputevents_cv     |       17527935 |       17527935 | PASSED
postgres_mimiciii_initialize  |  inputevents_mv     |        3618991 |        3618991 | PASSED
postgres_mimiciii_initialize  |  labevents          |       27854055 |       27854055 | PASSED
postgres_mimiciii_initialize  |  microbiologyevents |         631726 |         631726 | PASSED
postgres_mimiciii_initialize  |  noteevents         |        2083180 |        2083180 | PASSED
postgres_mimiciii_initialize  |  outputevents       |        4349218 |        4349218 | PASSED
postgres_mimiciii_initialize  |  patients           |          46520 |          46520 | PASSED
postgres_mimiciii_initialize  |  prescriptions      |        4156450 |        4156450 | PASSED
postgres_mimiciii_initialize  |  procedureevents_mv |         258066 |         258066 | PASSED
postgres_mimiciii_initialize  |  procedures_icd     |         240095 |         240095 | PASSED
postgres_mimiciii_initialize  |  services           |          73343 |          73343 | PASSED
postgres_mimiciii_initialize  |  transfers          |         261897 |         261897 | PASSED
postgres_mimiciii_initialize  | (26 rows)
postgres_mimiciii_initialize  | 
postgres_mimiciii_initialize  | Done!
```

The name of our freshly created database is `mimic`, and the schema we are interested in is `mimiciii`.   

Once the database if fully built, use Ctrl+C to stop the container.

### 6. Use the database...

#### Option 1: As a standalone service:

From the `docker_postgres_mimiciii/postgres/` directory, run:

```1
$ docker compose up
```

You can then connect to the database as read-only user `mimic` or super-user `postgres` using the password and port values you added to the `.env` file in Step 3.





#### Option 1: As a service in a multi-container application run through docker compose

In this docker-compolse.yml example, the postgres_mimiciii container's standard postgres data folder is mapped to the named volume storing the database we created in Step 4. Local directory /my/local/path is mapped to a directory in the app container, and to a directory 

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
    container_name: postgres_mimiciii_initialize
    volumes:
      - postgres_mimiciii_db:/var/lib/postgresql/data
      - /my/local/path/:/some/db/container/path
    ports:
      - 5555:5432
    init: true
    stdin_open: true
    tty: true

volumes:
  postgres_mimiciii_db:
    external: true
```



### 7. Accessing a shell inside the container

The `postgres_mimiciii` Docker image has sudo-privileged user named `gen_user` . When troubleshooting / exploring a container, it may be useful to run a shell as this user inside the container. You can start a bash shell under this user in a running `postgres_mimiciii` container with the command:

```
$ docker exec -it --user gen_user postgres_mimiciii /bin/bash
```

Or, you can start a zsh shell with:

```
docker exec -it --user gen_user postgres_mimiciii /bin/zsh
```

I strongly recommend the second (zsh) option. `gen_user`'s zsh profile uses Oh-My-Zsh with Powerlevel10k formatting that just happens to match what I use in my local dev environment :grinning:.



### 8. Removing the database

 You can delete the named volume where Docker stores the database using:

```shell
$ docker volume rm postgres_mimiciii_db
```

