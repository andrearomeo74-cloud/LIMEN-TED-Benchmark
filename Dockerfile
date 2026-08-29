FROM maven:3.9.9-eclipse-temurin-21

RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-pip unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install --break-system-packages lxml

WORKDIR /work
COPY LIMEN_TED_SEXTPAIR_EXEC_v0.1.zip /work/
COPY LIMEN_TED_FREEZE_RECEIPT_PROTOCOL_v0.1.zip /work/
COPY tools/run_and_collect.sh /work/run_and_collect.sh
RUN chmod +x /work/run_and_collect.sh

ENTRYPOINT ["/work/run_and_collect.sh"]
