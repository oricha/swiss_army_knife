#!/bin/bash

################################################################################
# Functions and utilities
################################################################################


dclean(){
    docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null || true
    docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null  || true
}

selectWithDefault() {
  # https://stackoverflow.com/questions/42789273/bash-choose-default-from-case-when-enter-is-pressed-in-a-select-prompt
  #
  # print the prompt message and call the custom select function.
  # echo "Include audits (default is 'Nope')?"
  # optionsAudits=('Yep' 'Nope')
  # opt=$(selectWithDefault "${optionsAudits[@]}")
  #
  ## Process the selected item.
  # case $opt in
  #   'Yep') includeAudits=true; ;;
  #   ''|'Nope') includeAudits=false; ;; # $opt is '' if the user just pressed ENTER
  # esac

  local item i=0 numItems=$#

  # Print numbered menu items, based on the arguments passed.
  for item; do         # Short for: for item in "$@"; do
    printf '%s\n' "$((++i))) $item"
  done >&2 # Print to stderr, as `select` does.

  # Prompt the user for the index of the desired item.
  while :; do
    printf %s "${PS3-#? }" >&2 # Print the prompt string to stderr, as `select` does.
    read -r index
    # Make sure that the input is either empty or that a valid index was entered.
    [[ -z ${index} ]] && break  # empty input
    (( index >= 1 && index <= numItems )) 2>/dev/null || { echo "Invalid selection. Please try again." >&2; continue; }
    break
  done

  # Output the selected item, if any.
  [[ -n ${index} ]] && printf %s "${@: index:1}"

}

runit() {
   docker run -it --rm $@
}

rundeamon() {
   docker run -d --rm $@
}

##############################################################################
# CLI - Terminal commands
##############################################################################
awscli() {
   runit \
     --name awscli \
     -v "${HOME}/.aws:/root/.aws:ro" \
     ivonet/aws-cli "$@"
   #-v <option_yml>:/aws:ro
}
alias daws='awscli'

ubuntu() {
    runit \
       --rm \
       -v "$(pwd)/:/input:ro" \
       -v "$(pwd)/:/output:rw" \
       ivonet/ubuntu:18.04 /bin/bash
}


##############################################################################
# Just for fun ...
##############################################################################
ponysay() {
    runit ivonet/ponysay $@
}

hollywood() {
    runit ivonet/hollywood
}
alias busyguy='hollywood'
alias imbusy='hollywood'

##############################################################################
# Development/ Compilers / Tools
##############################################################################
ubuntudev() {
    runit -v $(pwd):/project ivonet/ubuntu:dev
}


##############################################################################
# Applications
##############################################################################

drawio() {
    emulate -L sh
    RUNNING=$(docker inspect --format="{{ .State.Running }}" draw.io 2> /dev/null)

    if [ $? -eq 1 ] || [ "$RUNNING" == "false" ]; then
      docker run -d --rm --name draw.io -p 4000:80 -p 4443:443 ivonet/draw.io
      /usr/bin/osascript -e 'display notification "Starting draw.io..." with title "Draw.io" '
      open http://localhost:4000?offline=1
    else
      /usr/bin/osascript -e 'display notification "Stopping..." with title "Draw.io"'
      docker stop draw.io
      /usr/bin/osascript -e 'display notification "Stopped successfully." with title "Draw.io"'
    fi
}
alias draw.io='drawio'

mysqld() {
    emulate -L sh
    test_db() {
        if [ ! -d "$(pwd)/mysql-data" ]; then
            echo "First run so creating a test database..."
            mkdir -p "$(pwd)/mysql-setup" >/dev/null
            echo "CREATE DATABASE \`test\` CHARACTER SET utf8 COLLATE utf8_general_ci; \nCREATE USER 'user'@'%' IDENTIFIED BY 'secret'; \nGRANT ALL PRIVILEGES ON \`test\`.* TO 'user'@'%';" > $(pwd)/mysql-setup/0001-create_test_db_with_user.sql
        fi
    }

    RUNNING=$(docker inspect --format="{{ .State.Running }}" mysql 2>/dev/null)
    if [ $? -eq 1 ] || [ "$RUNNING" == "false" ]; then
        echo "MySQL creates a couple of folders..."
        echo "Do you wish to run MySQL in this folder? (default = Yes)"
        optionsAudits=('Yes' 'No')
        opt=$(selectWithDefault "${optionsAudits[@]}")
        case ${opt} in
            ''|'Yes' )
                /usr/bin/osascript -e 'display notification "Starting..." with title "MySQL"'
                test_db
                docker run \
                   -d \
                   --rm \
                   --name mysql \
                   -v $(pwd):/project \
                   -v $(pwd)/mysql-data:/var/lib/mysql:rw \
                   -v $(pwd)/mysql-setup:/docker-entrypoint-initdb.d \
                   -v $(pwd)/mysql-testdata:/testdata \
                   -p "3306:3306" \
                   -e MYSQL_ROOT_PASSWORD=secret \
                   ivonet/mysql "$@" >/dev/null
                return ;;
            'No' )
                return;;
        esac
    else
      /usr/bin/osascript -e 'display notification "Stopping..." with title "MySQL"'
      docker stop mysql
      /usr/bin/osascript -e 'display notification "Stopped successfully." with title "MySQL"'
    fi
}

