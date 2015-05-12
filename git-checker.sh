#!/bin/bash

LOCAL_HEAD=`git show-ref refs/heads/master | awk '{print $1}'`
REMOTE_HEAD=`git ls-remote --heads | grep refs/heads/master | awk '{print $1}'`

if [[ $LOCAL_HEAD != $REMOTE_HEAD ]]; then 
        git pull
fi 



