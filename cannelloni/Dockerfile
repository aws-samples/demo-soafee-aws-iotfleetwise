FROM ubuntu:20.04 as build-step

ARG version=v1.0.0
ENV DEBIAN_FRONTEND=noninteractive
LABEL version=${version}

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git ca-certificates iproute2 can-utils jq sed build-essential cmake && \
    apt-get clean
WORKDIR /root
RUN git clone --depth 1 --branch ${version} https://github.com/mguentner/cannelloni.git && \
    cd /root/cannelloni/ && \
    cmake -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make install

# FROM ubuntu:20.04

# LABEL version=${version}

# RUN apt-get update && \
#     apt-get install --no-install-recommends -y \
#     ca-certificates iproute2 can-utils jq sed \
#     curl zlib1g-dev libcurl4-openssl-dev && \
#     apt-get clean
# WORKDIR /roots

# COPY --from=build-step /usr/local/bin/cannelloni /usr/local/bin/
# COPY --from=build-step /usr/local/lib/libcannelloni* /usr/local/lib/

RUN ldconfig

ADD start-cannelloni.sh /usr/bin
RUN chmod +x /usr/bin/start-cannelloni.sh

CMD ["/usr/bin/start-cannelloni.sh"]
