cpyrr
{
// Test de la fonction afficher et de différentes erreurs de format

// CORRECT
afficher("bonjour %d %s %c %d %f\n", 3, "bonjour", 'c', 5, 3.15);

// FORMATS numéro 1, 3 et 5 INCORRECTS
afficher("bonjour %f %s %d %d %s\n", 3, "bonjour", 'c', 5, 3.15);

// TROP D'ARGUMENTS
afficher("bonjour %f %s %c %d\n", 3, "bonjour", 'c', 5, 3.15);

// TROP DE FORMATS
afficher("bonjour %f %s %c %d %f\n", 3, "bonjour", 'c', 5);
}
