*(First try with ruby)*

---

# Lightweight maven repository and repository browser

This is a standalone lightweight maven repository setup written in ruby with some java and linux dependencies.

Components:

 * **The nginx example config file**  
   This config file shows how to create a webdav capable virtual host which can work as a maven repository,
   can be used with regular maven, and is able to receive deploy requests (*webdav PUT*)
   
 * **Indexer and watcher shell scripts**  
   The `index.sh` script uses the **nexus-indexer.jar** file to index the files on order to act like a 
   maven repo. The `wait_and_index.sh` starts an inotifywait service to watch the repo directory and start
   the indexer when a new GAV has been deployed (uploaded).
   
 * **Standalone ruby web server**  
   The standalone web server written in ruby, which is a maven repository browser with some search functionality
 
 * **Start/stop scripts**  
   The `start.sh` and the `stop.sh` to start the standalone web server (*maven-repo-browser*)

Useful for low memory VPS.
