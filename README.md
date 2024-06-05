# plrust basic tests

* We are using PG16 [here](https://github.com/trustification/trustify/blob/main/etc/deploy/compose/compose.yaml#L3) and [here](https://github.com/trustification/trustify/blob/main/Cargo.toml#L73) :heavy_check_mark:
* We need to build this with rust 1.72.0 and we are using 1.77.2 and 1.78.0 :heavy_minus_sign:

## build

podman build -t postgres-plrust .

### execute

podman run --name postgres-plrust-container -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=testdb -d postgres-plrust

### access

podman exec -it postgres-plrust-container bash
