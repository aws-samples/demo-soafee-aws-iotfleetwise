FROM python:3

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        git ca-certificates iproute2 can-utils vim  \
        python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir wrapt cantools prompt_toolkit python-can can-isotp matplotlib


WORKDIR /root
#RUN git clone --depth 1 --branch v1.0.0 https://github.com/aws/aws-iot-fleetwise-edge.git
#WORKDIR /root/aws-iot-fleetwise-edge/tools/cansim/
ADD hscan.dbc .
ADD cansim.py .
ADD canigen.py .

#ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["python", "cansim.py", "-i", "vxcan0"]
