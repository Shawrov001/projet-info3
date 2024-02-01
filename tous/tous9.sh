#!/bin/bash

# Vérification de l'argument pour s'assurer que data.csv est fourni en premier
if [ "$1" != "data/data.csv" ]; then
    echo "Erreur : Vous devez fournir 'data/data.csv' comme premier argument."
    echo "Utilisation: $0 data/data.csv [OPTIONS]"
    exit 1
fi

# Fonction pour créer un dossier s'il n'existe pas
creer_dossier() {
    local dossier=$1
    if [ ! -d "$dossier" ]; then
        mkdir -p "$dossier" && echo "Le dossier '$dossier' a été créé." || echo "Erreur lors de la création du dossier '$dossier'."
    fi
}

# Créer les dossiers nécessaires
creer_dossier "data"
creer_dossier "progc"
creer_dossier "images"
creer_dossier "temp"
creer_dossier "demo"
creer_dossier "res"

# Fonction pour déplacer les fichiers d'un dossier à un autre
deplacer_fichiers() {
    local dossier_source=$1
    local dossier_destination=$2
    # Reste de la fonction...
}

# Reste du script...

# Vérification de l'existence du fichier data.csv et déplacement si nécessaire
verifier_existence_data_csv() {
    
    if [ -f "$1" ]; then
        echo "Le fichier 'data.csv' a été spécifié."
    else
        echo "Erreur : Le fichier 'data.csv' est introuvable à l'emplacement spécifié."
        exit 1
    fi
}

# Appel de la fonction avec $1
verifier_existence_data_csv "$1"




# Fonction pour afficher l'aide
afficher_aide() {
    echo "Utilisation: ./tous9.sh [OPTIONS]"
    echo ""
    echo "Ce script permet de manipuler et d'analyser des données à partir d'un fichier CSV."
    echo ""
    echo "Options:"
    echo "  -D1    Effectue le traitement D1 : affiche les 10 conducteurs ayant effectué le plus de trajets."
    echo "         Les résultats sont triés par nombre de trajets et sauvegardés dans un fichier."
    echo "  -D2    Effectue le traitement D2 : liste les 10 conducteurs ayant parcouru la plus grande distance."
    echo "         Les résultats sont triés par distance et sauvegardés dans un fichier."
    echo "  -L     Effectue le traitement L : affiche les 10 trajets les plus longs."
    echo "         Les résultats sont triés par longueur de trajet et sauvegardés dans un fichier."
    echo "  -T     Effectue le traitement T : liste les 10 villes les plus traversées."
    echo "         Les résultats sont triés par nombre de traversées et sauvegardés dans un fichier."
    echo "  -S     Effectue le traitement S : fournit des statistiques sur les étapes des trajets."
    echo "         Les résultats incluent des mesures comme la distance minimale, maximale et moyenne."
    echo "  -h     Affiche ce message d'aide et quitte le script."
    echo ""
    echo "Exemples:"
    echo "  ./script.sh  data/data.csv -D1    # Exécute le traitement D1"
    echo "  ./script.sh  data/data.csv -D2    # Exécute le traitement D2"
    echo ""
    echo "Vous pouvez également combiner plusieurs options pour exécuter plusieurs traitements en une seule exécution du script."
    echo "Exemple : ./script.sh -D1 -D2 -L"
    exit 0
}

# Puis, vous pouvez appeler cette  :
case "$1" in
    -h)
        afficher_aide
        ;;
    
esac







# Vérifier le nombre d'arguments
if [ "$#" -lt 2 ]; then
    echo "Erreur: Vous devez fournir au moins deux arguments."
    echo "Exemple : ./tous9.sh data/data.csv -D1"
    exit 1
fi

fichier_de_travail="data/data.csv"

