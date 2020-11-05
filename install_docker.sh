#!/usr/bin/env bash

#--------------------------------------------------------------------#
# Install docker
# File name    : install_docker.sh
# File version : 1.0
# Created by   : Mr. Mrunal M. Nachankar
# Created on   : Friday 30 October 2020 09:51:51 PM IST
# Modified by  : None
# Modified on  : Not yet
# Description  : This file is used for installing docker
#--------------------------------------------------------------------#

# Ask for the user password
# Script only works if sudo caches the password for a few minutes
sudo true

function version(){
    echo "install_docker script ver1.0"
}

function install_docker() {
    echo "Installing docker"

    # Release/Channel (Community edition (CE) : docker-ce)
    #   get - install from stable channel
    #   test - install from test channel
    channel_subdomain="get"

    # Ask for the user password
    # Script only works if sudo caches the password for a few minutes
    sudo true

    # Alternatively you can use the official docker install script
    wget -qO- https://${channel_subdomain}.docker.com/ | sh

    # Informative message for user to add user to docker group and logout to take it effect.
    # intentionally mixed spaces and tabs here -- tabs are stripped by "<<-EOF", spaces are kept in the output
    echo "If you would like to use Docker as a non-root user, you should now consider"
    echo "adding your user to the \"docker\" group with something like:"
    echo
    echo "  sudo usermod -aG docker your_system_username"
    echo
    echo "Remember that you will have to log out and back in for this to take effect!"
    echo
    echo "WARNING: Adding a user to the \"docker\" group will grant the ability to run"
    echo "         containers which can be used to obtain root privileges on the"
    echo "         docker host."
    echo "         Refer to https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface"
    echo "         for more information."

    # Adding all the logged in user(s) to docker group
    echo -e "\n\nINFORMATION: Adding all the logged in user(s) to docker group"
    logged_in_user_count="$(users | tr ' ' '\n' | sort -u | wc -w)"
    logged_in_users="$(users | tr ' ' '\n' | sort -u)"
    for logged_in_user in ${logged_in_users};
    do
        # sudo usermod -aG docker ${logged_in_user};
        echo "             * Added \"${logged_in_user}\" to the \"docker\" group successfully";
    done

    echo "CAUTION: Remember that you will have to log out and log in back for this to take effect! (Better to restart the system in case of non-server systems)"

}

function install_docker-compose() {
    echo "Installing docker-compose"
    # Install docker-compose
    COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | tail -n 1`
    sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
    sudo chmod +x /usr/local/bin/docker-compose
}

function install_docker-machine() {
    # Install docker-machine
    echo "Installing docker-machine"
    MACHINE_VERSION=`git ls-remote https://github.com/docker/machine | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | tail -n 1`
    sudo sh -c "curl -L https://github.com/docker/machine/releases/download/v${MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` > /tmp/docker-machine"
    sudo sh -c "install /tmp/docker-machine /usr/local/bin/docker-machine"
    sudo chmod +x /usr/local/bin/docker-machine
}

function install_docker_bash_completion() {
    echo "Installing docker bash completion"
    # bash completion
    sudo sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
}

function docker_cleanup() {
    echo "docker cleanup"
    # Install docker-cleanup command
    cd /tmp
    sudo rm -rf 76b450a0c986e576e98b
    git clone https://gist.github.com/76b450a0c986e576e98b.git
    cd 76b450a0c986e576e98b
    sudo mv docker-cleanup /usr/local/bin/docker-cleanup
    sudo chmod +x /usr/local/bin/docker-cleanup
}


# Ref: https://gist.githubusercontent.com/rosterloh/1bff516dfcdd8573fde0/raw/2d3356320ff34af370cf146b4f2d3a5e2df13327/getopts.sh
#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

