# Q4M - a Message Queue for MySQL

http://q4m.github.io/

Q4M is a message queue that works as a pluggable storage engine of MySQL
5.1 / 5.5 / 5.6 / 5.7.

## Usage

```bash
$ docker build . --build-arg MYSQL_VERSION=8.0.28 -t mysql80-q4m
$ docker run -p 127.0.0.1:3306:3306 mysql80-q4m
```

## MySQL 5.6 Compatibility

As of MySQL 5.6, it is no longer possible to call the `queue_wait()`
function within a `WHERE` clause, due to a change within the internals
of MySQL core.

In case it is necessary to use the feature, you should apply
`support-files/5.6-select-where-queue-wait.patch` to the MySQL source
code, disable the assertion code at the top of `queue_wait_init`
function in `src/ha_queue.cc`, and recompile both MySQL and Q4M.

The patch is not necessary if you are always calling the function in a
separate statement (e.g. `SELECT queue_wait()`).

## LICENSE and COPYRIGHT

* Copyright (c) 2009-2010 Cybozu Labs, Inc.
* Copyright (c) 2010-2014 DeNA Co., Ltd.

Please refer to each file.  The engine was built from the Skeleton engine
and the copyright of the build scripts mostly belong to their authors.

Copyright of the source code of the queue engine belongs to Cybozu Labs,
Inc., and is licensed under GPLv2.

Copyright of Boost C++ Library belongs to their authors and is licensed
under Boost Software License.

For more information see doc/index.html.
