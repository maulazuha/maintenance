#!/usr/bin/env bash
# copyright 2017-2020, all rights reserved by SDRausty; see LICENSE
# generate eight digit pseudo random numbers to create uniq strings
##############################################################################
set -eu
declare ONESA
declare STIME
_GENRAND_() {
	[[ -r proc/sys/kernel/random/uuid ]]&&_RANDUUID_||_RANDDATE_
	printf "\\e[1;7;38;5;0m%s\\e[0m" "$STIME"
	while true
	do
		"$0"
	done
}
_RANDDATE_() {
	STIME="$(rev<<<"$(date +%s)")"
 	STIME="${STIME::4}"
	ONESA="$(dae +%N 2>/dev/null)"||ONESA="${$: -4}"
 	ONESA="${ONESA: -4}"
	STIME="$ONESA$STIME"
}
_RANDUUID_() {
	STIME="$(cat /proc/sys/kernel/random/uuid)"
	STIME="${STIME//-}"
	STIME="${STIME//[[:alpha:]]}"
	STIME="${STIME::8}"
}
_GENRAND_
# randgen.bash EOF
