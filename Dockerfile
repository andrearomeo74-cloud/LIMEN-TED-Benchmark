FROM maven:3.9.9-eclipse-temurin-21

RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-pip unzip zip ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work

COPY LIMEN_TED_v0.2_WAVE1_EXEC.zip /work/
COPY tools/run_and_collect.sh /work/run_and_collect.sh

RUN chmod +x /work/run_and_collect.sh

CMD ["/work/run_and_collect.sh"]
