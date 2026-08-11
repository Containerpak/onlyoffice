FROM ghcr.io/containerpak/gtk:main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates curl desktop-file-utils libasound2t64 libcups2t64 libx11-xcb1 libxss1 xz-utils && \
    curl -fsSL http://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors-9.4.0-x64.tar.xz \
      -o /tmp/onlyoffice.tar.xz && \
    echo 'd054d35f6c11274755cdad32683e8238f886420756c6cdcbf68c3b89ea66675c  /tmp/onlyoffice.tar.xz' | sha256sum -c - && \
    mkdir -p /tmp/onlyoffice && \
    tar -xJf /tmp/onlyoffice.tar.xz -C /tmp/onlyoffice && \
    mkdir -p /opt/onlyoffice /usr/share/applications && \
    cp -a /tmp/onlyoffice/opt/onlyoffice/desktopeditors /opt/onlyoffice/desktopeditors && \
    install -Dm644 /tmp/onlyoffice/usr/share/applications/onlyoffice-desktopeditors.desktop \
      /usr/share/applications/org.onlyoffice.desktopeditors.desktop && \
    desktop-file-edit --set-key=Exec --set-value='desktopeditors %U' \
      /usr/share/applications/org.onlyoffice.desktopeditors.desktop && \
    desktop-file-edit --set-key=Icon --set-value=org.onlyoffice.desktopeditors \
      /usr/share/applications/org.onlyoffice.desktopeditors.desktop && \
    for size in 16 24 32 48 64 128 256; do \
      install -Dm644 "/tmp/onlyoffice/usr/share/icons/hicolor/${size}x${size}/apps/onlyoffice-desktopeditors.png" \
        "/usr/share/icons/hicolor/${size}x${size}/apps/org.onlyoffice.desktopeditors.png"; \
    done && \
    cpak-clean-junk

COPY desktopeditors /usr/bin/desktopeditors