function traitementD1 {
    echo "Traitement D1 en cours.."
    start_time=$(date +%s.%N)
    
    # Exécution de la commande pour générer les données et trier par nombre de trajets
    LC_NUMERIC=C awk -F';' '{ conducteurs[$1]++; if (!distance[$1]) { count[$6]++; distance[$1]=1 }} END {for (i in count) print count[i]";"i}' "$fichier_de_travail" | sort -k1,1nr | head -n 10 | awk -F';' '{temp=$1; $1=$2; $2=temp} 1' OFS=';' > resD1.txt
          
          gnuplot <<EOF
    # Paramètres du graphique
    set terminal pngcairo enhanced size 800,600
    set output 'images/graphD1.png'
    set encoding utf8

    # Marges et plage de l'axe Y
    set margins 10, 10, 5, 5
    set yrange [0:*]

    # Style du graphique en histogramme
    set style data histogram
    set style histogram cluster gap 1
    set style fill transparent solid 0.5
    set boxwidth 0.8

    # Formatage des étiquettes sur l'axe X
    set xtics format ""
    set grid ytics

    # Titre non affiché
    unset title

    # Étiquette personnalisée
    set label "Option -d1 : Nb routes = f(Driver)" at screen 0.05,0.5 center rotate by 90 font ",20" 

    # Étiquettes et style pour l'axe X
    set xlabel "DRIVER NAMES" font ",18" rotate by -180 center offset 0,1
    set xtics rotate by 90 offset 0,1.5 font ",15"

    # Style et étiquettes pour l'axe Y à droite
    set y2tics mirror
    set ytics mirror rotate by 90 offset 75,0 font ",15" center
    set ylabel "NB ROUTES" font ",18" rotate by 90 center offset 85,0

    # Séparateur de données et tracé du graphique
    set datafile separator ";"
    plot 'resD1.txt' using 2:xtic(1):xticlabels(1) lc "#00ffff" notitle with boxes
EOF
#mogrify -rotate 90 'graphD1.png'

          
          
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    echo "Graphique est généré "
    echo "Durée du traitement D1: $duration secondes"
    if [ -e resD1.txt ]; then
        mv resD1.txt res/
        echo "Le resD1.txt a été déplacé dans le res."
    else
        echo "Le resD1.txt n'existe pas."
    fi
}

function traitementD2 {
    echo "Traitement D2 en cours.."
    start_time=$(date +%s.%N)
    LC_NUMERIC=C  awk -F';' '{total[$6]+=$5} END {for (i in total) printf "%.3f;%s\n", total[i], i}' "$fichier_de_travail" | sort -t';' -k1nr | head -n 10 | awk -F';' '{temp=$1; $1=$2; $2=temp} 1' OFS=';' > resD2.txt
	 gnuplot <<EOF
             gnuplot <<EOF
    # Paramètres du graphique
    set terminal pngcairo enhanced size 800,600
    set output 'images/graphD2.png'
    set encoding utf8

    # Marges et plage de l'axe Y
    set margins 10, 10, 5, 5
    set yrange [0:*]

    # Style du graphique en histogramme
    set style data histogram
    set style histogram cluster gap 1
    set style fill transparent solid 0.5
    set boxwidth 0.8

    # Formatage des étiquettes sur l'axe X
    set xtics format ""
    set grid ytics

    # Titre non affiché
    unset title

    # Étiquette personnalisée
    set label "Option -d2 : Nb routes = f(Driver)" at screen 0.05,0.5 center rotate by 90 font ",20" 

    # Étiquettes et style pour l'axe X
    set xlabel "DRIVER NAMES" font ",18" rotate by -180 center offset 0,1
    set xtics rotate by 90 offset 0,1.5 font ",15"

    # Style et étiquettes pour l'axe Y à droite
    set y2tics mirror
    set ytics mirror rotate by 90 offset 75,0 font ",15" center
    set ylabel "NB ROUTES" font ",18" rotate by 90 center offset 85,0

    # Séparateur de données et tracé du graphique
    set datafile separator ";"
    plot 'resD2.txt' using 2:xtic(1):xticlabels(1) lc "#00ffff" notitle with boxes
EOF
	
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    echo "Durée du traitement D2: $duration secondes"
    if [ -e resD2.txt ]; then
        mv resD2.txt res/
        echo "Le resD2.txt a été déplacé dans res."
    else
        echo "Le resD2.txt n'existe pas."
    fi
}

