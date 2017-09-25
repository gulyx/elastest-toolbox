#!/bin/sh

stop() {
  if [ -z "$RUN_PID" ]; then
    echo 'Not stopped'
    exit 1
  else
     pkill -TERM -P $RUN_PID # Kill run.py process and childs
     echo ''
     echo '*************************'
     echo '*  Stopping components  *'
     echo '*************************'
     echo ''
     if [ -z "$PARAMETERS" ]; then
       python run.py 'stop'
     else
       python run.py 'stop' $PARAMETERS
     fi
     exit 0
  fi
}

# Start
if [ "$1" = 'start' ]; then
	# Trap SIGTERM/SIGINT to stop execution
	trap stop TERM
	trap stop INT

	# Run run.py script to start components
	export EXPRESION="$*"
	shift
	export PARAMETERS="$*"

	python run.py $EXPRESION & export RUN_PID=$!

	echo ''
	echo '*****************************************************************************************'
	echo '*  To stop open new terminal and type:                                                  *'
	echo '*  docker run -v /var/run/docker.sock:/var/run/docker.sock --rm elastest/platform stop  *'
	echo '*****************************************************************************************'
	echo ''

	# Wait for stop signal
	while true; do
	  sleep 20 &
	  wait $!
	done

# Stop (when platform container is in BG or stopped)
elif [ "$1" = 'stop' ]; then
	echo 'Sending stop signal...'
	echo ''
	nproc=$(echo $(docker ps | grep elastest/platform | wc -l))
	sh -c 'docker ps -q --filter ancestor="elastest/platform" | xargs -r docker kill --signal=SIGTERM'

	# If container is stopped, run stop just in case there are running containers
	if [ $? -gt 0 ] || [ $nproc -lt 2 ]; then # 2 containers: started container and this container (stop)
		echo ''
		echo 'trying again...'
		echo ''
	       python run.py 'stop'
	fi
# HELP
elif [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
	       python run.py '-h'
fi
