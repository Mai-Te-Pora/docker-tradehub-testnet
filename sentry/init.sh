#!/bin/bash

while getopts "w:" opt
do
   # shellcheck disable=SC2220
   case "$opt" in
      w ) wallet="$OPTARG" ;;
   esac
done

printf "$wallet\n$wallet\n$wallet\n" | switcheocli keys import --keyring-backend file val_key /root/.key/val_key

export DAEMON_NAME=switcheod
export DAEMON_HOME=${HOME}/.switcheod
export DAEMON_ALLOW_DOWNLOAD_BINARIES=true
export PATH=${HOME}/.switcheod/cosmovisor/current/bin:${HOME}/.switcheod/cosmovisor/genesis/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

# Start oracle
WALLET_PASSWORD=$wallet bash -c "exec -a oracle_process switcheod start --oracle --exclude=\"db,cosmos-rest\" --exclude-node &"
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start oracle_process: $status"
  exit $status
fi

# Start persistence
WALLET_PASSWORD=$wallet bash -c "exec -a persistence_process switcheod start --db --exclude-node &"
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start persistence_process: $status"
  exit $status
fi

# Start cosmovisor
WALLET_PASSWORD=$wallet bash -c "exec -a cosmovisor_process switcheod start -a --exclude=\"oracle,db\" &"
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start cosmovisor_process: $status"
  exit $status
fi

old_height=0
counter=0

while sleep 5; do

  echo "Checking processes..."
  ps aux |grep oracle_process |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep persistence_process |grep -q -v grep
  PROCESS_2_STATUS=$?
  ps aux |grep cosmovisor_process |grep -q -v grep
  PROCESS_3_STATUS=$?
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 -o $PROCESS_3_STATUS -ne 0 ]; then
    echo "One of the processes exited. Abort"
    exit 1
  fi

  echo "Checking stalling..."
  local_height=$(curl -s "http://localhost:26657/status" | jq -r '.result.sync_info.latest_block_height')
  if [ $local_height -ne $old_height ]; then
		echo "Blockheight increasing - OK: $(($local_height-$old_height)) Counter: $counter"
		counter=$((0))
		old_height=$((local_height))
	else
		counter=$((counter+1))
		echo "Blockheight stalled - BAD: $(($local_height-$old_height)) Counter: $counter"
	fi
	if [ $counter -gt 20 ]; then
	  echo "Node seems stalled. Abort"
		exit 1
	fi

done