function traitementL {
    echo "Traitement L en cours.."
    start_time=$(date +%s.%N)

    LC_NUMERIC=C awk -F';' '{total[$1]+=$5; count[$1]++} END {for (i in total) printf "%3f;%s\n", total[i], i}' "$fichier_de_travail" | sort -t';' -k1nr | head -n 10 | sort -t ';' -k2n | awk -F';' '{temp=$1; $1=$2; $2=temp} 1' OFS=';' > resL.txt

    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    
    # GNUplot commands
    gnuplot <<EOF
    set term png enhanced size 1200,1000
    set output "images/outputL.png"
    set encoding utf8
    set margins 12, 12, 5, 5
    set yrange [0:3000]
    set ytics 500
    set style fill solid
    set boxwidth 0.5 relative
    set xlabel "Route ID"
    set ylabel "Distance (Km)"
    set title "Top 10 Trajets les Plus Longs"
    set datafile separator ";"
    set style line 1 lc rgb "#0045FF" lt 1 lw 2
    set grid ytics linestyle 1
    set key outside below

    # Augmenter l'espace entre les chiffres en abscisse
    set xtics 1.5

    plot 'resL.txt' using 2:xtic(1) with boxes lc rgb "#0045FF" title 'Distance (Km)'
EOF

    echo "Durée du traitement L: $duration secondes"
    if [ -e resL.txt ]; then
        mv resL.txt res/
        echo "Le resL.txt a été déplacé dans le res."
    else
        echo "Le resL.txt n'existe pas."
    fi
}

function traitementT {
    echo "Traitement T en cours.."
    echo ""
    # Enregistrer le temps de début
    start_time=$(date +%s.%N)

    # Exécute le script AWK
    awk -F';' '{
        total4[$4]++;
        if ($2 == 1) {
            total3[$3]++;
            townAStep1[$3]++;
        }
    }
    END {
        for (i in total3) {
            printf "%s;%d;%d\n", i, (i in townAStep1) ? townAStep1[i] : 0, total3[i] + total4[i];
        }
    }' "$fichier_de_travail" > resT.txt

    # Compile le programme C
    make -C progc/T run

    # Ajoutez ici la compilation du programme C si nécessaire

    # Génération du graphique avec gnuplot
    
gnuplot <<EOF
set term png enhanced size 1200,800
set output "images/graphT.png"
set encoding utf8
set margins 10, 10, 7, 5
set yrange [0:4000]  # Utilisation de yrange pour définir la plage de l'axe y
set ytics 500
set style data histograms
set style fill solid
set boxwidth 0.4 absolute
set offset 0.5, 0.5, 0, 0
set xtic rotate by -45
set datafile separator ";"
plot 'res/resT.txt' using 2:xtic(1) title 'Nombre de trajets' lc rgb "blue", '' using 3:xtic(1) title 'Nombre de conducteurs' lc rgb "orange"

EOF

    end_time=$(date +%s.%N)
    duration=$(awk "BEGIN {print $end_time - $start_time}")

    # Afficher la durée du traitement
    echo ""
    echo "Durée du traitement: ${duration} secondes"

    echo "Graphique généré et enregistré sous : $output_fileT"
    echo "Durée du traitement T: $duration secondes"

    if [ -e resT.txt ]; then
        mv resT.txt res/
        echo "Le resT.txt a été déplacé dans le dossier res."
    else
        echo "Le resT.txt n'existe pas."
    fi
}

function traitementS {
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
    }' "$fichier_de_travail" | awk '{gsub(/,/, "."); print}' > tempS.txt

    # Compile le programme C
    make -C progc/S run

    # Enregistrer le temps de fin
    end_time=$(date +%s.%N)
    duration=$(awk "BEGIN {print $end_time - $start_time}")

    # Afficher la durée du traitement
    echo ""
    echo "Durée du traitement: ${duration} secondes"
 if [ -e tempS.txt ]; then
        mv tempS.txt temp/
        echo "Le tempS.txt a été déplacé dans le dossier temp."
    else
        echo "Le tempS.txt n'existe pas."
    fi
   
}




# Ignorer le premier argument qui est le chemin du fichier
shift

# Parcourir les arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h)
            afficher_aide
            exit 0
            ;;
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
        *)
            echo "Traitement inconnu: $1"
            afficher_aide
            exit 1
            ;;
    esac
    shift
done

