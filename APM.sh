main () {
	iter=1
	time=0
	ifstat -d 1
	# Headers for System level metrics csv file
	echo "Time,RX Data Rate, TX Data Rate, Disk Writes, Disk Capacity" >> system_metrics.csv
        # Headers for Process level metrics csv file
	echo "Time,APM 1 CPU,APM 1 Memory"  >> APM1_metrics.csv
	echo "Time,APM 2 CPU,APM 2 Memory" >> APM2_metrics.csv
	echo "Time,APM 3 CPU,APM 3 Memory" >> APM3_metrics.csv
	echo "Time,APM 4 CPU,APM 4 Memory" >> APM4_metrics.csv
	echo "Time,APM 5 CPU,APM 5 Memory" >> APM5_metrics.csv
	echo "Time,APM 6 CPU,APM 6 Memory" >> APM6_metrics.csv
	spawn
	echo "Spawned"
        # Run for 15 minutes
	while [ $time -lt 900 ]
		do
		# Get seconds of run time - Get data every 5 seconds
		time=$(( $iter * 5 ))
                # Increment iteration
		iter=$(( $iter + 1 ))
                # Run system level function to get data
		stats $time
                # Run process level function to get data
		ps_levels $time
		echo "Execution again"
		echo $iter
                # Sleep for 5 seconds
		sleep 5
		done
}

# Function to get process level data - CPU and Memory usage
ps_levels () {
        # Get APM1 cpu usage.
	cpu1=$(ps -aux | grep APM1 | head -n 1 | awk '{print $3}')
        # Get APM1 memory usage.
	mem1=$(ps -aux | grep APM1 | head -n 1 | awk '{print $4}')
	cpu2=$(ps -aux | grep APM2 | head -n 1 | awk '{print $3}')
	mem2=$(ps -aux | grep APM2 | head -n 1 | awk '{print $4}')
	cpu3=$(ps -aux | grep APM3 | head -n 1 | awk '{print $3}')
	mem3=$(ps -aux | grep APM3 | head -n 1 | awk '{print $4}')
	cpu4=$(ps -aux | grep APM4 | head -n 1 | awk '{print $3}')
	mem4=$(ps -aux | grep APM4 | head -n 1 | awk '{print $4}')
	cpu5=$(ps -aux | grep APM5 | head -n 1 | awk '{print $3}')
	mem5=$(ps -aux | grep APM5 | head -n 1 | awk '{print $4}')
	cpu6=$(ps -aux | grep APM6 | head -n 1 | awk '{print $3}')
	mem6=$(ps -aux | grep APM6 | head -n 1 | awk '{print $4}')

        # Write data to csv files
	echo $1,$cpu1,$mem1 >> APM1_metrics.csv
	echo $1,$cpu2,$mem2 >> APM2_metrics.csv
	echo $1,$cpu3,$mem3 >> APM3_metrics.csv
	echo $1,$cpu4,$mem4 >> APM4_metrics.csv
	echo $1,$cpu5,$mem5 >> APM5_metrics.csv
	echo $1,$cpu6,$mem6 >> APM6_metrics.csv
}

# Function for getting system level data
stats () {
        # Get txRate - transmit rate for network
	txrate=$(ifstat ens33 | awk '{print $9}' | tail -n 2 | head -n 1 | sed 's/[^0-9]*//g')
        # Get rxRate - Receive rate for network
	rxrate=$(ifstat ens33 | awk '{print $7}' | tail -n 2 | head -n 1 | sed 's/[^0-9]*//g')
        # Get Avaliable Hard disk access rates over time
	avail=$(df / -k --output=avail | tail -n1)
        # Get Hard disk utilization over time
	write=$(iostat sda | tail -n2 | head -n1 | awk '{print $4}')
        # Write data to csv file
	echo $1,$rxrate,$txrate,$write,$avail >> system_metrics.csv
}

# Run applications on IP address
spawn () {
   ./APM1 192.168.124.1 &
   ./APM2 192.168.124.1 &
   ./APM3 192.168.124.1 &
   ./APM4 192.168.124.1 &
   ./APM5 192.168.124.1 &
   ./APM6 192.168.124.1 &
}

# Kill all applications that are running
cleanup () {
	pkill -9 APM1
	pkill -9 APM2
	pkill -9 APM3
	pkill -9 APM4
	pkill -9 APM5
	pkill -9 APM6
	pkill -9 ifstat
}
main
cleanup

