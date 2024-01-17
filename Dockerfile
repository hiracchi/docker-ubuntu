FROM ubuntu:22.04

ARG GROUP_NAME=docker
ARG USER_NAME=docker
ARG USER_ID=1000
ARG GROUP_ID=1000
ENV GROUP_NAME=${GROUP_NAME}
ENV USER_NAME=${USER_NAME}

ARG FIXUID_ARCH=amd64
ARG FIXUID_VER=0.6.0

# -----------------------------------------------------------------------------
# base settings
# -----------------------------------------------------------------------------
# switch apt repository
ARG APT_SERVER="archive.ubuntu.com"
# ARG APT_SERVER="jp.archive.ubuntu.com"
# ARG APT_SERVER="ftp.riken.jp/Linux"
# ARG APT_SERVER="ftp.jaist.ac.jp/pub/Linux/"

ENV TZ="Asia/Tokyo"
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive

RUN set -x && \
  sed -i -e "s|archive.ubuntu.com|${APT_SERVER}|g" /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  apt-utils sudo wget curl ca-certificates gnupg locales tzdata bash \
  && \
  apt-get update && \
  apt-get upgrade -y && \
  echo "dash dash/sh boolean false" | debconf-set-selections && \
  dpkg-reconfigure dash && \
  locale-gen ja_JP.UTF-8 && \
  update-locale LANG=ja_JP.UTF-8 && \
  echo "${TZ}" > /etc/timezone && \
  mv /etc/localtime /etc/localtime.orig && \
  ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*


# -----------------------------------------------------------------------------
# fixuid
# -----------------------------------------------------------------------------
ARG GROUP_NAME=docker
ARG USER_NAME=docker
ARG USER_ID=1000
ARG GROUP_ID=1000
ENV GROUP_NAME=${GROUP_NAME}
ENV USER_NAME=${USER_NAME}

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  apt-utils sudo curl wget ca-certificates gnupg \
  && \
  apt-get clean && apt-get autoclean && \
  rm -rf /var/lib/apt/lists/* && \
  \
  groupadd --gid ${GROUP_ID} ${GROUP_NAME} && \
  useradd --uid ${USER_ID} -g ${GROUP_NAME} -G sudo,root \
  --home-dir /home/${USER_NAME} --create-home \
  --shell /usr/bin/bash ${USER_NAME} && \
  echo "${USER_NAME}:${USER_NAME}" | chpasswd && \
  echo "%${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USER_NAME} && \
  chmod 0400 /etc/sudoers.d/${USER_NAME} && \
  \
  curl -SsL https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VER}/fixuid-${FIXUID_VER}-linux-${FIXUID_ARCH}.tar.gz | tar -C /usr/local/bin -xzf - && \
  chown root:root /usr/local/bin/fixuid && \
  chmod 4755 /usr/local/bin/fixuid && \
  mkdir -p /etc/fixuid && \
  printf "user: ${USER_NAME}\ngroup: ${GROUP_NAME}\n" > /etc/fixuid/config.yml


# -----------------------------------------------------------------------------
# entrypoint
# -----------------------------------------------------------------------------
COPY scripts/* /usr/local/bin/
RUN set -x && \
  chmod +x /usr/local/bin/*.sh

USER ${USER_NAME}:${GROUP_NAME}
WORKDIR /home/${USER_NAME}

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# CMD ["/usr/bin/tail", "-f", "/dev/null"]

