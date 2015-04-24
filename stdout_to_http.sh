#!/bin/bash
inotifywait -e create,delete,modify,move -mrq /home/rpienaar/ips/galleria | xargs -I DATA curl http://localhost:8090/entry -d DATA -H "Content-Type: text/plain"