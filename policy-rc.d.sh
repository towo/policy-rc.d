#!/bin/sh

output() {
	if [ "${verbose}" == '1' ]; then
		echo $@
	fi
}

if ! [ -x '/usr/bin/getopt' ]; then
	echo '/usr/bin/getopt cannot be found. Install the `util-linux` package.'
	exit 102
fi

OPTS=$(/usr/bin/getopt -o + --long list,help,quiet -n 'policy-rc.d' -- "${@}")

if [ $? -ne 0 ]; then
	echo 'Parsing options failed.'
	exit 102
fi

eval set -- "${OPTS}"
unset OPTS

mode='query'
verbose=1

while true; do
	case "$1" in
		'--list')
			mode='list'
			shift
			continue
		;;
		'--quiet')
			verbose=0
			shift
			continue
		;;
		'--help')
			echo 'We should probably output something here.'
			exit 0
		;;
		'--')
			shift
			break
		;;
		*)
			output 'Option parsing failed spectacularly.';
			exit 102
		;;
	esac
done

initscript=$1
if [ -z "${initscript}" ]; then
	output 'Missing initscript parameter.'
	exit 103
fi
shift

action=$1
if [ -z "${action}" ] && [ "${mode}" != 'list' ]; then
	output 'Missing action parameter.'
	exit 103
fi
shift

runlevel=$@

case $mode in
	query)
		case $action in
			start,'(start)',restart,force-restart)
				output "Starting is denied for package installation and similar."
				exit 101
				;;
			*)
				output "Action is allowed."
				exit 0
				;;
		esac
		;;
	list)
		echo "Allowed actions for ${initscript}: stop, reload, force-reload, status."
		echo "Forbidden actions for ${initscript}: start, restart, force-restart."
		;;
esac