# Usage / help content
help_content() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
echo "
    Usage:
        ./${0} ${BOLD}<options>${NORM}       ${REV}or${NORM}       bash ${0} ${BOLD}<options>${NORM}

    Example(s):
        ./${0} -a
        bash ${0} -a
        ./${0} -dcb
        bash ${0} -dcb
        ./${0} -m -d
        bash ${0} -m -d

    Options:
        ${REV}Short${NORM}   ${REV}Alternative${NORM}         ${REV}Long${NORM}                    ${REV}Description${NORM}
        ${BOLD}-a${NORM},     -all,               ${BOLD}--all${NORM}                   Install docker, docker-compose, docker-machine and bash-completion

        ${BOLD}-d${NORM},     -docker${NORM},            ${BOLD}--docker${NORM}                Install docker

        ${BOLD}-c${NORM},     -docker-compose${NORM},    ${BOLD}--docker-compose${NORM}        Install docker-compose

        ${BOLD}-m${NORM},     -docker-machine${NORM},    ${BOLD}--docker-machine${NORM}        Install docker-machine

        ${BOLD}-b${NORM},     -bash_completion${NORM},   ${BOLD}--bash_completion${NORM}       Install bash_completion

        ${BOLD}-r${NORM},     -docker-cleanup${NORM},    ${BOLD}--docker-cleanup${NORM}        Install docker-cleanup

        ${BOLD}-v${NORM},     -version${NORM},           ${BOLD}--version${NORM}               Version of install_docker script

        ${BOLD}-h${NORM},     -help${NORM},              ${BOLD}--help${NORM}                  Display help
"
}

function incorrect_options_or_value(){
    # Mrunal : check for - bash install_docker.sh -qewe
    if [ "$argvl" = "" ] || [ "$argvl" = "-"  ] ; then
        value="No"
    else
        value="Incorrect"
    fi
    echo -e "\n${value} option(s) provided. Hence failed to parse options...";
    echo -e "Exiting with help content." ;
    echo "";
    help_content
    exit 1;
}

# Parse command-line options
# Ref:  https://www.tutorialspoint.com/unix_commands/getopt.htm
#       https://stackoverflow.com/questions/16483119/an-example-of-how-to-use-getopts-in-bash

# Option strings
SHORT=adcmbrvh
LONG=all,docker,docker-compose,docker-machine,bash_completion,docker_cleanup,version,help

# Read the options (Parameters of getopt)
#   -o/--options is for short options like -h
#   -l/--long is for long options with double dash like --help
#       the comma separates different long options
#   -a/--alternative is for long options with single dash like -help
#   -n/--name is for script name / file name
#   $@ is all command line parameters passed to the script.
OPTIONS=$(getopt --options ${SHORT} --long ${LONG} --alternative --name "${0}" -- "${@}")

if [ ${?} != 0 ] ; then
    # echo "Incorrect options provided. Hence failed to parse options...exiting." >&2 ;
    # exit 1 ;
    incorrect_options_or_value
fi

eval set -- "${OPTIONS}"

# extract options and their arguments into variables.
while true ; do
    case "${1}" in
        -a | --all )
            install_docker;
            install_docker-machine;
            install_docker-machine;
            install_docker_bash_completion;
            opt_value="a";
            shift
            ;;
        -d | --docker )
            install_docker;
            opt_value="d";
            shift
            ;;
        -c | --docker-compose )
            install_docker-compose;
            opt_value="c";
            shift
            ;;
        -m | --docker-machine )
            install_docker-machine;
            opt_value="m";
            shift
            ;;
        -b | --bash-completion )
            install_docker_bash_completion;
            opt_value="b";
            shift
            ;;
        -r | --docker_cleanup )
            docker_cleanup;
            opt_value="r";
            shift
            ;;
        -v | --version )
            version;
            opt_value="v";
            shift
            ;;
        -h | --help )
            help_content;
            opt_value="h";
            shift
            ;;
        -- )
            shift
            break
            ;;
        * )
            echo "Internal error!"
            exit 1
            ;;
    esac
done

if [ "${opt_value}" = "" ]; then
    echo "Oops:Arg:${?}:${@}:";
    argvl=${@}
    incorrect_options_or_value
fi
