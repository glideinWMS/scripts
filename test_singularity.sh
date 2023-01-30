#!/bin/bash

# SPDX-FileCopyrightText: 2023 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# GWMS-CS file:frontend,factory,standalone

# This function comes from singularity_lib.sh
singularity_check() {	
    # Check if it is invoked in Singularity and if Singularity is privileged mode ot not
    # Return true (0) if in Singularity false (1) otherwise
    # Echo to stdout a string with the status:
    # - EMPTY if not in singularity
    # - yes is SINGULARITY_CONTAINER or GWMS_SINGULARITY_REEXEC are defined
    # - likely if SINGULARITY_NAME is not defined but process 1 is shim-init or sinit
    # - appends _privileged to yes or likely if singularity is running in privileged mode
    # - appends _fakeroot  to yes or likely if singularity is running in unprivileged fake-root mode
    # - appends _nousernamespaces to yes or likely there is no user namespace info (singularity is running in privileged mode)
    # In Singularity SINGULARITY_NAME and SINGULARITY_CONTAINER are defined (in v=2.2.1 only SINGULARITY_CONTAINER)
    # In the default GWMS wrapper GWMS_SINGULARITY_REEXEC=1
    # The process 1 in singularity is called init-shim (v>=2.6), or sinit (v>=3.2), not init
    # If the parent is 1 and is not init could be also Docker or other containers, so the check was removed
    #   even if it could be also Singularity
    local in_singularity=
    [[ -n "$SINGULARITY_CONTAINER" ]] && in_singularity=yes
    [[ -z "$in_singularity" && -n "$GWMS_SINGULARITY_REEXEC" ]] && in_singularity=yes
    [[ -z "$in_singularity" && "$(ps -p1 -ocomm=)" = "shim-init" ]] && in_singularity=likely
    [[ -z "$in_singularity" && "$(ps -p1 -ocomm=)" = "sinit" ]] && in_singularity=likely
    # [[ "x$PPID" = x1 ]] && [[ "x`ps -p1 -ocomm=`" != "xinit" ]] && { true; return; }  This is true also in Docker
    [[ -z "$in_singularity" ]] && { false; return; }
    # It is in Singularity
    # Test for privileged singularity suggested by D.Dykstra
    # singularity exec -c -i -p ~/work/singularity/cvmfs-fuse3 cat /proc/self/uid_map 2>/dev/null|awk '{if ($2 == "0") print "privileged"; else print "unprivileged"; gotone=1;exit} END{if (gotone != 1) print "failed"}'
    if [[ -e /proc/self/uid_map ]]; then
        local check_privileged
        check_privileged="$(cat /proc/self/uid_map 2>/dev/null | head -n1 | tr -s '[:blank:]' ','),"
        if [[ "$check_privileged" = ,0,* ]]; then
            [[ "$check_privileged" = ,0,0,* ]] && in_singularity=${in_singularity}_privileged || in_singularity=${in_singularity}_fakeroot
        fi
    else
        in_singularity=${in_singularity}_nousernamespaces
    fi
    echo ${in_singularity}
    # echo will not fail, returning 0 (true)
}


# Assuming is invoked as custom script, working also if not
error_gen=
glidein_config="$1"
[[ -r "$glidein_config" ]] && error_gen=$(grep -m1 '^ERROR_GEN_PATH ' "$glidein_config" | cut -d ' ' -f 2-)

# Check and echo status
if ! res=$(singularity_check); then
    echo "Not running in Singularity/Apptainer"
    [[ -n "$error_gen" ]] && "$error_gen" -ok "test_singularity.sh" "in_singularity" "no" "mode" "NA" "fakeroot" "NA"
    exit 0
else
    echo -n "Running in Singularity/Apptainer "
    fakeroot=no
    mode=privileged
    if [[ "$res" = *_privileged ]]; then
	echo "(privileged mode)"
    elif [[ "$res" = *_fakeroot ]]; then
	echo "(unprivileged,fakeroot mode)"
	fakeroot=yes
        mode=unprivileged	
    elif [[ "$res" = *_nousernamespaces ]]; then
	echo "(no user namespaces assuming privileged mode)"
    else
	echo "(unprivileged mode)"
        mode=unprivileged	
    fi
    [[ -n "$error_gen" ]] && "$error_gen" -ok "test_singularity.sh" "in_singularity" "no" "mode" "$mode" "fakeroot" "$fakerrot"
    exit 0
fi

