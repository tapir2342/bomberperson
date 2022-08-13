FROM frolvlad/alpine-glibc:alpine-3.15_glibc-2.34
ARG GODOT_VERSION="3.5"
ARG RELEASE_NAME="stable"

EXPOSE 23420/udp
USER root
RUN apk add --no-cache scons pkgconf gcc g++ libx11-dev libxcursor-dev libxinerama-dev libxi-dev libxrandr-dev libexecinfo-dev wget zip unzip

RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux_server.64.zip \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux_server.64.zip \
    && mv Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux_server.64 /usr/local/bin/godot \
    && rm -f Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux_server.64.zip


WORKDIR /game
ADD . /game
CMD ["/usr/local/bin/godot"]

