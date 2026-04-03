# 1) Base image
FROM lscr.io/linuxserver/tvheadend:latest

USER root

ARG APK_BRANCH=edge
ENV APK_MAIN="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/main" \
    APK_COMMUNITY="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/community" \
    APK_TESTING="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/testing"

ENV PIPX_HOME=/usr/local/pipx \
    PIPX_BIN_DIR=/usr/local/bin \
    PATH=/usr/local/bin:${PATH}

# Step A — install system packages
RUN apk add --no-cache \
      -U -X "$APK_MAIN" \
      -X "$APK_COMMUNITY" \
      -X "$APK_TESTING" \
      python3 py3-pip git pipx

# Step B — install streamlink-drm
RUN pipx install --system-site-packages \
      git+https://github.com/ImAleeexx/streamlink-drm \
 && mv /usr/local/bin/streamlink /usr/local/bin/streamlink-drm

# Step C — install official streamlink
RUN python3 -m pip install --upgrade --break-system-packages streamlink

# Step D — verify
RUN echo "Streamlink: $(streamlink --version)" \
 && echo "Streamlink-DRM: $(streamlink-drm --version || echo 'n/a')"
