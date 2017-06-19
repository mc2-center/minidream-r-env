#!/usr/bin/env bash
# Copy a module folder from a user's home space to the shared space.
#
# $1 = path to user's module folder
#
# Usage:
# copy_to_shared.sh /home/jeddy/modules/demo

USER_MODULE=$1
cp -r ${USER_MODULE} /home/shared/modules/
