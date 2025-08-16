# syntax=docker/dockerfile:1

FROM openjdk:21-jdk-buster

LABEL version="1.13.2"
LABEL homepage.group=Minecraft
LABEL homepage.name="FTB OceanBlock 2"
LABEL homepage.icon="https://cdn.feed-the-beast.com/blob/fa/fae647b9fa950ab09081ca6b395ea02dd06c7532b09b22fc3eb035b3092f7f78.png"
LABEL homepage.widget.type=minecraft
LABEL homepage.widget.url=udp://FTB-Ocean-Block-2:25565


RUN apt-get update && apt-get install -y curl && \
 adduser --uid 99 --gid 100 --home /data --disabled-password minecraft

COPY launch.sh /launch.sh
RUN chmod +x /launch.sh

USER minecraft

VOLUME /data
WORKDIR /data

EXPOSE 25565/tcp

ENV MOTD="FTB OceanBlock 2 v1.13.2 Server Powered by Docker"
ENV LEVEL=world
ENV JVM_OPTS="-Xms4096m -Xmx6144m"

CMD ["/launch.sh"]