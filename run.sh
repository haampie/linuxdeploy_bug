#!/bin/bash

# Download linuxdeployqt and make executable
wget https://github.com/probonopd/linuxdeployqt/releases/download/6/linuxdeployqt-6-x86_64.AppImage
chmod a+x linuxdeployqt-6-x86_64.AppImage

# Compile the project
g++ -O2 -shared -o deps/libdep1.so -Wl,-rpath="\$ORIGIN" deps/dep1.cc
g++ -O2 -shared -o deps/libdep2.so -Wl,-rpath="\$ORIGIN" deps/dep2.cc -Ldeps -ldep1
g++ -O2 -o Example.AppDir/usr/bin/example -Wl,-rpath="$(realpath deps)" src/example.cc -Ldeps -ldep2

# Deploy
# My development environment is Ubuntu 18.04, so adding the flag -unsupported-bundle-everything
# on Ubuntu 16.04 the -bundle-non-qt-libs should be sufficient
./linuxdeployqt-6-x86_64.AppImage Example.AppDir/example.desktop -unsupported-bundle-everything -bundle-non-qt-libs
