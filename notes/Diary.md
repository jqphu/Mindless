# [2021-17-23] 16:18
Well it's been a while since I've added an entry. Let's do something...

I wonder if there's a use for a "pause". Just because I can't use it consistently.

TODO:
* [] Add a rename button (warmup task!)

# [2020-11-01] 15:39 - 17:23
## Start
Just working the home page I guess?

## End of session
Set up basic home page tab view.

"Finished" the accounts page. This is kept very scratch like since it is not part of core
functionality. We will re-visit this and what we really want here (probably a settings style with
editing name etc) later.

TODO: Homepage! Implement the core homepage :)

# [2020-10-18]

## Start
New diary format! Trying to standardize on vimwiki :)

Just some casual Sunday programming. No major goals / milestones.

I was listening to How I Built This with Guy Raz and now motivated to build things again :P.
At least my hiatuses are shorter and shorter.

## During

TODO:
* [X] Finish registration page
* [X] Fix pedantic static analysis issues
~~* [ ] Add build watcher pubspec~~
  * This wasn't what I was expecting
* [X] Secure storage to persist login information

We will clear the secure storage when we press "logout" in the home page.
For now we never clear the secure storage.

Need up update SDK version for secure storage.

## End of day
We got registration done! Quite nice :) Also added some persistent storage.

Nice little chunk of work for today. Time to call it a day though.

# [2020-10-16] 19:21 - 20:49
A one month hiatus :) as always.

Goals:
* Work on login / registration page.

Completed:
* Add registration page
* Contains text fields for username and name
* Added a floating action button

TODO:
* Add the register pipeline to the server.
* Add pending request with a CircularIndicator

# [2020-09-04] 20:50

Goal to start actually comitting out app code.

Goal: Get a production demo app following https://flutter.dev/docs/deployment/android

## Adding a launcher icon

Using [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) and follow
the steps on there!

The icon is a little smaller than I'd like but we can fix that later.

## Signing the app

Create a keystore in hidden home directory.

but we can work with it!

# Colors

We probably want to just stick to Material themeing and coloring. The only problem is I have no idea
how to color an app.

Reading: https://material.io/design/color/the-color-system.html#color-theme-creation made some sense
and found some color pallets which I [found nice](https://coolors.co/palettes/trending).
However, it's hard to tell how it will look together.

The overall goal is to go for a light and clean theme. Not too many colors, nothing too strong.
We'll figure this one out a little more as we go.

# Login page

Let's start building the login page.

Let's try to think how we can have persistent login token with the HTTP server.
This would require setting up our own authentication or using firebase and authenticating the token.
I'm going to hopefully write the code in a way that when we switch to using firebase or a proper
authentication it should be simply to insert. For now, we use shared local storage to see if the
user is already logged in. 

# [2020-08-09]  01:05 - 4:22
Yeah, what a strange time to get started. I guess we can call this a hackathon :).

* Update to latest version of sqlx

This update seemed to also fix the failure to grab lock :D.

E2E INTEGRATION! No tests yet though.

Figure out how to do some e2e tests.

# [2020-08-08]  10:18 - ~15:00
A little focus time with copyrighted music before streaming :P 
Goal:
 * Get database interface to work.

## To global or not to global
I want to be able to hide the type of database from the routes code but instead
provide an opaque database object.

My initial thought was to simply have a global connection pool object so when you
execute a transaction or update on a User it will silently grab a connection object
in the database.

This is a very c-like model and method. I was looking for the equivalent of ELF constructor
to initialize my global.

I think the correct way to do this in a high level language is to expose these is to use dependency
injection. I will create a Database object and pass that around as state. The benefit of this method
is:
1. No global uninitialized state (which is hard to do in rust, could have used a lazy static but
then I don't get an error until I try to connect).
2. Make the dependency explicit! Less global initialization but be clear that you need this database
   object and where.

## Rust constructor?
I have a database object, I want to ensure during construction it is completely valid and connected.
The downside is it is async and returns a Result. This seemed a bit strange to have a `new` that did
so much work.

Asked Rust group and convention is `new` should always just return `Self`. So just name it something
else since theres no such thing as a "constructor" in rust except for:
  ```rust
  Database {
    field1: val
  }
  ```

## Testing async fn
There is no easy way to poll a future to completion. In order to test my async fn's I bring a full
runtime.

## Connection granularity
A connection per request?
A connection per transaction?
A connection held forever?

Let's keep this very fine grained and start with a connection per transaction. This is the cleanest
and easiest to implement.

Long connections are bad due to connection issues.

Connection per request may be more optimal (do lots of work before at once) but this is an
optimization. And what do we say to early optimizations? Not today!

On a metanote. The fact that I can ask a question to a discord chat and get a response in a few
minutes is fascinating. What a great time to be learning.

## Build scripts

Currently Cargo build needs the database set up to run sql queries. We need to write a python script
that wraps cargo build and sets up the DB if it doesn't exist! TODO...

Also needs to set up database url.

# [2020-08-03]  17:45 - 19:40
Goal:
* Server side to understand associate habits with users.

Added BRAINSTORM file to show the new structure.

Achieved:
* Added new database schema
* Added git hooks to verify the schema is syntactically correct.
* Added new database rust library
* Added git hooks for doc testing

Learnings:
Need to add `set -e` to ensure bash will exit immediately when a simple command fails. E.g. if
you're doing command || exit 1 you should add `set -e` or it won't work unless it is the last
command.

# [2020-07-27]  17:30 - 19:35

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

TODO:
* Use [provider package](https://pub.dev/packages/provider) to share data between states.
* Hash the email to send to the database as the "username".
* Look into using dummy facebook account to login
* Facebook auth only works for Android app. iOS has different setup and I'm not sure about web.

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

