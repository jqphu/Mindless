# [2020-07-23]  17:30
Goal:
* Server side to understand associate habits with users.


```
.headers on
.mode line
```
.headers on to contain column names in SQL query.
.mode line to make the format human readable.

```
SELECT * FROM habit
INNER JOIN habit_log ON habit.habit_id=habit_log.id
INNER JOIN users ON habit_log.user_id=users.id;
```

# [2020-07-23]  16:00 - 20:00

Goal:
* Update JSON being sent. 
* Creating / Deleting habits. 
* Set up digital ocean sever? 
* High priority: Users
* High priority: authentication.
 * Sessions.
 * Login screen flutter.
* Figure out how to get app on the app store.
* Visualization of data. SQL -> excel.
  * Create an endpoint to download data.
* Stretch: Hierarchical style habits

TODO: Fix code not working???? (on droplet)
TODO: Make this repo public.
TODO: Dedup habits on client side and remove case sensitivity.

# [2020-07-22]  18:54 - 23:07

Goal:
* Set up habits to be marked only once a day. 
* Unmark habits. 
* Stretch: JSONify 
* Stretch: Creating habits from the flutter app.  

Used tool: https://httpie.org/

This allows us to send HTTP requests from the command line. This is incredibly useful when doing
POST/PUT requests.

The script `reset_database.sh` is used only when we call Cargo tests. Calling this script directly
will fail since it can only be called from the path `server/api`

Simple examples:
`http localhost:8000/mindless/api/habit < test_file.json` where
`test_file` looks like:
```
{
  name: Gym,
  should_mark: true
}
```

TODO: Integrate the jsonified interface into flutter.
TODO: Pre-commit hook for testing rust server.

# [2020-07-22]  20:53
Bit of a late one but J Cole dropped two songs so you know we coding tonight.

Let's work on the server again and write some Rust.

Goal:
* Get habits flagged only once per day.
  * Hardcode to SF time for now...
* Send data using JSON instead of just a raw path.
  * Will make it easier for us to expand later.


# [2020-07-20]  06:30 - 08:30
Yes daily...

Goal: Get a simple http request going 

Struggled quite a bit with this :P. But learnt a bunch.
First we can't use localhost because localhost is the loopback for the android device itself. This
makes sense! Instead the emulator uses 10.0.2.2 to represent the host device. Ended up using this
but kept getting a connection denied. The error message showed a random port which seems to be a
flutter deficiency. Once I figured that out I still couldn't figure out why I couldn't reach my
endpoint. I thought it was the firewall but I disabled my iptables service and it didn't help. Then
I realized the port 8000 is closed of course. So I set up nginx to accept http requests on port 80
and send them to my localhost server. Horrah! It worked.

Need to set it up with SSL but hey at least I can quickly iterate locally now :) 


# [2020-07-07]  05:15 - 06:38
Let's make this a daily thing.

Goal: Get basic flutter app working.

Installed a bunch of dependencies (I should have wrote down steps...) and now have flutter app running on android and web. This should be fun!

This was easier than I though :D.

Next steps:
* Hard coded tracking with http request sent.
* Ability to add / remove habits.
* Verification in the server of double clicked habits.


# [2020-06-07] 15:34

Continuing. Now I have a database connection let's add a habit.

Implementing a simple query to insert a habit:

```
INSERT INTO
  habit ( habit_id )
VALUES
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Wakeup'
    )
  )
```

I assume it is faster if we do this as a single query as opposed to extracting the id and then
inserting a habit into a table. However, for simplicity let's separate this into two steps.

Setting up NGINX reverse proxy on digital ocean too. Pretty simple:

```
localion /mindless/ {
  proxy_pass http://127.0.0.1:8000;
}
```

in `/etc/nginx/sites-available/default`. Should probably make a custom file and not put it in
default.

# [2020-05-31] 13:38

Let's add some trivial habits by string.

Requirements:
1. Set once a day only.
2. Set by some arbitrary string for now (no hierarchy)

SQL Schema:
To test the schema manually.
1. `sqlite3 habits.db`   - Open the database.
2. `.read schema.sql`    - Creates the tables.
3. `.read test_data.sql` - Read in the dummy data.
4. `SELECT * FROM habit INNER JOIN habit_log ON habit.habit_id=habit_log.id` - Visualise the joined
   data.

# [2020-05-30] 12:00

Another idea another repo another try. Tracker - QR code version.

