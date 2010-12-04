The ActiveRecord adapter unit tests require that you connect to actual
databases. In order for these tests to run, you must therefore provide
the database connection parameters, in the form of a "database.yml" file
located in this directory. If this file is not present, the ActiveRecord
adapter tests will be skipped.

The format of this file is the same as the Rails "config/database.yml"
file, except that the main keys, instead of environment names, should be
adapter names.

For example:

####
mysqlspatial:
  adapter: mysqlspatial
  encoding: utf8
  reconnect: false
  database: <mysql_test_database>
  username: <mysql_user>
  password: <mysql_password>
  host: localhost
mysql2spatial:
  adapter: mysql2spatial
  encoding: utf8
  reconnect: false
  database: <mysql_test_database>
  username: <mysql_user>
  password: <mysql_password>
  host: localhost
spatialite:
  adapter: spatialite
  database: /path/to/sqlite3_test_database.db
  libspatialite: /path/to/libspatialite.so
postgis:
  adapter: postgis
  database: <postgres_test_database>
  username: <postgres_user>
  password: <postgres_password>
  host: localhost
####

Note that the tests assume they "own" these databases, and they may
modify and/or delete any and all tables at any time.
