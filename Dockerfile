FROM lscr.io/linuxserver/tvheadend:latest

USER root

ARG APK_BRANCH=edge
ENV APK_MAIN="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/main" \
    APK_COMMUNITY="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/community" \
    APK_TESTING="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/testing"

# ✅ Add build dependencies
RUN apk add --no-cache \
      -U -X "$APK_MAIN" \
      -X "$APK_COMMUNITY" \
      -X "$APK_TESTING" \
      python3 py3-pip git \
      build-base python3-dev libffi-dev openssl-dev cargo

# Create venvs
RUN python3 -m venv /opt/streamlink \
 && python3 -m venv /opt/streamlink-drm

# Normal streamlink
RUN /opt/streamlink/bin/pip install --upgrade pip \
 && /opt/streamlink/bin/pip install streamlink

# DRM streamlink (now succeeds)
RUN /opt/streamlink-drm/bin/pip install --upgrade pip \
 && /opt/streamlink-drm/bin/pip install \
      git+https://github.com/ImAleeexx/streamlink-drm

# Expose both
RUN ln -sf /opt/streamlink/bin/streamlink /usr/bin/streamlink \
 && ln -sf /opt/streamlink-drm/bin/streamlink /usr/bin/streamlink-drm

# Verify
RUN echo "Normal: $(streamlink --version)" \
 && echo "DRM: $(streamlink-drm --version)"
