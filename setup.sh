#!/usr/bin/env bash
###
# NOTE:
# If you want to rerun this script in total set RE_SETUP to 1
###
RE_SETUP=1

SUPPORT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SETUP_DONE="${HOME}/.grasshoppers_setup_done"
if [[ ${RE_SETUP} != 0 ]]; then
    rm -f "${SETUP_DONE}"
fi

check=$(which brew)
if [[ -z "${check}" ]]; then
   echo "Installing brew..."
   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

check=$(which realpath)
if [[ -z "${check}" ]]; then
   echo "Installing coreutils..."
   brew install coreutils
fi



check=$(which zsh)
if [[ -z "${check}" ]]; then
   echo "Installing zsh..."
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

if [[ ! -f "${SETUP_DONE}" ]]; then
    pwd>${SETUP_DONE}

    echo "Installing essential software."
    echo "Please follow instructions..."
    sh ./install/installs.sh

    resource="${HOME}/.zshrc"
    echo "" >>${resource}
    echo "# Grasshoppers resources:" >>${resource}
    echo "for f in \${HOME}/.grasshoppers-*.sh; do source \${f}; done" >>${resource}
fi

check=$(which gimme-aws-creds)
if [[ -z "${check}" ]]; then
    check=$(which pip3)
    if [[ -z "${check}" ]]; then
       echo "Installing Python 3 for gimme-aws-creds."
       brew install python
    fi
   echo "Installing gimme-aws-creds..."
   pip3 install --upgrade gimme-aws-creds
fi

# Personal session scoped settings
rm -fv ${HOME}/.*.sh
for f in ./execute/g*.sh; do
   source="$(realpath ${f})"
   target="${HOME}/.$(basename ${f})"
   ln -sv ${source} ${target}
   chmod +x ${target}
done

echo "Done."
echo "Please stop all your terminal sessions en start new ones."
