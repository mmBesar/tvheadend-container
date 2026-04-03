# 1) Base image
FROM lscr.io/linuxserver/tvheadend:latest

# 2) Become root
USER root

# 3) Alpine edge repos (optional but kept from your setup)
ARG APK_BRANCH=edge
ENV APK_MAIN="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/main" \
    APK_COMMUNITY="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/community" \
    APK_TESTING="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/testing"

# 4) Install dependencies
RUN apk add --no-cache \
      -U -X "$APK_MAIN" \
      -X "$APK_COMMUNITY" \
      -X "$APK_TESTING" \
      python3 py3-pip git

# 5) Create isolated environments
RUN python3 -m venv /opt/streamlink \
 && python3 -m venv /opt/streamlink-drm

# 6) Install normal Streamlink
RUN /opt/streamlink/bin/pip install --upgrade pip \
 && /opt/streamlink/bin/pip install streamlink

# 7) Install DRM Streamlink
RUN /opt/streamlink-drm/bin/pip install --upgrade pip \
 && /opt/streamlink-drm/bin/pip install \
      git+https://github.com/ImAleeexx/streamlink-drm

# 8) Expose both commands globally (bulletproof PATH)
RUN ln -sf /opt/streamlink/bin/streamlink /usr/bin/streamlink \
 && ln -sf /opt/streamlink-drm/bin/streamlink /usr/bin/streamlink-drm

# 9) Verify during build (optional but useful)
RUN echo "Normal: $(/usr/bin/streamlink --version)" \
 && echo "DRM: $(/usr/bin/streamlink-drm --version)"
