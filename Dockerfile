FROM ubuntu:20.04 as builder

RUN set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    cmake \
    make \
    pkg-config \
    libssl-dev \
    git \
    clang \
  ; \
  rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash polkadot
USER polkadot

ARG TOOLCHAIN

RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain ${TOOLCHAIN} --target x86_64-unknown-linux-gnu,wasm32-unknown-unknown -y

ARG VERSION

RUN set -ex; \
  mkdir $HOME/polkadot; \
  curl -fL https://github.com/paritytech/polkadot/archive/v${VERSION}.tar.gz | tar -xz --strip-components=1 -C $HOME/polkadot

RUN set -ex; \
  PATH=$PATH:$HOME/.cargo/bin; \
  cd $HOME/polkadot; \
  cargo build --release


FROM ubuntu:20.04

COPY --from=builder /home/polkadot/polkadot/target/release/polkadot /usr/bin/

RUN useradd -m -u 1000 -s /bin/bash polkadot
USER polkadot

ENTRYPOINT ["polkadot"]
