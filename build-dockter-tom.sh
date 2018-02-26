#!/bin/bash
#
#  This file is the first command in Jenkins pipeline - sets bash debug mode & kicks off dockter-tom container build

set -e

docker build -t dockter-tom .
