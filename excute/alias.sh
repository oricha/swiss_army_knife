#!/usr/bin/env bash

alias httpie='http --verify=no'
alias gitpullall='find . -type d -depth 1 -exec echo "{}" \; -exec git -C {} pull \;'
