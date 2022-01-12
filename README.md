# Projet de compilation

## Utilisation du Makefile

La commande `make` va compiler l'exécutable bin/cpyrr qui permettra compiler un
programme dans le langage CPYRR et l'exécutable VM/bin/machine_virtuelle qui
permettra d'exécuter le programme compilé.

## Utilisation du compilateur

### Options
```
./bin/cpyrr [OPTIONS] <prog_cpyrr>
     * [OPTIONS] :
         * o <output> : précision du fichier d'ouput (défaut : a.out)
         * l : afficher table lexico
         * d : afficher table decla
         * t : afficher table types
         * r : afficher table regions
         * a : afficher arbres
     * <prog_cpyrr> : programme cpyrr
```

Exemple d'utilisation :

`./bin/cpyrr l d t o fichier_output r a tests/exemple.cpy`

Cela affichera toutes les tables ainsi que les arbres du programme exemple.cpy.
La commande aura aussi pour effet de créer l'exécutable fichier_output dans le
répertoire courant, regroupant les tables et le texte intermédiaire, ce qui
permettra à la machine virtuelle de l'exécuter (Cf ci-dessous) si toutefois la
compilation est possible.

Par défaut, le compilateur produit le fichier a.out si la compilation est un
succès et qu'aucun nom pour l'exécutable n'est précisé.

## Utilisation de la machine virtuelle

### Options
```
Usage : ./VM/bin/machine_virtuelle <fichier>
   <fichier> : programme cpyrr compilé

```

Exemple d'utilisation :

`./VM/bin/machine_virtuelle fichier_output`

La commande ci-dessus exécutera (ou tentera d'exécuter) le fichier
fichier_output, devant résulter d'une compilation d'un programme CPYRR par le
compilateur présenter dans le point précédent.
