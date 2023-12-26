#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node {
    int id;
    float min;
    float max;
    float avg;
    float dif;
    struct Node *left;
    struct Node *right;
    int height;
} Node;

// Fonction pour créer un nouveau nœud
Node *newNode(int id, float min, float avg, float max, float dif) {
    Node *node = (Node *)malloc(sizeof(Node));
    if (node == NULL) {
        // Gérer l'échec d'allocation mémoire ici
        exit(1);
    }
    node->id = id;
    node->min = min;
    node->max = max;
    node->avg = avg;
    node->dif = dif;

    node->left = NULL;
    node->right = NULL;
    node->height = 1;
    return node;
}


// Fonction pour obtenir la hauteur d'un nœud
int height(Node *node) {
    if (node == NULL)
        return 0;
    return node->height;
}

// Fonction pour obtenir le maximum entre deux entiers
int maxi(int a, int b) {
    return (a > b) ? a : b;
}

// Fonction pour faire une rotation à droite
Node *rightRotate(Node *y) {
    Node *x = y->left;
    Node *T2 = x->right;

    // Effectuer la rotation
    x->right = y;
    y->left = T2;

    // Mettre à jour les hauteurs
    y->height = maxi(height(y->left), height(y->right)) + 1;
    x->height = maxi(height(x->left), height(x->right)) + 1;

    // Retourner le nouveau nœud racine
    return x;
}

// Fonction pour faire une rotation à gauche
Node *leftRotate(Node *x) {
    Node *y = x->right;
    Node *T2 = y->left;

    // Effectuer la rotation
    y->left = x;
    x->right = T2;

    // Mettre à jour les hauteurs
    x->height = maxi(height(x->left), height(x->right)) + 1;
    y->height = maxi(height(y->left), height(y->right)) + 1;

    // Retourner le nouveau nœud racine
    return y;
}

// Obtenir le facteur d'équilibre d'un nœud
int getBalance(Node *node) {
    if (node == NULL)
        return 0;
    return height(node->left) - height(node->right);
}

// Insérer un nouveau nœud dans l'arbre AVL
Node *insert(Node *node, int id, float min, float avg, float max, float dif) {
    // Étape 1: Insertion standard de l'élément BST
    if (node == NULL) {
        return newNode(id, min, avg, max, dif);
    }

    // Comparaison des clés
    if (dif < node->dif || (dif == node->dif && id < node->id)) {
        node->left = insert(node->left, id, min, avg, max, dif);
    } else if (dif > node->dif || (dif == node->dif && id > node->id)) {
        node->right = insert(node->right, id, min, avg, max, dif);
    } else {
        // Les clés et les noms sont les mêmes, il est possible de choisir un côté pour insérer
        node->right = insert(node->right, id, min, avg, max, dif); // Insérer à droite arbitrairement
    }

    // Étape 2: Mettre à jour la hauteur du nœud actuel
    node->height = 1 + maxi(height(node->left), height(node->right));

    // Étape 3: Obtenir le facteur d'équilibre de ce nœud pour vérifier l'équilibre
    int balance = getBalance(node);

    // Les rotations pour équilibrer l'arbre selon les cas

    // Cas gauche-gauche
    if (balance > 1 && (dif < node->left->dif || (dif == node->left->dif && id < node->left->id))) {
        return rightRotate(node);
    }

    // Cas droite-droite
    if (balance < -1 && (dif > node->right->dif || (dif == node->right->dif && id > node->right->id))) {
        return leftRotate(node);
    }

    // Cas gauche-droite
    if (balance > 1 && (dif > node->left->dif || (dif == node->left->dif && id > node->left->id))) {
        node->left = leftRotate(node->left);
        return rightRotate(node);
    }

    // Cas droite-gauche
    if (balance < -1 && (dif < node->right->dif || (dif == node->right->dif && id < node->right->id))) {
        node->right = rightRotate(node->right);
        return leftRotate(node);
    }

    // Si l'arbre est équilibré, retourner le nœud actuel
    return node;
}




void infixe(Node *root, FILE *fichier, int *count) {
    if (root != NULL && *count < 50) {
        // Parcours inversé : d'abord le sous-arbre droit, puis le nœud actuel, ensuite le sous-arbre gauche
        infixe(root->right, fichier, count);

        if (*count < 50) {
            fprintf(fichier, "%d;%d;%.3f;%.3f;%.3f;%.3f\n",*(count)+1, root->id, root->min, root->avg, root->max, root->dif);
            (*count)++; // Incrémenter le compteur après l'impression d'un élément
        }

        infixe(root->left, fichier, count);
    }
}





/**
void afficherArbre(Node* arbre, int niveau) {
    if (arbre == NULL) {
        return;
    }

    // Espacement entre les niveaux
    int espacement = 5;

    // Augmenter la distance pour les niveaux inférieurs
    niveau += espacement;

    // Afficher le sous-arbre droit
    afficherArbre(arbre->right, niveau);

    // Afficher l'élément actuel
    printf("\n");
    for (int i = espacement; i < niveau; i++) {
        printf(" ");
    }
    printf("%d,%c\n", arbre->key,arbre->name[0]);

    // Afficher le sous-arbre gauche
    afficherArbre(arbre->left, niveau);
}

*/
void libererArbre(Node *arbre) {
    if (arbre == NULL) {
        return;
    }
    free(arbre);
}


int main() {
    FILE *fichier;
    fichier = fopen("temp.txt", "r"); // Remplacez "votre_fichier.txt" par le nom de votre fichier

    if (fichier == NULL) {
        printf("Impossible d'ouvrir le fichier.\n");
        return 1;
    }

    char ligne[100];
    Node *racineAVL = NULL; // Initialisation de la racine de l'AVL à NULL

    while (fgets(ligne, sizeof(ligne), fichier) != NULL) {
        int id;
        float min, avg, max, dif;

        // Utilisation de sscanf pour extraire les données de chaque ligne
        if (sscanf(ligne, "%d;%f;%f;%f;%f", &id, &min, &avg, &max, &dif) != 5) {
            printf("Erreur de lecture de la ligne : %s\n", ligne);
            continue;
        }

        // Insérer les données dans l'AVL
        racineAVL = insert(racineAVL, id, min, avg, max, dif);
    }

    fclose(fichier);
    
    fichier=fopen("resultats.txt","w");
    int compteur=0;
    infixe(racineAVL, fichier, &compteur);
    fclose(fichier);
    

    // Libération de la mémoire allouée pour l'arbre à la fin de l'utilisation
    libererArbre(racineAVL);

    return 0;
}
