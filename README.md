# plrust basic example

## General notes

* We are using PG16 [here](https://github.com/trustification/trustify/blob/main/etc/deploy/compose/compose.yaml#L3) and [here](https://github.com/trustification/trustify/blob/main/Cargo.toml#L73) :heavy_check_mark:
* We need to build this with rust 1.72.0 (we are using 1.77.2 and 1.78.0) :heavy_minus_sign:
  * Because cargo `pgrx` is conflicting with `plrust` (I don't remember the build error)
* It works :heavy_plus_sign:
  * Some basic functions fails to compile not sure why
* Not sure how much it can be reduced: :heavy_minus_sign:

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
