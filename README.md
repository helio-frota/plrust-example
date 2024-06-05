# plrust basic example

## General notes

* We are using PG16 [here](https://github.com/trustification/trustify/blob/main/etc/deploy/compose/compose.yaml#L3) and [here](https://github.com/trustification/trustify/blob/main/Cargo.toml#L73) :heavy_check_mark:
* We need to build this with rust 1.72.0 and we are using 1.77.2 and 1.78.0 :heavy_minus_sign:
  * Because cargo pgrx is conflicting with plrust (I don't remember the build error)
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

#### Check installed

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

something is correct but not installed

```shell
    Finished release [optimized] target(s) in 3m 00s
  Installing extension
     Copying control file to target/release/plrust-pg16/usr/share/postgresql/16/extension/plrust.control
     Copying shared library to target/release/plrust-pg16/usr/lib/postgresql/16/lib/plrust.so
 Discovering SQL entities
  Discovered 5 SQL entities: 0 schemas (0 unique), 3 functions, 0 types, 0 enums, 2 sqls, 0 ords, 0 hashes, 0 aggregates, 0 triggers
     Writing SQL entities to target/release/plrust-pg16/usr/share/postgresql/16/extension/plrust--1.1.sql
    Finished installing plrust
--> a0d4a0d4a295
STEP 11/11: CMD ["postgres"]
COMMIT postgres-plrust
--> cf82df661de0
Successfully tagged localhost/postgres-plrust:latest
cf82df661de040360181f8a22740d2ce0da72b884c6bc97a2f90fd3ffa3b156b
```

progress:

```
 Installing extension
     Copying control file to /usr/share/postgresql/16/extension/plrust.control
Error:
   0: failed writing `/var/lib/postgresql/plrust/plrust/plrust.control` to `/usr/share/postgresql/16/extension/plrust.control`
   1: Permission denied (os error 13)

Location:
   /var/lib/postgresql/.cargo/registry/src/index.crates.io-6f17d22bba15001f/cargo-pgrx-0.11.0/src/command/install.rs:270

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ SPANTRACE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   0: cargo_pgrx::command::install::install_extension with pg_version=16.3 profile=Dev test=false features=["pg16"]
      at /var/lib/postgresql/.cargo/registry/src/index.crates.io-6f17d22bba15001f/cargo-pgrx-0.11.0/src/command/install.rs:114
   1: cargo_pgrx::command::install::execute
      at /var/lib/postgresql/.cargo/registry/src/index.crates.io-6f17d22bba15001f/cargo-pgrx-0.11.0/src/command/install.rs:63
```

