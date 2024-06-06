# plrust basic example

## General notes

* We are using PG16 [here](https://github.com/trustification/trustify/blob/main/etc/deploy/compose/compose.yaml#L3) and [here](https://github.com/trustification/trustify/blob/main/Cargo.toml#L73) :heavy_check_mark:
* We need to build this with rust 1.72.0 (we are using 1.77.2 and 1.78.0) :heavy_minus_sign:
  * Because cargo `pgrx` is conflicting with `plrust` (I don't remember the build error)
* Not sure how much it can be reduced: :heavy_minus_sign:

```shell
➜  plrust-example git:(main) ✗ podman image list
REPOSITORY                  TAG         IMAGE ID      CREATED        SIZE
localhost/postgres-plrust   latest      a96730ad4e5e  9 seconds ago  6.02 GB
```

### Build

```shell
podman build -t postgres-plrust .
```

### Run

```shell
podman run --name postgres-plrust-container -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=testdb -d postgres-plrust
```

```shell
podman exec -it postgres-plrust-container bash
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

Trying https://plrust.io/use-plrust.html#basic-plrust-example

```console
testdb=# CREATE FUNCTION plrust.one()
    RETURNS INT LANGUAGE plrust
AS
$$
    Ok(Some(1))
$$;
```

```console
ERROR:
   0: `cargo build` failed

Location:
   /rustc/5680fa18feaa87f3ff04063800aec256c3d4b4be/library/core/src/convert/mod.rs:716

`cargo build` stderr:
   error: could not execute process `plrustc -vV` (never executed)

   Caused by:
     No such file or directory (os error 2)


Source Code:
   #![deny(unsafe_op_in_unsafe_fn)]
   pub mod opened {
       #[allow(unused_imports)]
       use pgrx::prelude::*;
       #[allow(unused_lifetimes)]
       #[pg_extern]
       fn plrust_fn_oid_16384_16396<'a>() -> ::std::result::Result<
           Option<i32>,
           Box<dyn std::error::Error + Send + Sync + 'static>,
       > {
           Ok(Some(1))
       }
   }
   #[deny(unknown_lints)]
   mod forbidden {
       #![forbid(deprecated)]
       #![forbid(implied_bounds_entailment)]
       #![forbid(plrust_async)]
       #![forbid(plrust_autotrait_impls)]
       #![forbid(plrust_closure_trait_impl)]
       #![forbid(plrust_env_macros)]
       #![forbid(plrust_extern_blocks)]
       #![forbid(plrust_external_mod)]
       #![forbid(plrust_filesystem_macros)]
       #![forbid(plrust_fn_pointers)]
       #![forbid(plrust_leaky)]
       #![forbid(plrust_lifetime_parameterized_traits)]
       #![forbid(plrust_print_macros)]
       #![forbid(plrust_static_impls)]
       #![forbid(plrust_stdio)]
       #![forbid(plrust_suspicious_trait_object)]
       #![forbid(soft_unstable)]
       #![forbid(suspicious_auto_trait_impls)]
       #![forbid(unsafe_code)]
       #![forbid(where_clauses_object_safety)]
       #[allow(unused_imports)]
       use pgrx::prelude::*;
       #[allow(unused_lifetimes)]
       fn plrust_fn_oid_16384_16396<'a>() -> ::std::result::Result<
           Option<i32>,
           Box<dyn std::error::Error + Send + Sync + 'static>,
       > {
           Ok(Some(1))
       }
   }


Backtrace omitted. Run with RUST_BACKTRACE=1 environment variable to display it.
Run with RUST_BACKTRACE=full to include source snippets.
testdb=#
```