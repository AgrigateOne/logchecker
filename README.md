# LogChecker

Import Postgresql csv log files and mine the data.

Get log files on server:
```
# Get a copy of postgres logfile(s):
sudo cp /var/lib/postgresql/9.5/main/pg_log/postgresql-2021-09-23_000000.csv .
# Change owner from root:
sudo chown unifrutti:unifrutti postgresql-2021-09-23_151041.csv postgresql-2021-09-23_000000.csv
# Zip the files:
zip pg_logs_2021_09.zip postgresql-2021-09-23_151041.csv postgresql-2021-09-23_000000.csv

# Grab a rails 1 logfile:
cp unifrutti_exporter/log/production.log.5.gz .
```

1. copy log files to logchecker/uploaded_logs
`scp production.log.5.gz nsld@192.168.50.27:logchecker/uploaded_logs`

2.zip up postgresql logs (they can get quite big)
`scp pg_logs_2021_09.zip  nsld@192.168.50.27:logchecker/uploaded_logs`

3. ssh in again & unzip the logs
`cd logchecker/uploaded_logs/`
`unzip pg_logs_2021_09.zip`

4. Import into the db....
```
cd logchecker/current
bin/console
LogcheckApp::ImportSqlLog.call(Date.today, ['/home/nsld/logchecker/uploaded_logs/postgresql-2019-07-19_000000.csv', '/home/nsld/logchecker/uploaded_logs/postgresql-2019-07-19_120825.csv']);
LogcheckApp::ImportRails123Log.call(Date.today, ['/home/nsld/logchecker/uploaded_logs/production.log.5']);
```

