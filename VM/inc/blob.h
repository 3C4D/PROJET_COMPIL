//Module de gestion des blob de données

#ifndef BLOB_H_
#define BLOB_H_

typedef long int blob;
typedef enum {false, true} bool;

typedef enum {VOID, BOOL, CHAR, INT, DOUBLE, PTR, REGAPPL, REGENGL} types;

typedef struct {
  blob val;
  types nat;
} ninja;

types type_conv(int i);

blob bool2blob(bool b);
blob char2blob(char c);
blob int2blob(int i);
blob double2blob(double d);
blob ptr2blob(void *p);

bool blob2bool(blob b);
char blob2char(blob b);
int blob2int(blob b);
double blob2double(blob b);
void *blob2ptr(blob b);

ninja init_ninja(blob b, types t);
void aff_ninja(ninja n);
bool est_num(ninja n);
void conv_char(ninja *n);
void conv_int(ninja *n);
void conv_double(ninja *n);

#endif