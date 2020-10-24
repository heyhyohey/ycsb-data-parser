#!/bin/zsh

if [[ $# -ne 3 ]]; then
	echo "Usage: $0 [db] [bind_option] [bound]"
	exit 1
fi

GRAPH_HOME="/home/yun/Graph"
YCSB_HOME="/home/yun/YCSB"
BIND_RESULT_HOME="$YCSB_HOME/exp/bind"
NOBIND_RESULT_HOME="$YCSB_HOME/exp/nobind"
RESULT_FILE_PATH="$GRAPH_HOME/result/$1-$2-$3.csv"


# Make result file
if [ -f $RESULT_FILE_PATH ]; then
	print -n "" > $RESULT_FILE_PATH
fi

# Determine a working directory
if [ "$2" = "bind" ]; then
	WORKING_HOME=$BIND_RESULT_HOME
else
	WORKING_HOME=$NOBIND_RESULT_HOME
fi

# Determine what data will be parsed
if [ "$3" = "ae" ]; then
	WORKLOADS=("load-workload-a" "run-workload-a" "run-workload-b" "run-workload-c" \
			"run-workload-f" "run-workload-d" "load-workload-e")
else
	WORKLOADS=("run-workload-e")
fi

# Determine modes
if [ "$1" = "redis" ] || [ "$1" = "mongodb" ]; then
	MODES=("bb" "swap" "devdax" "pmm")
elif [ "$1" = "rocksdb" ]; then
	MODES=("bb" "swap" "devdax" "pmm" "bbr")
fi

# echo $YCSB_HOME $BIND_RESULT_HOME $NOBIND_RESULT_HOME

for SIZE in "16g" "48g" "96g"; do
	for MODE in $MODES; do
		for WORKLOAD in $WORKLOADS; do
			echo $MODE $SIZE $WORKLOAD
			FILE_PATH="$WORKING_HOME/$1/result_$SIZE/$1-${MODE}-$WORKLOAD.txt"
			if [ -f $FILE_PATH ]; then
				COMMEND="cat $FILE_PATH | grep Throughput | awk '{ print \$3 }'"
				RESULT=$(eval $COMMEND)
				if [ -z "$RESULT" ]; then
					print -n "0.0" >> $RESULT_FILE_PATH
				else
					print -n "$RESULT" >> $RESULT_FILE_PATH
				fi
			else
				print -n "0.0" >> $RESULT_FILE_PATH
			fi
			if [ "$WORKLOAD" = "run-workload-e" ] || [ "$WORKLOAD" = "load-workload-e" ]; then 
				print "" >> $RESULT_FILE_PATH
			else
				print -n "," >> $RESULT_FILE_PATH
			fi
		done
	done
done
