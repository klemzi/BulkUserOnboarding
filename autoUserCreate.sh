#! /bin/bash

# creates user from a CSV file

CURRENT_USER=$USERNAME
MODE=$1

# CSV file to read from
CSV_FILE=$2
if [ "$CSV_FILE" = "" ]; then
    CSV_FILE="./names.csv" # default
    echo "using default file $CSV_FILE"
fi

# check script mode
case "$MODE" in
    1 | [cC][rR][eE][aA][tT][eE])
    echo "mode: create users from $CSV_FILE"
    MODE=1
    ;;
    0 | [dD][eE][lL] | [dD][eE][lL][eE][tT][eE])
    echo "mode: delete users from $CSV_FILE"
    MODE=0
    ;;
    *)
    echo "default mode: create users from $CSV_FILE"
    MODE=1
    ;;
esac

# creates a user
function createUser() {
    NEW_USER=$1
    IS_USER=$( sudo grep $NEW_USER /etc/passwd)
    if [ "$IS_USER" != "" ]; then
        echo "$NEW_USER already exists! skipping.."
    else
        # create user
        echo "Creating user $NEW_USER"
        useradd -m $NEW_USER
        # add to developers group
        usermod -a $NEW_USER -G "developers"
        # check for .ssh folder
        if [ -f "/home/$NEW_USER/.ssh" ]; then
            echo ".ssh file exists"
            cp "/home/$CURRENT_USER/.ssh/id_rsa.pub" "/home/$NEW_USER/.ssh/authorized_keys"
        else
            mkdir "/home/$NEW_USER/.ssh"
            cp "/home/$CURRENT_USER/.ssh/id_rsa.pub" "/home/$NEW_USER/.ssh/authorized_keys"
        fi
    fi
}

# deletes a user
function deleteUser() {
    USER=$1
    IS_USER=$( sudo grep $USER /etc/passwd)
    if [ "$IS_USER" != "" ]; then
        echo "deleting user $USER"
        userdel -fr $USER # delete including home folder
    else
        echo "$USER not found! skipping..."
    fi
}

# main loop
while read -r USR
do
    if [ "$USR" != "" ]; then
        if [ "$MODE" = 0 ]; then
            deleteUser $USR
        else
            createUser $USR
        fi
    fi
done < $CSV_FILE
