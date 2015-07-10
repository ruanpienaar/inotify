#!/bin/bash
# $1 -> DIR
inotifywait -e create,delete,modify,move -mrq $1 | xargs -I DATA curl http://localhost:8090/entry -d DATA -H "Content-Type: text/plain"
