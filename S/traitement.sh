#!/bin/bash
echo "Traitement en cours.."
echo ""
# Enregistrer le temps de début
start_time=$(date +%s.%N)

# Exécute le script AWK
awk -F';' 'NR>1{
    count[$1]++;
    sum[$1]+=$5;
    if (route[$1]=="") {
        route[$1]=$5;
        smallest[$1]=$5;
        largest[$1]=$5;
    } else {
        if ($5 < smallest[$1]) {
            smallest[$1]=$5;
        }
        if ($5 > largest[$1]) {
            largest[$1]=$5;
        }
    }
}
END{
    for (r in count) {
        print r ";" smallest[r] ";" (sum[r]/count[r]) ";" largest[r] ";" (largest[r] - smallest[r]);
    }
}' data.csv | awk '{gsub(/,/, "."); print}' > temp.txt

# Compile le programme C
gcc -o exe traitementS.c

# Vérifie si la compilation a réussi
if [ $? -eq 0 ]; then
    # Lance le programme C
    ./exe
else
    echo "Erreur de compilation du programme C."
fi

# Enregistrer le temps de fin
end_time=$(date +%s.%N)
duration=$(awk "BEGIN {print $end_time - $start_time}")

# Afficher la durée du traitement
echo ""
echo "Durée du traitement: ${duration} secondes"