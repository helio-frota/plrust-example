# plrust basic tests

## build

podman build -t postgres-plrust .

```shell
Error:
   0: The installed `cargo-pgrx` v0.11.4 is not compatible with the `pgrx = 0.11.0`, `pgrx-macros = 0.11.0`, `pgrx-sql-entity-graph = 0.11.0`, `pgrx-tests = 0.11.0` dependencies in `./Cargo.toml`. `cargo-pgrx` and pgrx dependency versions must be identical.

Location:
   /var/lib/postgresql/.cargo/registry/src/index.crates.io-6f17d22bba15001f/cargo-pgrx-0.11.4/src/metadata.rs:68

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ SPANTRACE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   0: cargo_pgrx::metadata::validate
      at /var/lib/postgresql/.cargo/registry/src/index.crates.io-6f17d22bba15001f/cargo-pgrx-0.11.4/src/metadata.rs:30
   1: cargo_pgrx::command::package::execute
      at /var/lib/postgresql/.cargo/registry/src/index.crates.io-6f17d22bba15001f/cargo-pgrx-0.11.4/src/command/package.rs:101
```
