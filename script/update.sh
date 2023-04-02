#!/bin/bash
set -e;

PUBKEY_REPO=https://github.com/AOSC-Dev/dev-pubkeys.git;
BRANCH=master;
LOCAL_DIR=pubkeys;
SSH_DIR=$HOME/.ssh;
AUTHORIZED_KEYS=authorized_keys;
TEMP_FILE=temp_keys;

# Pull the pubkeys
if [ ! -d $LOCAL_DIR ]; then # If the directory does not exist.
	git clone $PUBKEY_REPO -b $BRANCH $LOCAL_DIR;
elif [ ! -d $LOCAL_DIR/.git ]; then # If the directory isn't a git repo.
	rm -Rf $LOCAL_DIR;
	git clone $PUBKEY_REPO -B $BRANCH $LOCAL_DIR;
fi
pushd $LOCAL_DIR;
git pull;
git checkout master;
popd;

# Update pubkeys
if [ -f $SSH_DIR/$AUTHORIZED_KEYS ]; then
	cat $SSH_DIR/$AUTHORIZED_KEYS > $TEMP_FILE;
fi
cat $LOCAL_DIR/authorized_keys >> $TEMP_FILE;
if [ ! -d $SSH_DIR ]; then
	mkdir -p $SSH_DIR;
fi
awk '!seen[$0]++' $TEMP_FILE > $SSH_DIR/$AUTHORIZED_KEYS; # Remove duplicated keys
rm $TEMP_FILE; # Remove temp file

# Fix permission
chmod 700 $SSH_DIR;
chmod 600 $SSH_DIR/$AUTHORIZED_KEYS;
chmod go-w ~;
