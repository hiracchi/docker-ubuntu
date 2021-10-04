FROM ubuntu:20.04

ARG GROUP_NAME=docker
ARG USER_NAME=docker
ARG USER_ID=1000
ARG GROUP_ID=1000
ENV GROUP_NAME=${GROUP_NAME}
ENV USER_NAME=${USER_NAME}


# -----------------------------------------------------------------------------
# base settings
# -----------------------------------------------------------------------------
# switch apt repository
ARG APT_SERVER="archive.ubuntu.com"
# ARG APT_SERVER="jp.archive.ubuntu.com"
# ARG APT_SERVER="ftp.riken.jp/Linux"
# ARG APT_SERVER="ftp.jaist.ac.jp/pub/Linux/"

ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Asia/Tokyo"
# ENV LANG="ja_JP.UTF-8" LANGUAGE="ja_JP:en" LC_ALL="ja_JP.UTF-8"
ENV LANG=C LC_CTYPE=en_US.UTF-8 

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
  locale-gen en_US.UTF-8 && \
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
RUN set -x && \
  groupadd --gid ${GROUP_ID} ${GROUP_NAME} && \
  useradd --uid ${USER_ID} -g ${GROUP_NAME} -G sudo,root \
  --home-dir /home/${USER_NAME} --create-home \
  --shell /usr/bin/bash ${USER_NAME} && \
  echo "${USER_NAME}:${USER_NAME}" | chpasswd && \
  echo "%${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USER_NAME} && \
  chmod 0400 /etc/sudoers.d/${USER_NAME}


RUN set -x && \
  curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5.1/fixuid-0.5.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
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
# ENTRYPOINT ["fixuid"]
# CMD ["/usr/bin/tail", "-f", "/dev/null"]
