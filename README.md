# plrust basic tests

## General notes

* We are using PG16 [here](https://github.com/trustification/trustify/blob/main/etc/deploy/compose/compose.yaml#L3) and [here](https://github.com/trustification/trustify/blob/main/Cargo.toml#L73) :heavy_check_mark:
* We need to build this with rust 1.72.0 and we are using 1.77.2 and 1.78.0 :heavy_minus_sign:
* Not sure how much it can be reduced: :heavy_minus_sign:

```shell
➜  plrust-example git:(main) ✗ podman image list
REPOSITORY                  TAG         IMAGE ID      CREATED             SIZE
localhost/postgres-plrust   latest      19e170d87b56  About a minute ago  4.81 GB
```

### Build

```shell
podman build -t postgres-plrust .
```

### Execute

```shell
podman run --name postgres-plrust-container -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=testdb -d postgres-plrust
```

### Access

```shell
podman exec -it postgres-plrust-container bash
```

#### check installed

```shell
psql -U postgres -d testdb
```

```shell
\dx
```

trying to understand:

```shell
➜  plrust-example git:(main) ✗ podman exec -it postgres-plrust-container bash
postgres@5d8f7f746904:~$ psql -U postgres -d testdb
psql (16.3 (Debian 16.3-1.pgdg120+1))
Type "help" for help.

testdb=# \dx
                 List of installed extensions
  Name   | Version |   Schema   |         Description
---------+---------+------------+------------------------------
 plpgsql | 1.0     | pg_catalog | PL/pgSQL procedural language
(1 row)

testdb=# CREATE EXTENSION IF NOT EXISTS plrust;
ERROR:  extension "plrust" is not available
DETAIL:  Could not open extension control file "/usr/share/postgresql/16/extension/plrust.control": No such file or directory.
HINT:  The extension must first be installed on the system where PostgreSQL is running.
testdb=#
```