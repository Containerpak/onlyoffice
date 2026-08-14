FROM ubuntu:26.04 AS source

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates curl desktop-file-utils xz-utils && \
    curl -fsSL http://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors-9.4.0-x64.tar.xz \
      -o /tmp/onlyoffice.tar.xz && \
    echo 'd054d35f6c11274755cdad32683e8238f886420756c6cdcbf68c3b89ea66675c  /tmp/onlyoffice.tar.xz' | sha256sum -c - && \
    mkdir -p /tmp/onlyoffice && \
    tar -xJf /tmp/onlyoffice.tar.xz -C /tmp/onlyoffice && \
    mkdir -p /out/opt/onlyoffice /out/usr/share/applications && \
    cp -a /tmp/onlyoffice/opt/onlyoffice/desktopeditors /out/opt/onlyoffice/desktopeditors && \
    install -Dm644 /tmp/onlyoffice/usr/share/applications/onlyoffice-desktopeditors.desktop \
      /out/usr/share/applications/org.onlyoffice.desktopeditors.desktop && \
    desktop-file-edit --set-key=Exec --set-value='desktopeditors %U' \
      /out/usr/share/applications/org.onlyoffice.desktopeditors.desktop && \
    desktop-file-edit --set-key=Icon --set-value=org.onlyoffice.desktopeditors \
      /out/usr/share/applications/org.onlyoffice.desktopeditors.desktop && \
    sed -i 's#^Exec=/usr/bin/onlyoffice-desktopeditors#Exec=desktopeditors#' \
      /out/usr/share/applications/org.onlyoffice.desktopeditors.desktop && \
    for size in 16 24 32 48 64 128 256; do \
      install -Dm644 "/tmp/onlyoffice/usr/share/icons/hicolor/${size}x${size}/apps/onlyoffice-desktopeditors.png" \
        "/out/usr/share/icons/hicolor/${size}x${size}/apps/org.onlyoffice.desktopeditors.png"; \
    done

FROM ghcr.io/containerpak/gtk3:main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    ca-certificates libasound2t64 libcups2t64 libice6 libnotify4 libnss3 \
    libsm6 libx11-xcb1 libxss1 && \
    cpak-clean-junk

COPY --from=source /out/ /
COPY desktopeditors /usr/bin/desktopeditors
