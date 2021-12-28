// Module de gestion des blob de données

#ifndef BLOB_H_
#define BLOB_H_

typedef long int blob; // Espace mémoire de 8 octets (64 bits)
typedef enum {false, true} bool; // Définition des constantes booléennes

// Types indiquant la nature d'un blob
typedef enum {VOID, BOOL, CHAR, INT, DOUBLE, PTR, REGAPPL, REGENGL} types;

// Structure definissant une variable versatile
typedef struct {
  blob val;   // Valeur
  types nat;  // Nature
} ninja;


// Conversion entre les constantes types de l'arbre d'execution et de la pile
types type_conv(int i);


/* Conversions de type primitif vers blob */

// Conversion de bool vers blob
blob bool2blob(bool b);
// Conversion de char vers blob
blob char2blob(char c);
// Conversion de int vers blob
blob int2blob(int i);
// Conversion de double vers blob
blob double2blob(double d);
// Conversion de pointeur vers blob
blob ptr2blob(void *p);


/* Conversions de blob vers type primitif */

// Conversion de blob vers bool
bool blob2bool(blob b);
// Conversion de blob vers char
char blob2char(blob b);
// Conversion de blob vers int
int blob2int(blob b);
// Conversion de blob vers double
double blob2double(blob b);
// Conversion de blob vers pointeur
void *blob2ptr(blob b);


/* Fonction sur les variables versatiles */

// Initialise une variable versatile
ninja init_ninja(blob b, types t);
// Affiche une variable versatile
void aff_ninja(ninja n);
// Retourne true si une variable versatile est numérique, false sinon
bool est_num(ninja n);
// Conversion d'une variable versatile vers char 
void conv_char(ninja *n);
// Conversion d'une variable versatile vers int
void conv_int(ninja *n);
// Conversion d'une variable versatile vers double
void conv_double(ninja *n);

#endif