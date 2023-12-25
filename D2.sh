awk -F';' '{total[$6]+=$5} END {for (i in total) printf "%.3f %s\n", total[i], i}' data.csv | sort -k1nr | head -n 10
