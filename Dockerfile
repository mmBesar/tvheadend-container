# Use the same base as linuxserver/tvheadend
FROM lscr.io/linuxserver/tvheadend:latest

# Become root to install packages
USER root

# Mirror your APK repos (edge branch to get the latest pipx, python3, etc.)
ARG APK_BRANCH=edge
ENV APK_MAIN="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/main" \
    APK_COMMUNITY="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/community" \
    APK_TESTING="http://dl-cdn.alpinelinux.org/alpine/${APK_BRANCH}/testing"

# Install Python3, pip, git, pipx, then use pipx to install streamlink‑drm
# and pip to install the latest streamlink
RUN apk add --no-cache \
      -U -X "$APK_MAIN" \
      -X "$APK_COMMUNITY" \
      -X "$APK_TESTING" \
      python3 py3-pip git pipx \
 && pipx ensurepath \
 && pipx install --system-site-packages git+https://github.com/ImAleeexx/streamlink-drm \
 && python3 -m pip install --upgrade --break-system-packages streamlink \
 && echo "Installed Streamlink: $(streamlink --version)" \
 && echo "Installed Streamlink‑DRM: $(streamlink --version-drm || echo 'unknown')"

# Ensure the pipx binary path is in PATH for the 'abc' user
# By default pipx links binaries into /root/.local/bin
# linuxserver images run tvheadend under the 'abc' user, whose home is /config
ENV PATH="/config/.local/bin:${PATH}"

# Drop back to the 'abc' user that runs tvheadend
USER abc
