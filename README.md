# README - Script d'Analyse de Données data.csv

Ce script Bash est conçu pour manipuler et analyser des données stockées dans un fichier CSV nommé `data.csv`. Il offre plusieurs fonctionnalités, telles que la création de dossiers, le déplacement de fichiers, l'analyse de données et la génération de statistiques.



# Préacquis
   Bonjour, pour commencer, veuillez vérifier si votre système est bien à jour en entrant la commande suivante dans votre terminal Ubuntu :
               
``` sh 
sudo apt update && sudo apt upgrade
```
Une fois que vous avez mis à jour le système, veuillez vérifier que Gnuplot est bien installé.

``` sh
gnuplot --version
```
verifier si le Makefile est bien installer sur Ubuntu
``` sh
      make --version
```
si il est pas installé  veillez installer en ecrivant la commande suivant sur votre terminale :
```sh
sudo apt update
sudo apt install make
```

Ensuite, veuillez installer cette commande qui  sera  utilisée pour les graphiques, notamment pour le premier et le deuxième graphique.

``` sh
sudo apt-get install imagemagick
```
## Structure du Script

Le script suit une structure logique pour faciliter la manipulation et l'analyse des données :
1. **Vérification de l'argument** : S'assure que le fichier `data/data.csv` est fourni en tant que premier argument.
2. **Création de dossiers** : Crée les dossiers nécessaires pour l'organisation des fichiers et des résultats.
3. **Déplacement des fichiers** : Déplace les fichiers d'un dossier source vers un dossier de destination.
4. **Vérification et préparation des données** : Vérifie l'existence du fichier `data.csv` et le déplace si nécessaire.
5. **Traitement des données** : Offre plusieurs options pour traiter les données, telles que l'affichage des conducteurs ayant effectué le plus de trajets, la liste des villes les plus traversées, etc.
6. **Affichage de l'aide** : Fournit des informations sur l'utilisation du script et les options disponibles.

## Utilisation

Pour utiliser ce script, naviguez dans le répertoire contenant le script et exécutez-le avec le chemin du fichier CSV en argument, suivi des options de traitement souhaitées.



### Syntaxe

```
./nom_du_script.sh data/data.csv [OPTIONS]
```

### Options

- `-D1` : Affiche les 10 conducteurs ayant effectué le plus de trajets.
- `-D2` : Liste les 10 conducteurs ayant parcouru la plus grande distance.
- `-L` : Affiche les 10 trajets les plus longs.
- `-T` : Liste les 10 villes les plus traversées.
- `-S` : Fournit des statistiques sur les étapes des trajets.
- `-h` : Affiche le message d'aide et quitte le script.

### Exemples d'Utilisation

Pour exécuter le traitement D1 et lister les 10 conducteurs ayant effectué le plus de trajets :
```
./nom_du_script.sh data/data.csv -D1
```

Pour combiner plusieurs options et exécuter plusieurs traitements en une seule exécution :

```
./nom_du_script.sh data/data.csv -D1 -D2 -L
```
### la fonction HELP(-h)
```sh
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
```
### info en plus.
 A la fin du script , il va vous demander si vous vouler supprimer les dossier suivant : temp , images , demo ,
  Si le fichier data.csv il n'est pas dans le dossier data , le script va vous le deplacer. mais aussi si les dossier suivant ne sont pas cree , le script va vous le cree lui meme.
  n'effacer surtout pas dans le dossier progc car , il contient les codes en C et le Makefile , vous pouvez effacer les dossier data , temp , images  , demo  car le shell va le cree si il detecte que il ne sont pas disponible
  Il est oblige que le data.csv soit en premiere argument , sans ca le code ne marchera pas , car il va vous afficher le message suivant :
  ```sh
Erreur : Vous devez fournir 'data/data.csv' comme premier argument.
Utilisation: ./tous9.sh data/data.csv [OPTIONS]

### Fonctionement de la commaned clean.
``` sh
./script.sh clean
```

### Licence : John shenouda , Sharow DAS , ALexandre

