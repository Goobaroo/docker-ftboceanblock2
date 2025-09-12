# syntax=docker/dockerfile:1

FROM openjdk:21-jdk-bookworm

LABEL version="1.10.2"
LABEL homepage.group=Minecraft
LABEL homepage.name="FTB NeoTech"
LABEL homepage.icon="https://cdn.feed-the-beast.com/blob/c8/c853e9a0534b3e83a2b2dc90fd439db77b8094c5f6b06e92d8e0072212d89bb6.png"
LABEL homepage.widget.type=minecraft
LABEL homepage.widget.url=udp://FTB-NeoTech:25565


RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && adduser --uid 99 --gid 100 --home /data --disabled-password minecraft

COPY launch.sh /launch.sh
RUN chmod +x /launch.sh

USER minecraft

VOLUME /data
WORKDIR /data

EXPOSE 25565/tcp

ENV MOTD="FTB NeoTech v1.10.2 Server Powered by Docker"
ENV LEVEL=world
ENV JVM_OPTS="-Xms4096m -Xmx6144m"

CMD ["/launch.sh"]