#!/bin/bash

BD=$(dirname $0)

export REPODIR="$1"

if [ ! -d "${REPODIR}" ]; then
        echo "Invalid repository directory: ${REPODIR}"
        exit -1
fi

java -cp ${BD}/nexus-indexer-3.0.4-cli.jar org.sonatype.nexus.index.cli.NexusIndexerCli -r ${REPODIR} -i ${REPODIR}/.index -d ${REPODIR}/.index -n "Majki's repo" -t full
ruby ${BD}/browser/archetype_catalog_generator.rb --repo-path ${REPODIR} --archetype-catalog-path ${REPODIR}/archetype-catalog.xml
