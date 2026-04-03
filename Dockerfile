FROM lscr.io/linuxserver/tvheadend:latest

USER root

ARG APK_BRANCH=edge
ENV APK_MAIN="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/main" \
    APK_COMMUNITY="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/community" \
    APK_TESTING="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/testing"

ENV PIPX_HOME=/usr/local/pipx \
    PIPX_BIN_DIR=/usr/local/bin \
    PATH=/usr/local/bin:${PATH}

RUN apk add --no-cache \
      -U -X "$APK_MAIN" \
      -X "$APK_COMMUNITY" \
      -X "$APK_TESTING" \
      python3 py3-pip py3-lxml git pipx

# Install streamlink-drm with lxml constraint ignored, using system lxml 6.x
RUN pip install --break-system-packages --no-deps \
      git+https://github.com/ImAleeexx/streamlink-drm \
 && pip install --break-system-packages \
      certifi isodate pycountry pycryptodome PySocks requests urllib3 websocket-client \
 && cp $(which streamlink) /usr/local/bin/streamlink-drm

# Install official streamlink (will use same system lxml 6.x, no conflict)
RUN pip install --break-system-packages --upgrade streamlink

# Verify both
RUN echo "Streamlink:     $(streamlink --version)" \
 && echo "Streamlink-DRM: $(streamlink-drm --version)"
