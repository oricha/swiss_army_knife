#!/usr/bin/env bash

echo "About to install logs of tools and settings developers need..."
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
echo "Installing mandatory tools..."
brew tap caskroom/versions
brew cask install java8
brew install sbt
brew install scala
brew install gradle
brew install awscli
brew install coreutils
brew install python
brew install pip
brew install git


echo "Other Cask applications..."
brew cask install iterm2
brew cask install caffeine
brew cask install docker-edge
brew cask install go2shell
brew cask install postman
brew cask install xquartz
brew cask install alfred
brew cask install textmate
brew cask install fluor

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

echo "Fun cli commands..."
brew install cmatrix
brew install cowsay
brew install ponysay
brew install figlet

echo "Pip installs..."
pip3 install requests
