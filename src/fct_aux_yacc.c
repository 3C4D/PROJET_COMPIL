// Fonctions auxiliaires utilisées dans le programme YACC

#include <stdlib.h>
#include <stdio.h>

extern int *tab_format;

// fonction permettant de déterminer combien et quels formats simples se
// trouvent dans une chaine de caractère
void format(char *str){
  char *ptr = str;

  tab_format[0] = 0;

  while(*ptr != '\0'){
    if(*ptr == '%'){
      if(*(ptr+1) == 'd'
      || *(ptr+1) == 'f'
      || *(ptr+1) == 'c'
      || *(ptr+1) == 's'
      ){
        tab_format[0]++;
        tab_format[tab_format[0]] = *(ptr+1)-'a';
      }
    }
    ptr++;
  }
}
