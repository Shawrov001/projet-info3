#!/bin/bash

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

# Fonction pour créer un dossier s'il n'existe pas
creer_dossier() {
    local dossier=$1
    if [ ! -d "$dossier" ]; then
        mkdir -p "$dossier" && echo "Le dossier '$dossier' a été créé." || echo "Erreur lors de la création du dossier '$dossier'."
    fi
}

if [ "$1" == "-h" ];then
	afficher_aide
	exit 0
fi

if [ "$1" == "clean" ];then
	echo "effacement de tous les documents en cours..."
	rm -rf temp res images demo
	make -C progc/T clean
	make -C progc/S clean
	exit 0
fi

# Vérification de l'argument pour s'assurer que data.csv est fourni en premier
if [ $# -eq 0 ]; then
    echo "Erreur : Aucun argument fourni."
    if [  -f "data.csv" ];then
	echo "mais vous avez fourni un data.csv"
	echo "on va donc le déplacer de sorte à ce qu'il puisse être utilisable"
	echo ""
	creer_dossier "data"
	mv data.csv data/data.csv
	afficher_aide
    fi		
    afficher_aide
    exit 1

elif [ "$1" != "data/data.csv" ]; then
	
    echo "Erreur : Vous devez fournir 'data/data.csv' comme premier argument."
    echo "Utilisation: $0 data/data.csv [OPTIONS]"
    echo ""
    exit 1
fi



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

    if [ -n "$(ls -A $dossier_source)" ]; then
        echo "Des fichiers sont présents dans le dossier '$dossier_source'. Déplacement en cours..."
        mv "$dossier_source"/* "$dossier_destination"/
        echo "Les fichiers ont été déplacés dans le dossier '$dossier_destination'."
    else
        echo "Le dossier '$dossier_source' est vide. Aucune action nécessaire."
    fi
}

# Déplacer les fichiers qui sont dans 'images' vers le dossier 'demo'
deplacer_fichiers "images" "demo"


# Fonction pour vérifier l'existence du fichier data.csv et le déplacer si nécessaire
verifier_existence_data_csv() {
    if [ -f "data/data.csv" ]; then
        echo "Le fichier 'data.csv' existe déjà dans le dossier 'data'."
    elif [ -f "data.csv" ]; then
        echo "Le fichier 'data.csv' trouvé. Déplacement en cours..."
        mv "data.csv" "data/" && echo "Le fichier 'data.csv' a été déplacé dans le dossier 'data'." || echo "Erreur lors du déplacement du fichier 'data.csv'."
    else
        echo "Erreur : Le fichier 'data.csv' est introuvable."
        exit 1
    fi
}







# Appel de la fonction avec $1
verifier_existence_data_csv "$1"






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
        set term png enhanced size 1200,1000
        set output "images/outputD1.png"
        set encoding utf8
        set margins 12, 12, 15, 5
        unset ytics
        set y2range [0:*]
        set y2tics 50 rotate by 90 right
        set y2label 'NB ROUTES'
        set ylabel 'Option -d1 : Nb routes = f(Driver)'
        set style data histograms
        set style fill solid
        set boxwidth 0.4 absolute
        set offset 0.5, 0.5, 0, 0
        set xtic rotate by 90 right
        set xlabel 'DRIVER NAMES' rotate by -180
        set datafile separator ";"
        set nokey
        plot 'resD1.txt' using 2:xtic(1) with boxes title "Valeurs" axes x1y2


EOF
    mogrify -rotate 90 'images/outputD1.png'
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
        set term png enhanced size 1200,1000
        set output "images/outputD2.png"
        set encoding utf8
        set margins 12, 12, 15, 5
        unset ytics
        set y2range [0:*]
        set y2tics 20000 rotate by 90 right
        set y2label 'DISTANCE (Km)'
        set ylabel 'Option -d2 : Distance = f(Driver)'
        set style data histograms
        set style fill solid
        set boxwidth 0.4 absolute
        set offset 0.5, 0.5, 0, 0
        set xtic rotate by 90 right
        set xlabel 'DRIVER NAMES' rotate by -180
        set datafile separator ";"
        set nokey
        plot 'resD2.txt' using 2:xtic(1) with boxes title "Valeurs" axes x1y2 linecolor rgb "green"


EOF

    mogrify -rotate 90 'images/outputD2.png'
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
    set yrange [0:*]
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
    }' "$fichier_de_travail" > tempT.txt

    # Compile le programme C
    make -C progc/T run

    # Ajoutez ici la compilation du programme C si nécessaire

    # Génération du graphique avec gnuplot
    output_fileT="images/outputT.png"
    gnuplot <<EOF
    set term png enhanced size 1200,1000
    set output "$output_fileT"
    set encoding utf8
    set margins 10, 10, 7, 5
    set yrange [0:*]
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

    echo "Graphique généré et enregistré sous : $output_fileT"
    echo "Durée du traitement T: $duration secondes"

    if [ -e tempT.txt ]; then
        mv tempT.txt temp/
        echo "Le tempT.txt a été déplacé dans le dossier temp."
    else
        echo "Le tempT.txt n'existe pas."
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

    output_fileS="images/outputS.png"
# Code Gnuplot
gnuplot <<EOF
    
    set term png enhanced size 1200,1000
    set output "$output_fileS"
    set encoding utf8
    set yrange [0:*]
    set title "Option -s: Distance =f(Route)"
    set ytics 100
    set ylabel "Distance (Km)"
    set xlabel "Route ID"
    set style data lines
    set xtic rotate by 45 right
    set datafile separator ";"
    
    
    plot 'res/resS.txt' using 1:3:5:xtic(2) with filledcurves title 'Distance Max/Min (Km)' lc rgb "light-blue" , \
     	'' using 1:4 smooth mcs with lines title 'Distance average (Km)' lc rgb "red" 

EOF
    




    # Enregistrer le temps de fin
    end_time=$(date +%s.%N)
    duration=$(awk "BEGIN {print $end_time - $start_time}")

    # Afficher la durée du traitement
    echo ""
    echo "Graphique généré et enregistré sous : $output_fileS"
    echo "Durée du traitement S: ${duration} secondes"
 if [ -e tempS.txt ]; then
        mv tempS.txt temp/
        echo "Le tempS.txt a été déplacé dans le dossier temp."
    else
        echo "Le tempS.txt n'existe pas."
    fi
   
}

function gestion_option_h {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h)
                echo "Vous avez ignoré tous les traitements et êtes revenu au menu."
                afficher_aide
                ;;
            *)
                shift
                ;;
        esac
    done
}

gestion_option_h "$@"

# Ignorer le premier argument qui est le chemin du fichier
shift

# Parcourir les arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
    	-a)
    		traitementD1
    		traitementD2
    		traitementL
    		traitementT
    		traitementS
    		;;
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

#clean
