# Read in the in memory database schema.
sqlite3 ':memory:' < '/home/justin/projects/mindless/server/api/data/Mindless.sql'

if [ $? -ne 0 ];
then
  echo "Validating Mindless.sql schema failed."
  exit 1
fi
