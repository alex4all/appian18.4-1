#!/usr/bin/bash

TOPOL_PATH=$APPIAN_HOME/conf/appian-topology.xml
OPT_FUNC_PREFIX=opt-

LOCAL_READY_PORT="${READY_PORT:-9355}"
LOCAL_READY_TEXT="${READY_TEXT:-ready}"

check_hostname() {
  if [[ $SET_SM_PW == "true" ]]; then
    cont_hostname=$(grep "^" /etc/hostname | cut -d "." -f1)

    components=( server broker zookeeper )
    num_components=${#components[@]}
    shost=$(grep -Po '<server host="\K.*?(?=")' $TOPOL_PATH)
    bhost=$(grep -Po '<broker host="\K.*?(?=")' $TOPOL_PATH)
    zhost=$(grep -Po '<zookeeper host="\K.*?(?=")' $TOPOL_PATH)

    hosts=( $shost $bhost $sshost $zhost )
    match=true
    for i in $( seq 0 $(($num_components - 1)) ); do
      if [[ ! ${hosts[$i]} == $cont_hostname ]]; then
        echo ERROR: Container hostname \"$cont_hostname\" does not match ${components[$i]} host \"${hosts[$i]}\" in $TOPOL_PATH
        match=false
      fi
    done
    if [[ $match == false ]]; then
      exit 1
    fi
  fi
}

check_for_initial_data() {
  if [[ ! -f verify-data-was-initialized/successful.txt ]]; then
    echo "ERROR: Run the set-up-initial-data script appropriate for your host machine's OS"
    exit 1
  fi
}
setup_traps() {
  for sig in SIGUSR1 SIGTERM SIGINT; do
    trap "trap_signal $sig" $sig
  done
}

trap_signal() {
  echo "Signal caught: $@"
  if [[ $cmdpid ]] && kill -0 $cmdpid &> /dev/null; then
    echo "Killing command at pid: $cmdpid"
    kill $cmdpid
  fi

  stop_gracefully
}

stop_gracefully() {
  echo "Stop invoked"

  if [ -n "$readypid" ] ; then
    echo "Killing 'container ready' listener: $readypid"
    for (( tries = 0; tries < 10; tries++ )); do
      pkill -0 -P $readypid > /dev/null && break
    done

    pkill -P $readypid
  fi

  if [ -n "$stopcmd" ]; then
    echo "Executing stop command: $stopcmd"
    $stopcmd
  fi

  if [ -n "$tailpid" ]; then
    echo "Killing tail process: $tailpid"
    kill $tailpid
  fi

  echo "Stopped"
  exit 0
}

set_sm_password_if_applicable() {
  if [[ "$SET_SM_PW" == "true" ]]; then
    SM_PW=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
    $APPIAN_HOME/services/bin/password.sh -p $SM_PW
    ### Update password wrapper script
    sed -i "s/SM_PW=.*/SM_PW=$SM_PW/" $APPIAN_HOME/passwordWrapper.sh
 fi
}

parse_args() {
  local commandline="$@"

  allhosts=()

  while [[ $# > 0 ]] ; do
    arg="$1" && shift

    case "$arg" in
      --)
        cli="$@"
        break
        ;;

      --*)
        option="${arg%=*}"
        command="${option#--*}"

        case "$arg" in
          *=*)
            arg="${arg#*=}"
          ;;
          *)
            arg="$1" && shift
          ;;
        esac

        ${OPT_FUNC_PREFIX}${command} "$arg"
        ;;

      *)
        cli=("$arg" "$@")
        break
        ;;

    esac
  done

  if [[ -z "$cli" ]]; then
    echo "No command specified, exiting"
    exit 0
  fi
  cli="$(eval "cat <<EOF"$'\n'"${cli[@]}"$'\n'"EOF")"
}

opt-log() {
  logfile+=("$1")
}

opt-stop() {
  stopcmd="$(eval "cat <<EOF"$'\n'"$1"$'\n'"EOF")"
}

check_for_license(){
  if [[ "$CHECK_K4" == "true" && ! -s ${APPIAN_HOME}/data-server/engine/bin/q/l64/k4.lic ]] || \
    [[ "$CHECK_K3" == "true" && ! -s  ${APPIAN_HOME}/server/_bin/k/linux64/k3.lic ]]; then
    print_license_info_and_exit
  fi
}

print_license_info_and_exit() {
  for i in 1 2 3; do
    echo "-----------------------------------------------------"
    echo "*LICENSE NOT FOUND, PRINTING INFO TO REQUEST LICENSE*"
    echo "-----------------------------------------------------"
    faketty $APPIAN_HOME/data-server/engine/bin/q/l64/q | head -n 3
    sleep 5s
  done
  exit 1
}

faketty() {
  script -qfc "$(printf "%q " "$@" )" /dev/null
}

wait_for_containers() {
  if [ -z "$WAIT_CONTAINERS" ]; then
    echo "No containers to wait for, starting now"
    return 0
  fi
  waitcontainers=($WAIT_CONTAINERS)
  echo "Waiting for these containers to start: $WAIT_CONTAINERS"
  for container in ${waitcontainers[@]}; do
    echo "Currently waiting for $container"
    while ! ncat --recv-only $container $LOCAL_READY_PORT 2> /dev/null \
      | grep -q "${LOCAL_READY_TEXT}"; do
      sleep 1s
    done
    echo "$container is up!"
  done
}

perform_migration() {
  echo "run-migration.txt exists on service-manager, starting migration process"
  echo "Running resetAnalytics.sh"
  $APPIAN_HOME/passwordWrapper.sh resetAnalytics.sh
  echo "Starting all the engines"
  $APPIAN_HOME/passwordWrapper.sh start.sh -s all
  echo "Deleting run-migration.txt"
  rm check-migration/run-migration.txt
  echo "Finished migration process"
}


start_and_tail() {
  if [[ -f check-migration/run-migration.txt ]]; then
    perform_migration
  fi

  echo "Executing start command: ${cli}"

  eval "$cli &"; cmdpid="${!}"
  wait $cmdpid
  local status=$?

  if [[ $status == 1 ]]; then
    echo "Failed to start up, exiting"
    exit 1
  fi

  echo "Advertising as ready on $LOCAL_READY_PORT"
  ncat -lk -p ${LOCAL_READY_PORT} -c "echo ${LOCAL_READY_TEXT}" &
  readypid="${!}"

  if [ -n "$logfile" ]; then
    local logs=$(eval echo "${logfile[@]}")
    echo "Logfiles: $logs"

     while true; do
       tail -F $logs &
       tailpid="${!}"
       wait $tailpid
     done
  fi
}

check_hostname
setup_traps
set_sm_password_if_applicable
parse_args "$@"

check_for_license
wait_for_containers

start_and_tail
stop_gracefully
