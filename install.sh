#!/bin/bash

set -e;

PUBKEY_REPO="https://github.com/AOSC-Dev/dev-pubkeys.git";
BRANCH="master";
LOCAL_DIR="pubkeys";
SCRIPT_INSTALL_DIR="$HOME/.update_pubkeys"

pushd /tmp;

if [ -d $LOCAL_DIR ]; then
	rm -Rf $LOCAL_DIR;
fi

echo ">>> Downloading scripts...";

git clone $PUBKEY_REPO -b $BRANCH $LOCAL_DIR;
pushd $LOCAL_DIR;

echo ">>> Copying files...";
if [ -d $SCRIPT_INSTALL_DIR ]; then
	rm -Rf $SCRIPT_INSTALL_DIR;
	mkdir -p $SCRIPT_INSTALL_DIR;
else
	mkdir -p $SCRIPT_INSTALL_DIR;
fi
cp script/update.sh $SCRIPT_INSTALL_DIR/update.sh;

echo ">>> Copying systemd files... (requires sudo)";
sed -i "s|User=aosc|User=$USER|g" systemd/update_pubkeys.service;
sed -i "s|Environment=\"HOME=/home/aosc\"|Environment=\"HOME=$HOME\"|g" systemd/update_pubkeys.service;
sed -i "s|WorkingDirectory=/home/aosc/.update_pubkeys|WorkingDirectory=$SCRIPT_INSTALL_DIR|g" systemd/update_pubkeys.service;
sed -i "s|ExecStart=/home/kay/.update_pubkeys/update.sh|ExecStart=$SCRIPT_INSTALL_DIR/update.sh|g" systemd/update_pubkeys.service;

sudo cp systemd/update_pubkeys.service /etc/systemd/system/update_pubkeys_$USER.service;
sudo cp systemd/update_pubkeys.timer /etc/systemd/system/update_pubkeys_$USER.timer

sudo systemctl daemon-reload;
sudo systemctl start update_pubkeys_$USER --now;

echo ">>> Enabling timer..."
sudo systemctl enable update_pubkeys_$USER.timer;
sudo systemctl start update_pubkeys_$USER.timer;

echo ">>> Cleaning up..."
popd;
rm -Rf $LOCAL_DIR;
popd;

echo ">>> Done."
