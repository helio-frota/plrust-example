FROM postgres:16

# installs required packages
# changes some dir permissions to postgres user and group
# cleans apt stuff
RUN apt update && \
    apt -y install postgresql-server-dev-16 curl git build-essential pkg-config && \
    chown -R postgres:postgres /usr/share/postgresql/16/extension/  && \
    chown -R postgres:postgres /usr/lib/postgresql/16/lib/ && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# this is working to update postgresql.conf
COPY init.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/init.sh

# required to change the user to posgres when installing rust and other things
USER postgres

RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain=1.72.0  -y

# i have no idea about this just following the docs
ENV PATH="/var/lib/postgresql/.cargo/bin:${PATH}"

# we need to use 0.11.0 atm to avoid build error with current version
RUN cargo install cargo-pgrx --version 0.11.0 --locked
RUN cargo pgrx init --pg16 /usr/bin/pg_config

WORKDIR /var/lib/postgresql

RUN git clone https://github.com/tcdi/plrust.git && \
    cd plrust/plrust && \
    cargo pgrx install --release -c /usr/bin/pg_config

CMD ["postgres"]