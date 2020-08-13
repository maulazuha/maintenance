#!/usr/bin/env bash
# Copyright 2019-2020 (c) all rights reserved by S D Rausty; see LICENSE
# https://sdrausty.github.io hosted courtesy https://pages.github.com
# To create checksum files and commit use; ./do.sums.bash
# To see file tree use; awk '{print $2}' sha512.sum
# To check the files use; sha512sum -c sha512.sum
#####################################################################
set -euo pipefail
printf "%s\\n" "Creating checksum file and pushing commit : "
MTIME="$(ls -l --time-style=+"%s" .git/ORIG_HEAD 2>/dev/null | awk '{print $6}')" || MTIME=""
TIME="$(date +%s)"
([[ ! -z "${MTIME##*[!0-9]*}" ]] && (if [[ $(($TIME - $MTIME)) -gt 43200 ]] ; then git pull ; fi) || git pull) || (printf "%s\\n" "Signal generated at [ ! -z \${num##*[!0-9]*} ]" && git pull)
rm -f *.sum
# query .gitmodules file and find paths to submodules
[[ -f .gitmodules ]] && GMODSLST="$(grep path .gitmodules | sed 's/path = //g')" || GMODSLST=""
GIMODS=""
SMDRE=""
# build directory exclusion string
for SMDRE in $GMODSLST
do
    	SMDRE="$(grep -v ".scripts" <<< $SMDRE)" ||:
    	[[ ! -z ${SMDRE:-} ]] && GIMODS+="-or -name $SMDRE "
done
# checksums will be created for these files
FINDLST="$(find . \( -type d \( -name .git -or -name .scripts $GIMODS \) -prune \) -or \( -type f -print \))"
# checksum file types to be created
CHECKLIST=(sha512sum) # md5sum sha1sum sha224sum sha256sum sha384sum
for SCHECK in "${CHECKLIST[@]}"
do
	printf "%s\\n" "Creating $SCHECK file..."
	for FILE in $FINDLST
	do
		$SCHECK "$FILE" >> ${SCHECK::-3}.sum
	done
done
chmod 400 ${SCHECK::-3}.sum
for SCHECK in  ${CHECKLIST[@]}
do
	printf "%s\\n" "Checking $SCHECK..."
	$SCHECK -c ${SCHECK::-3}.sum
done
git add .
SN="$(sn.sh)" # sn.sh is found in https://github.com/BuildAPKs/maintenance.BuildAPKs/blob/master/sn.sh
( [[ -z "${1:-}" ]] && git commit -m "$SN" ) || ( [[ "${1//-}" == [Ss]* ]] && git commit -a -S -m "$SN" && pkill gpg-agent ) || git commit -m "$SN"
git push || git push --set-upstream origin master
ls
printf "%s\\n" "$PWD"
git show
printf "%s\\n" "Creating checksum file and pushing commit : DONE"
# do.sums.bash EOF
