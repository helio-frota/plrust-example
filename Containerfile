FROM postgres:16

RUN apt update && \
    apt -y install postgresql-server-dev-16 git curl build-essential pkg-config

USER postgres

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH="/var/lib/postgresql/.cargo/bin:${PATH}"

RUN cargo install cargo-pgrx --version 0.11.0 --locked
RUN cargo pgrx init --pg16 /usr/bin/pg_config

WORKDIR /var/lib/postgresql
RUN git clone https://github.com/tcdi/plrust.git && \
    cd plrust && \
    cargo pgrx package