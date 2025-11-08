# syntax=docker/dockerfile:1

FROM eclipse-temurin:21-jdk

LABEL version="1.0.8"
LABEL homepage.group=Minecraft
LABEL homepage.name="FTB StoneBlock 4"
LABEL homepage.icon="https://cdn.feed-the-beast.com/blob/5b/5b10fbf6e78546a5a4be81a2d311718cc24d29e4277e747028d787d6fec0be46.webp"
LABEL homepage.widget.type=minecraft
LABEL homepage.widget.url=udp://FTB-StoneBlock-4:25565


RUN apt-get update && apt-get install -y curl jq && \
 adduser --uid 99 --gid 100 --home /data --disabled-password minecraft

COPY launch.sh /launch.sh
RUN chmod +x /launch.sh

USER minecraft

VOLUME /data
WORKDIR /data

EXPOSE 25565/tcp

ENV MOTD="FTB StoneBlock 4 v1.0.8 Server Powered by Docker"
ENV LEVEL=world
ENV JVM_OPTS="-Xms6144m -Xmx8192m"

CMD ["/launch.sh"]
