# 1) Base image (inherits the default ENTRYPOINT + default USER from LSIO)
FROM lscr.io/linuxserver/tvheadend:latest

# 2) Switch to root so we can install things
USER root

# 3) Alpine edge mirrors (for the latest pipx, etc.)
ARG APK_BRANCH=edge
ENV APK_MAIN="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/main" \
    APK_COMMUNITY="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/community" \
    APK_TESTING="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/testing"

# 4) Make pipx install into /usr/local (not /config)
ENV PIPX_HOME=/usr/local/pipx \
    PIPX_BIN_DIR=/usr/local/bin \
    PATH=/usr/local/bin:${PATH}

# 5) Install Python, pip, git, pipx → install streamlink & streamlink-drm
RUN apk add --no-cache \
      -U -X "$APK_MAIN" \
      -X "$APK_COMMUNITY" \
      -X "$APK_TESTING" \
      python3 py3-pip git pipx \
 && pipx ensurepath \
 && pipx install --system-site-packages git+https://github.com/ImAleeexx/streamlink-drm \
 && mv /usr/local/bin/streamlink /usr/local/bin/streamlink-drm
 && python3 -m pip install --upgrade --break-system-packages streamlink \
 && echo "Streamlink: $(streamlink --version)" \
 && echo "Streamlink‑DRM: $(streamlink --version-drm || echo 'n/a')"
