#!/usr/bin/env bash
# Script to add a user to Linux system and SAMBA for Apple Time Machine
# -------------------------------------------------------------------------
# Copyright (c) 2018 Furious ⬟ Warrior <https://github.com/FuriousWarrior>
# This script is licensed under Apache License 2.0
# Comment/suggestion: 
# -------------------------------------------------------------------------
# The user does not have a system shell and home directory
# -------------------------------------------------------------------------
# It may be necessary to establish.
# apt install makepasswd
# -------------------------------------------------------------------------
if [ $(id -u) -eq 0 ]; then
        read -p "Enter username : " username
        egrep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                        echo "$username exists!"
                        exit 1
        else
            password=$(cat /dev/urandom | tr -d -c 'a-zA-Z0-9' | fold -w 6 | head -1)
                        echo "The generated password is: "$password
                        useradd -p $password -M -s /bin/false $username
        [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"

                                (echo "$password"; echo "$password") | /usr/local/samba/bin/smbpasswd -s -a "$username"
                                echo "User has been added to samba!"
                                mkdir -m 700 /srv/backup/timemachine/$username

                                chown $username /srv/backup/timemachine/$username

                                cat <<EndXML > /srv/backup/timemachine/$username/.com.apple.TimeMachine.quota.plist
                                <?xml version="1.0" encoding="UTF-8"?>
                                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                                <plist version="1.0">
                                <dict>
                                <key>GlobalQuota</key>
                                <integer>800000000000</integer>
                                </dict>
                                </plist>
                                EndXML
        fi
else
        echo "Only root may add a user to the system!"
        exit 2
fi
