#!/bin/bash

# See:
# https://github.com/tcdi/plrust/blob/main/doc/src/config-pg.md#required
# https://github.com/tcdi/plrust/blob/main/Dockerfile.try#L102
echo "shared_preload_libraries='plrust'" >> /var/lib/postgresql/data/postgresql.conf
echo "plrust.work_dir='/tmp'" >> /var/lib/postgresql/data/postgresql.conf
