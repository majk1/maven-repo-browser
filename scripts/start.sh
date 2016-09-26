#!/bin/bash

cd ..

nohup ruby server.rb \
        --host localhost \
        --port 9999 \
        --repo-path /maven2/web \
        --repo-id majkis-repo \
        --repo-name "Majki's maven repository" \
        --repo-url "http://maven.majki.org" \
        >> maven-repo-browser.log &

echo $! > maven-repo-browser.pid
