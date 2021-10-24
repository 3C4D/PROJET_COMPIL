# Projet de compilation

## Utilisation du Makefile

La commande `make` va compiler l'exécutable bin/cpyrr qui permettra compiler un
programme dans le langage CPYRR et l'exécutable VM/bin/machine_virtuelle qui
permettra d'exécuter le programme compilé.

## Utilisation du compilateur

### Options
```
./bin/cpyrr [OPTIONS] <prog_cpyrr> <output>
     * [OPTIONS] :
         * l : afficher table decla
         * d : afficher table decla
         * t : afficher table types
         * r : afficher table regions
         * a : afficher arbres
     * <prog_cpyrr> : programme cpyrr
     * <output> : nom du programme généré
```
