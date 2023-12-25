sed -i 's/\./,/g' dat.csv && awk -F';' '{total[$6]+=$5} END {for (i in total) printf "%.3f;%s\n", total[i], i}' dat.csv | sort -t';' -k1nr | head -n 10
