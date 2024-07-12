# Vendorized Code


## 1. mimic-code

- Project: https://github.com/MIT-LCP/mimic-code
- Commit: a8308706d8f2bf3bbf42f5e7065094c648f64576

### URLs of files used
```
https://github.com/MIT-LCP/mimic-code/blob/a8308706d8f2bf3bbf42f5e7065094c648f64576/LICENSE
https://raw.githubusercontent.com/MIT-LCP/mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576/mimic-iii/buildmimic/docker/setup.sh
https://raw.githubusercontent.com/MIT-LCP/mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576/mimic-iii/buildmimic/postgres/create_mimic_user.sh
https://raw.githubusercontent.com/MIT-LCP/mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576/mimic-iii/buildmimic/postgres/postgres_add_comments.sql
https://raw.githubusercontent.com/MIT-LCP/mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576/mimic-iii/buildmimic/postgres/postgres_add_indexes.sql
https://raw.githubusercontent.com/MIT-LCP/mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576/mimic-iii/buildmimic/postgres/postgres_checks.sql
https://raw.githubusercontent.com/MIT-LCP/mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576/mimic-iii/buildmimic/postgres/postgres_create_tables.sql
https://raw.githubusercontent.com/MIT-LCP/mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576/mimic-iii/buildmimic/postgres/postgres_create_tables_pg10.sql
https://raw.githubusercontent.com/MIT-LCP/mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576/mimic-iii/buildmimic/postgres/postgres_load_data.sql
https://raw.githubusercontent.com/MIT-LCP/mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576/mimic-iii/buildmimic/postgres/postgres_load_data_7zip.sql
https://raw.githubusercontent.com/MIT-LCP/mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576/mimic-iii/buildmimic/postgres/postgres_load_data_gz.sql
```


### Modifications

#### File `.mimic-iii/buildmimic/docker/setup.sh`:

Insert the following lines:
```
# ensure mimic user can read mimiciii db
psql -U postgres -d mimic -c "GRANT USAGE ON SCHEMA mimiciii TO mimic;"
psql -U postgres -d mimic -c "GRANT SELECT ON ALL TABLES IN SCHEMA mimiciii TO mimic;"
```
So that the end of the file looks like this:
```
echo "$0: running postgres_checks.sql (all rows should return PASSED)"
psql "dbname=mimic user='$POSTGRES_USER' options=--search_path=mimiciii" < /docker-entrypoint-initdb.d/buildmimic/postgres/postgres_checks.sql
fi

# ensure mimic user can read mimiciii db
psql -U postgres -d mimic -c "GRANT USAGE ON SCHEMA mimiciii TO mimic;"
psql -U postgres -d mimic -c "GRANT SELECT ON ALL TABLES IN SCHEMA mimiciii TO mimic;"

echo 'Done!
```