mysql() {
    emulate -L sh
    RUNNING=$(docker inspect --format="{{ .State.Running }}" mysql 2> /dev/null)
    if [ $? -eq 1 ] || [ "${RUNNING}" == "false" ]; then
        /usr/bin/osascript -e 'display notification "Please start mysqld first..." with title "MySQL"'
    else
        docker exec -it mysql mysql -u root -p "$@"
    fi
}

postgresql() {
    emulate -L sh
    test_db() {
        if [ ! -d "$(pwd)/psql-data" ]; then
            echo "First run so creating a test database..."
            mkdir -p "$(pwd)/psql-init" >/dev/null
            chmod -R 755 "$(pwd)/psql-init"

        fi
    }

    RUNNING=$(docker inspect --format="{{ .State.Running }}" postgres 2>/dev/null)
    if [ $? -eq 1 ] || [ "$RUNNING" == "false" ]; then
        if [ ! -d "$(pwd)/psql-data" ]; then
            echo "PostgreSQL creates a couple of folders..."
            echo "Do you wish to run PostgreSQL in this folder? (default = Yes)"
            optionsAudits=('Yes' 'No')
            opt=$(selectWithDefault "${optionsAudits[@]}")
        else
            opt='Yes'
        fi
        case ${opt} in
            ''|'Yes' )
                /usr/bin/osascript -e 'display notification "Starting..." with title "Postgres"'
                test_db
                rundeamon \
                   --name postgres \
                   -v $(pwd)/psql-init:/docker-entrypoint-initdb.d \
                   -v $(pwd)/psql-data:/var/lib/postgresql/data \
                   -v ${HOME}/.ssh:/root/.ssh \
                   -e POSTGRES_USER=dev \
                   -e POSTGRES_PASSWORD=simpassword \
                   -e PGPASSWORD=simpassword \
                   -e POSTGRES_DB=store_rfid_scan_journal \
                   -p "5432:5432" \
                   postgres:9.6 "$@"
                return ;;
            'No' )
                return;;
        esac
    else
      /usr/bin/osascript -e 'display notification "Stopping..." with title "Postgres"'
      docker stop postgres
      /usr/bin/osascript -e 'display notification "Stopped successfully." with title "Postgres"'
    fi
}

postgres() {
    emulate -L sh
    RUNNING=$(docker inspect --format="{{ .State.Running }}" postgres 2> /dev/null)
    if [ $? -eq 1 ] || [ "${RUNNING}" == "false" ]; then
        /usr/bin/osascript -e 'display notification "Please start postgresql first..." with title "Postgres"'
    else
        docker exec -it postgres psql "$@"
    fi
}
#alias psql='postgres'
alias psqllog='docker logs -f postgres'


################################################################################
# Project commands
################################################################################
# run docker images for scan-sessions
scan-sessions() {
    cd /Users/iwoltr/dev/rstrfid/scan-sessions
    VERSION=1 NETWORK_NAME=app-comms AWS_LOCAL=localhost IOT_LOCAL=localhost CLIENT_LOCAL=localhost docker-compose $@
    if [ "$1" = "up" ]; then
        open http://localhost:8082/
    fi
    cd -
}
alias ssls='alias|grep -v grep|grep dss|sort'
alias dss='scan-sessions'
alias dssu='scan-sessions up -d'
alias dssd='scan-sessions down -v'
alias dssl='scan-sessions logs -f'


rfiddb() {
    cd /Users/iwoltr/dev/env/db/postgres
    postgresql
    cd -
    psqllog
}

rfiddbinit() {
    cd /Users/iwoltr/dev/env/db/postgres
    rm -rf psql-data
    rm -rf psql-init
    mkdir psql-init
    cp -v /Users/iwoltr/dev/rstrfid/scan-gw/schema.sql ./psql-init/
    cd -
    rfiddb
}

