Sets up a working webapp and database for Obelisk, a socialist economic planning program. The solver that turns data into an economic plan and writes back into the database can be found at: https://github.com/obelisk-planner/obelisk-backend

An introduction to Obelisk in the format of a slideshow can be found at https://mega.nz/file/PYgj0IpY#nHBmW3s1jbZRuYtw3vI2kUUwY1Shf9lGcYfCXu3Y7h4

You'll need a Linux machine, NPM and PostgreSQL with an empty database set up, and the appropriate postgresql-server-dev installed.
Once that's done, run su install-depend.sh and (not su) setup.sh from a PostgreSQL superuser. Finally, to start serving, run obelisk.sh.
If it doesn't work, make sure PostgreSQL is accepting local IPv6 connections.

Thanks to the creators of PostgREST (https://github.com/PostgREST/postgrest/) and it's pgjwt extension, as well as
Vue.js and Vue Router (https://github.com/vuejs), which I've taken full advantage of.

This is my first project using these tools and I expect it will be janky.
