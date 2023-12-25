#!/bin/bash
echo "Traitement en cours.."
echo ""
# Enregistrer le temps de début
start_time=$(date +%s.%N)

# Exécute le script AWK
awk -F';' '{
    totaal[$4]++;
    if ($2 == 1) {
        total[$3]++;
        townAStep1[$3]++;
    }
}
END {
    for (i in total) {
        printf "%s;%d;%d\n", i, (i in townAStep1) ? townAStep1[i] : 0, total[i] + totaal[i];
    }
}' data.csv > temp.txt

# Compile le programme C
gcc -o exe traitementT.c

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