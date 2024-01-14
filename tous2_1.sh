#!/bin/bash

# Fonction d'affichage de l'aide
function afficher_aide {
    echo "Usage: $0 [-h] chemin_du_fichier [traitement1 traitement2 traitement3 ...]"
    echo "Options:"
    echo "  -h          Affiche ce message d'aide"
    echo "Traitements disponibles:"
    echo "  traitementD1   Description du traitement 1"
    echo "  traitementD2   Description du traitement 2"
    echo "  traitementL    Description du traitement 3"
    echo "  traitementT    Description du traitement T"
    echo "  traitementS    Description du traitement S"
    exit 1
}





# Fonction pour gérer l'option -h
function gestion_option_h {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h)
                afficher_aide
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
}


gestion_option_h "$@"





# Vérifier le nombre d'arguments
if [ "$#" -lt 2 ]; then
    echo "Erreur: Vous devez fournir au moins deux arguments."
    afficher_aide
fi


# Vérifier si l'option d'aide est spécifiée
if [ "$1" == "-h" ]; then
    echo " comment puis je vous aider ?"
    echo " revenir au menue "
    echo " detaille des description D1 :  "
    echo " detaille des description D2 : "
    echo " detaille des description L  : "
    echo " detaille des description T  : "
    echo " detaille des description S  :  "
fi

# Chemin du fichier de données
chemin_du_fichier="$1"

# Vérifier si le fichier de données existe
if [ ! -f "$chemin_du_fichier" ]; then
    echo "Erreur: Le fichier $chemin_du_fichier n'existe pas."
    exit 1
fi

# Définir les fonctions de traitement
function traitementD1 {
 echo "Traitement D1 en cours.."
    start_time=$(date +%s.%N)
    awk -F';' '{conducteurs[$1]++; if (!distance[$1]) { count[$6]++; distance[$1]=1 }} END {for (i in count) print count[i]";"i}' "$chemin_du_fichier" | sort -k1nr | head -n 10 > temp1.txt
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)

    echo "Durée du traitement D1: $duration secondes"

}

function traitementD2 {
 echo "Traitement D2 en cours.."
    start_time=$(date +%s.%N)
    awk -F';' '{total[$6]+=$5} END {for (i in total) printf "%.3f;%s\n", total[i], i}' "$chemin_du_fichier" | sort -t';' -k1nr | head -n 10 > temp2.txt
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)

    echo "Durée du traitement D2: $duration secondes"
}

function traitementL {
    echo "Traitement L en cours.."
    start_time=$(date +%s.%N)

    awk -F';' '{total[$1]+=$5} END {for (i in total) printf "%.3f %s\n", total[i], i}' "$chemin_du_fichier" | sort -t';' -k1nr -k2n | head -n 10 > temp.txt

    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)

    echo "Durée du traitement L: $duration secondes"
}


 




function traitementT {
    echo "Traitement T en cours.."
    start_time=$(date +%s.%N)
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
    }' "$chemin_du_fichier" > temp.txt
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    echo "Durée du traitement T: $duration secondes"
}

function traitementS {
    echo "Traitement S en cours.."
    start_time=$(date +%s.%N)
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
    }' "$chemin_du_fichier" | awk '{gsub(/,/, "."); print}' > temp.txt
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    echo "Durée du traitement S: $duration secondes"
}

# Appel des traitements en fonction des arguments passés
shift  # Pour ignorer le premier argument qui est le chemin du fichier
while [ "$#" -gt 0 ]; do
    case "$1" in
        -D1)
            traitementD1
            ;;
        -D2)
            traitementD2
            ;;
        -L)
            traitementL
            ;;
        -T)
            traitementT
            ;;
        -S)
            traitementS
            ;;
        *) echo "Traitement inconnu: $1" ; afficher_aide;;
    esac
    shift
done
