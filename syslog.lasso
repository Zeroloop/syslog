<?lasso

///////////////////////////////////////////////////////
//
//	Single UDP network object
//
///////////////////////////////////////////////////////

define syslog_udp => {
	var(__syslog_udp) ? return $__syslog_udp
	web_request ? define_atend({syslog_udp->close})
	return $__syslog_udp:= net_udp 
}

///////////////////////////////////////////////////////
//
//	Facilites
//
///////////////////////////////////////////////////////

define syslog_facility_kernel       => 0
define syslog_facility_user         => 1
define syslog_facility_mail         => 2
define syslog_facility_system       => 3
define syslog_facility_security     => 4
define syslog_facility_messages     => 5
define syslog_facility_printer      => 6
define syslog_facility_network      => 7
define syslog_facility_uucp         => 8
define syslog_facility_clock        => 9
define syslog_facility_security     => 10
define syslog_facility_ftp          => 11
define syslog_facility_ntp          => 12
define syslog_facility_audit        => 13
define syslog_facility_alert        => 14
define syslog_facility_clock2       => 15
define syslog_facility_local_user_0 => 16
define syslog_facility_local_user_1 => 17
define syslog_facility_local_user_2 => 18
define syslog_facility_local_user_3 => 19
define syslog_facility_local_user_4 => 20
define syslog_facility_local_user_5 => 21
define syslog_facility_local_user_6 => 22
define syslog_facility_local_user_7 => 23

///////////////////////////////////////////////////////
//
//	Severities
//
///////////////////////////////////////////////////////

define syslog_severity_emergency     => 0
define syslog_severity_alert         => 1
define syslog_severity_critical      => 2
define syslog_severity_error         => 3
define syslog_severity_warning       => 4
define syslog_severity_notice        => 5
define syslog_severity_informational => 6
define syslog_severity_debug         => 7

///////////////////////////////////////////////////////
//
//	Main syslog type
//
///////////////////////////////////////////////////////

define syslog => type {

	data
		public host     = '127.0.0.1',
		public port     = 514,
		public machine  = '',
		public app      = '',
		public facility = syslog_facility_system,
		public severity = syslog_severity_warning,
		public protocol = 'RFC3164'

	public oncreate(
		host::string,
		port::integer = .port
	) => .oncreate(
		-host = #host,
		-port = #port
	)

	public oncreate(
		-host::string     = .host,
		-port::integer    = .port,
		-machine::string  = .machine,
		-app::string      = .app,
		-protocol::string = .protocol,
		-facility         = .facility
	) => {
		.host     = #host
		.port     = #port
		.machine  = #machine
		.app      = #app
		.protocol = #protocol
		.facility = #facility
	}

	public machine => .'machine' || (web_request ? server_name) || (web_request ? server_ip) || ''

	private priority(severity::integer = .severity) => (.facility * 8) + #severity 

///////////////////////////////////////////////////////
//
//	Facility Setter
//
///////////////////////////////////////////////////////

	public facility=(p::integer) => {.'facility' = #p}

	public facility=(p::string) => {
		match(#p) => {
		case('kernel')      .'facility' = syslog_facility_kernel
		case('user')        .'facility' = syslog_facility_user
		case('mail')        .'facility' = syslog_facility_mail
		case('system')      .'facility' = syslog_facility_system
		case('security')    .'facility' = syslog_facility_security
		case('messages')    .'facility' = syslog_facility_messages
		case('line')        .'facility' = syslog_facility_printer
		case('network')     .'facility' = syslog_facility_network
		case('uucp')        .'facility' = syslog_facility_uucp
		case('clock')       .'facility' = syslog_facility_clock
		case('security')    .'facility' = syslog_facility_security
		case('ftp')         .'facility' = syslog_facility_ftp
		case('ntp')         .'facility' = syslog_facility_ntp
		case('audit')       .'facility' = syslog_facility_audit
		case('alert')       .'facility' = syslog_facility_alert
		case('clock2')      .'facility' = syslog_facility_clock2
		case('local_use_0') .'facility' = syslog_facility_local_use_0
		case('local_use_1') .'facility' = syslog_facility_local_use_1
		case('local_use_2') .'facility' = syslog_facility_local_use_2
		case('local_use_3') .'facility' = syslog_facility_local_use_3
		case('local_use_4') .'facility' = syslog_facility_local_use_4
		case('local_use_5') .'facility' = syslog_facility_local_use_5
		case('local_use_6') .'facility' = syslog_facility_local_use_6
		case('local_use_7') .'facility' = syslog_facility_local_use_7	
		}
	}

///////////////////////////////////////////////////////
//
//	Send msg calls
//
///////////////////////////////////////////////////////

	public emergency(msg::string)     => .write(#msg,.priority(syslog_severity_emergency))     
	public alert(msg::string)         => .write(#msg,.priority(syslog_severity_alert))         
	public critical(msg::string)      => .write(#msg,.priority(syslog_severity_critical))      
	public error(msg::string)         => .write(#msg,.priority(syslog_severity_error))         
	public warning(msg::string)       => .write(#msg,.priority(syslog_severity_warning))       
	public notice(msg::string)        => .write(#msg,.priority(syslog_severity_notice))        
	public informational(msg::string) => .write(#msg,.priority(syslog_severity_informational)) 
	public debug(msg::string)         => .write(#msg,.priority(syslog_severity_debug))         

///////////////////////////////////////////////////////
//
//	Write msg
//
///////////////////////////////////////////////////////

	public write(msg::string,priority::integer = .priority) => {
		local(message) = array

		match(.protocol) => {
			case('RFC5424')
				#message = (:
					'<'+#priority +'>1',
					date->format('YYYY-MM-dd HH:mm:ss.SSXXX')->replace(' ','T')&  ,
					.machine,
					.app,
					'-',
					'ID47',
					'-',
					bom_utf8 + #msg
				)->join(' ')

			case('RFC3164')
				#message = (:
					'<' + #priority + '>' + date->format('MMM dd HH:mm:ss'),
					.machine,
					.app+':',
					 #msg
				)->join(' ')

		}

		syslog_udp->writeBytes(#message->asbytes,.host,.port)
	}

}
?>