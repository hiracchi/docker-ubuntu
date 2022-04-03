#!/bin/bash

# set -e
# umask 0000

USER_ID=$(id -u)
GROUP_ID=$(id -g)

if type fixuid; then
    eval $(fixuid -q)

    if [ -z "$*" ]; then
        tail -f /dev/null
    else
        eval "$@"
    fi
else
    # change userid & usergrp
    if [ "x${GROUP_ID}" != "x0" ]; then
        groupadd --non-unique --gid ${GROUP_ID} ${GROUP_NAME}
    fi
    if [ "x${USER_ID}" != "x0" ]; then
        useradd -d /home/${USER_NAME} -m -s /bin/bash -u ${USER_ID} -g users -G sudo,video,${GROUP_NAME} ${USER_NAME}
    fi

    # entrypoint
    if [ -z "$*" ]; then
        tail -f /dev/null
    else
        if [ "x${USER_ID}" != "x0" ]; then
            sudo -H -u ${USER_NAME} "$@"
        else
            eval "$@"
        fi
    fi
fi
