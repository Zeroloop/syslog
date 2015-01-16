# Syslog client for Lasso 9

Supports RFC3164 and RFC5424.

## Example Usage

```lasso
	define syslog_offiste => syslog('syslog-server.com',22231)
	define syslog_onsite => syslog(
							 -host     = '10.0.0.1',
							 -port     = 415,
							 -machine  = 'web01',
							 -app      = 'MyApp',
							 -protocol = 'RFC5424' 
						   )

   	define syslog_local => syslog

	syslog_offiste->emergency('Can some one help this is a emergency')
	syslog_offiste->alert('Hey! look at this alert')
	syslog_offiste->critical('WTF this is critical')
	syslog_offiste->error('Oh shit this is a error')
	
	syslog_onsite->warning('Oh no this is a warning')
	syslog_onsite->notice('Hey this has happened')
	syslog_onsite->info('Just some info')

	syslog_local->debug('Just some debugging info')

```

## Facilities

- kernel
- user
- mail
- system
- security
- messages
- line
- network
- uucp
- clock
- security
- ftp
- ntp
- audit
- alert
- clock2
- local_user_0
- local_user_1
- local_user_2
- local_user_3
- local_user_4
- local_user_5
- local_user_6
- local_user_7

## Message types

- ->emergency
- ->alert
- ->critical
- ->error
- ->warning
- ->notice
- ->info
- ->debug

