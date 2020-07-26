#!/bin/sh


echo "Trashing $1"
trash $1
echo "Trash returns: $?"
sqlite3 $1 '.read data/schema.sql'
echo "Creating database $1 returns: $?"
