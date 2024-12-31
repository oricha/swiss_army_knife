#!/usr/bin/env bash

echo "About to install tools and settings developers need..."
echo "Are you sure? [y/N] "
read -s response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # to lower
if [[ $response =~ ^(yes|y)$ ]]
then
    echo "Installing dependencies..."
else
    echo "Skipping..."
    exit
fi

echo "Updating Homebrew..."
brew update

echo "Installing mandatory tools..."
brew install sbt
brew install scala
brew install gradle
brew install coreutils
brew install python
brew install pip
brew install git

# Java installation with OpenJDK
brew install --cask temurin

# AWS CLI installation
brew install awscli

echo "Other Cask applications..."
brew install --cask iterm2
brew install --cask caffeine
brew install --cask docker
brew install --cask go2shell
brew install --cask postman
brew install --cask xquartz
brew install --cask alfred
brew install --cask textmate
brew install --cask fluor
brew install --cask visual-studio-code
brew install --cask slack

echo "Other CLI applications..."
brew install maven
brew install github-markdown-toc
brew install httpie
brew install bash-completion
brew install brew-cask-completion
brew install catimg
brew install gawk
brew install json-c
brew install jvmtop
brew install kotlin
brew install lolcat
brew install mdp
brew install moreutils
brew install p7zip
brew install watch
brew install tree
brew install node
brew install yarn --without-node

echo "Fun CLI commands..."
brew install cmatrix
brew install cowsay
brew install ponysay
brew install figlet

echo "Pip installs..."
pip3 install --upgrade pip
pip3 install requests

echo "All done!"
