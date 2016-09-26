## maven repository browser

This is a standalone lightweight maven repository setup written in ruby with some java and linux dependencies.

Components:

 * **The nginx example config file**  
   This config file shows how to create a webdav capable virtul host which can be function as a maven repository, that can be used with regular maven, and can receive deploy requiests (*webdav PUT*)
   
 * **Indexer and watcher shell scripts**  
   The `index.sh` script uses the **nexus-indexer.jar** file to index the files to be able to use as a maven repo. The `wait_and_index.sh` starts an inotifywait service to watch the repo directory and start the indexer when a new GAV has been deployed.
   
 * **Standalone ruby web server**  
   The standalone web server written in ruby, which is a maven repository browser with some search function
 
 * **Start/stop scripts**  
   The `start.sh` and the `stop.sh` to start the standalone web server (*maven-repo-browser*)

Useful low memory VPS.
