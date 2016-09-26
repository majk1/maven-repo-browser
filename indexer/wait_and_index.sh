#!/bin/bash

MAVEN_REPO=/maven2/web

while true; do
        echo "Waiting for change"
        inotifywait -r -e modify -e move -e moved_to -e moved_from -e create -e delete -e close_write ${MAVEN_REPO}
        sleep 10
        echo "Indexing repo ${MAVEN_REPO}"
        /maven2/index.sh "${MAVEN_REPO}"
done;
