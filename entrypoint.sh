#!/bin/sh

# Attach host user id to container.
usermod -u ${HOST_USER_ID} -o ${USER}
chown -R ${HOST_USER_ID}:1000 ${HOMEDIR}

exec su ${USER} "$@"

