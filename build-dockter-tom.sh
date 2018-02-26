#!/bin/bash
#
#  This file is the first command in Jenkins pipeline - basically sets bash debug mode

set -e

docker build -t dockter-tom .
