Sets up a working webapp and database for Obelisk, a socialist economic planning program. The solver that turns data into an economic plan and writes
back into the database is written but doesn't work yet. I plan to explain more fully in the future.

You'll need a Linux machine, NPM and PostgreSQL with an empty database set up, and the appropriate postgresql-server-dev installed.
Once that's done, run su install-depend.sh and (not su) setup.sh from a PostgreSQL superuser. Finally, to start serving, run obelisk.sh.
If it doesn't work, make sure PostgreSQL is accepting local IPv6 connections.

Thanks to the creators of PostgREST (https://github.com/PostgREST/postgrest/) and it's pgjwt extension, as well as
Vue.js and Vue Router (https://github.com/vuejs), which I've taken full advantage of.

This is my first project using these tools and I expect it will be janky. I'm currently aware of the
edit history system being broken.