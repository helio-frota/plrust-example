FROM postgres:16

RUN apt update && \
    apt -y install postgresql-server-dev-16 git htop curl build-essential pkg-config

USER postgres

RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain=1.72.0  -y

ENV PATH="/var/lib/postgresql/.cargo/bin:${PATH}"

RUN cargo install cargo-pgrx --version 0.11.0 --locked
RUN cargo pgrx init --pg16 /usr/bin/pg_config

WORKDIR /var/lib/postgresql
RUN git clone https://github.com/tcdi/plrust.git && \
    cd plrust && \
    cd plrust && \
    cargo pgrx package && \
    cargo pgrx install

CMD ["postgres"]