#!/bin/bash

cd ..

if [ ! -e maven-repo-browser.pid ]; then
        echo "not running"
        exit 1
fi

PID=$(cat maven-repo-browser.pid)

ps aux | grep -q "${PID}.*ruby.*server.rb.*"
if [ $? -eq 0 ]; then
        echo -n "Stopping PID: ${PID}..."
        kill ${PID}
        rm maven-repo-browser.pid
        echo "done"
fi
