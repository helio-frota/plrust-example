# plrust basic example

## General notes

* We are using PG16 [here](https://github.com/trustification/trustify/blob/main/etc/deploy/compose/compose.yaml#L3) and [here](https://github.com/trustification/trustify/blob/main/Cargo.toml#L73)
* We need to build this with rust 1.72.0 (we are using 1.77.2 and 1.78.0)
  * Because cargo `pgrx` is conflicting with `plrust` (I don't remember the build error)
* It works
  * Some basic functions fails to compile not sure why
* Not sure how much it can be reduced:

```shell
➜  plrust-example git:(main) ✗ podman image list
REPOSITORY                  TAG         IMAGE ID      CREATED         SIZE
localhost/pg-plrust         latest      07a447d9a180  56 seconds ago  4.83 GB
```

### Build

```shell
podman build -t pg-plrust .
```

### Run

```shell
podman run --name pg-plrust-c -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=testdb -d pg-plrust
```

```shell
podman exec -it pg-plrust-c bash
```

```shell
postgres@6720afb28218:~$ psql -U postgres -d testdb
psql (16.3 (Debian 16.3-1.pgdg120+1))
Type "help" for help.
```

```console
testdb=# \dx
                 List of installed extensions
  Name   | Version |   Schema   |         Description
---------+---------+------------+------------------------------
 plpgsql | 1.0     | pg_catalog | PL/pgSQL procedural language
(1 row)
```

#### Create extension

```console
testdb=# CREATE EXTENSION IF NOT EXISTS plrust;
WARNING:  plrust is **NOT** compiled to be a trusted procedural language
CREATE EXTENSION
```

```console
testdb=# \dx
                                List of installed extensions
  Name   | Version |   Schema   |                        Description
---------+---------+------------+------------------------------------------------------------
 plpgsql | 1.0     | pg_catalog | PL/pgSQL procedural language
 plrust  | 1.1     | plrust     | plrust:  A Trusted Rust procedural language for PostgreSQL
(2 rows)
```

### Basic example

from <https://plrust.io/use-plrust.html#basic-plrust-example>

```shell
postgres@6720afb28218:~$ psql -U postgres -d testdb
```

```console
CREATE FUNCTION plrust.one()
    RETURNS INT LANGUAGE plrust
AS
$$
    Ok(Some(1))
$$;
```

```console
testdb=# SELECT plrust.one();
 one
-----
   1
(1 row)
```

Other example (based on <https://plrust.io/use-plrust.html#calculations>)

```console
CREATE OR REPLACE FUNCTION plrust.fah_to_cel(fah FLOAT)
    RETURNS FLOAT
    LANGUAGE plrust STRICT
AS $$
    Ok(Some((fah - 32.0) / 1.8))
$$;
```

```console
testdb=# SELECT plrust.fah_to_cel(100);
    fah_to_cel
-------------------
 37.77777777777778
(1 row)
```

#### Added trustify dump, replace init.sql with whatever db script

```console
testdb=# \c testdb
You are now connected to database "testdb" as user "postgres".
testdb=# \dt
                     List of relations
 Schema |              Name              | Type  |  Owner
--------+--------------------------------+-------+----------
 public | advisory                       | table | postgres
 public | advisory_vulnerability         | table | postgres
 public | affected_package_version_range | table | postgres
 public | cpe                            | table | postgres
 public | cvss3                          | table | postgres
 public | cvss4                          | table | postgres
 public | fixed_package_version          | table | postgres
 public | importer                       | table | postgres
 public | importer_report                | table | postgres
 public | not_affected_package_version   | table | postgres
 public | organization                   | table | postgres
 public | package                        | table | postgres
 public | package_relates_to_package     | table | postgres
 public | package_version                | table | postgres
 public | package_version_range          | table | postgres
 public | product                        | table | postgres
 public | product_version                | table | postgres
 public | qualified_package              | table | postgres
 public | relationship                   | table | postgres
 public | sbom                           | table | postgres
 public | sbom_node                      | table | postgres
 public | sbom_package                   | table | postgres
 public | sbom_package_cpe_ref           | table | postgres
 public | sbom_package_purl_ref          | table | postgres
 public | seaql_migrations               | table | postgres
 public | vulnerability                  | table | postgres
 public | vulnerability_description      | table | postgres
(27 rows)

testdb=#
```

##### Select on existing table

> [!NOTE]
> Example based on plrust unit tests

```console
testdb=# CREATE FUNCTION random_importer() RETURNS TEXT
    STRICT
    LANGUAGE PLRUST AS
$$
    Ok(Spi::get_one("SELECT name FROM importer ORDER BY random() LIMIT 1")?)
$$;
CREATE FUNCTION
testdb=#
```

```console
testdb=# select random_importer();
 random_importer
-----------------
 osv-oss-fuzz
(1 row)

testdb=# select random_importer();
 random_importer
-----------------
 cve
(1 row)

testdb=# select random_importer();
 random_importer
-----------------
 osv-r
(1 row)

testdb=#
```
