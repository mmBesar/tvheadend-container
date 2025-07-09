# Use the same base as linuxserver/tvheadend
FROM lscr.io/linuxserver/tvheadend:latest
# (multi‑arch manifest that picks the right Alpine‑based image) :contentReference[oaicite:0]{index=0}

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
    # streamlink‑drm repo as in your script :contentReference[oaicite:1]{index=1} \
 && python3 -m pip install --upgrade --break-system-packages streamlink \
 && echo "Installed Streamlink: $(streamlink --version)" \
 && echo "Installed Streamlink‑DRM: $(streamlink --version-drm || echo 'unknown')"

# Ensure the pipx binary path is in PATH (matches where 'abc' will run things)
/* 
   By default pipx links binaries into /root/.local/bin; 
   linuxserver images use /config/.local/bin for per‑user installs
*/
ENV PATH="/config/.local/bin:${PATH}"

# Drop back to the 'abc' user that runs tvheadend
USER abc

# All done – tvheadend startup remains unchanged
