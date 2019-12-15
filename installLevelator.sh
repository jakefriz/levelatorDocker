#!/bin/bash

## https://gist.github.com/bmaupin/c87ac42ecbbfcff4ad0d

set -x

levelator_version=Levelator-1.3.0-Python2.5

# Install dependencies
if ! dpkg -l python2.5 &> /dev/null; then
    apt-add-repository -y ppa:fkrull/deadsnakes
    apt-get update
    apt-get install -y python2.5
    apt-add-repository -ry ppa:fkrull/deadsnakes
fi
apt-get -y install coreutils libc6:i386 libc6:i386 libflac8:i386 libgcc1:i386 libogg0:i386 libsndfile1:i386 libstdc++6:i386 libvorbis0a:i386 libvorbisenc2:i386


# Download and extract Levelator
wget http://web.archive.org/web/20110616011312/http://cdn.conversationsnetwork.org/$levelator_version.tar.bz2
tar -xvf $levelator_version.tar.bz2


# Make wxPython import not fail
mkdir $levelator_version/.levelator/wx
touch $levelator_version/.levelator/wx/__init__.py


# Install wrapper script
cat << LevelatorPy > $levelator_version/.levelator/levelator.py
from __future__ import with_statement
import logging
import os
import os.path
import sys
if len(sys.argv) != 4:
    sys.exit('Usage: %s input.wav output.wav' % os.path.basename(sys.argv[1]))
# Hide noise from proj import
with open(os.devnull,'wb') as null:
    sys.stdout = null
    import proj
# Log to stdout
root = logging.getLogger()
root.removeHandler(root.handlers[0])
ch = logging.StreamHandler(sys.__stdout__)
root.addHandler(ch)
# Hide more noise
ch.setLevel(logging.WARNING)
l = proj.levelator.Levelator(proj.worker.WorkerThread)
ch.setLevel(logging.INFO)
l.callLeveler(sys.argv[2], sys.argv[3])
LevelatorPy


# Point to wrapper script
sed -i.bak '/# Launches/a infilepath=`readlink -f "$1" 2>/dev/null`\noutfilepath=`readlink -f "$2" 2>/dev/null`' $levelator_version/levelator
sed -i 's/python main.py/python2.5 levelator.py "$0" "$infilepath" "$outfilepath"/' $levelator_version/levelator


# Make it so it can be run from a symlink
sed -i 's@^cd.*@cd `dirname "$(readlink -f "$0")"`/.levelator@' $levelator_version/levelator


# Put it in place
mv $levelator_version /opt
ln -s /opt/$levelator_version/levelator /usr/local/bin/levelator
rm $levelator_version.tar.bz2