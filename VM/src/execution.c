#include <stdio.h>

#include "../inc/io.h"
#include "../inc/eval.h"
#include "../inc/pile_exec.h"
#include "../inc/execution.h"
#include "../../inc/macros_arbres.h"
#include "../../GenTexte/inc/GenTexte.h"
#include "../../TabDecla/inc/TabDecla.h"
#include "../../TabLexico/inc/TabLexico.h"
#include "../../TabRegion/inc/TabRegion.h"
#include "../../TabRepresentation/inc/TabRepresentation.h"

pilex pile_exec_g;
int reg_actu_g;
ninja retval_g;

void appel_fctproc(int num_reg, arbre a);
void ajout_arg(int base_reg, int numreg, int numdecl, int arg_num, arbre a);
void retour();
void charger_reg(int num_reg);
void chainage_dynamique(int base_region_appl);
void chainage_statique(int base_region_appl, int nis);

var_info info_var(arbre a);
var_info info_artefact(int numdecl, arbre a);
int var_dec_tab(int dim, int ind_rep, int *taille_case, arbre a, arbre *suite);

// Execute un fichier de texte intermediare
void execution(FILE *fic){
  // Génération des tables et arbres d'execution
  generer_tables(fic);
  // Création de la pile d'execution
  pile_exec_g = pilex_init(100 * MAX_TAB_LEX);
  // Initialisation del al pile
  pilex_empn(taille_reg(0), pile_exec_g);
  // Initialisation de la région actuelle
  reg_actu_g = 0;
  // Éxection de l'arbre
  exec_arbre(arbre_reg(0));

  // Si tout c'est bien passé
  printf(
    "\nExecution terminée normalement: valeur de retour: 0x%016lx\n",
    retval_g.val);
  // Libération de l'espace occupé par la pile d'execution
  pilex_liberer(pile_exec_g);
}

// Exectue un arbre d'execution
bool exec_arbre(arbre a){
  int dec;
  mem val;
  ninja eval;
  if (est_vide(a)){ return false; }

  switch (a->nature){
  case A_LISTE_INSTR:
    if (exec_arbre(a->fils_gauche)){ return true;  }
    return exec_arbre(a->fils_gauche->frere_droit);

  case A_RETOURNE :
    retval_g = eval_arbre(a->fils_gauche);
    retour();
    return true;

  case A_FIN_PROC :
    retour();
    return true;

  case A_AFFECTATION :
    eval = eval_arbre(a->fils_gauche->frere_droit);
    dec = info_pile_var(a->fils_gauche).dec;
    val = mem_init(eval.val, eval.nat, pilex_recval(dec, pile_exec_g).id);
    pilex_modval(val, dec, pile_exec_g);
    break;

  case A_SI_ALORS :
    if (eval_arbre(a->fils_gauche).val){
      return exec_arbre(a->fils_gauche->frere_droit);
    }
    break;

  case A_SI_ALORS_SINON :
    if (eval_arbre(a->fils_gauche).val){
      return exec_arbre(a->fils_gauche->frere_droit);
    } else {
      return exec_arbre(a->fils_gauche->frere_droit->frere_droit);
    }
    break;

  case A_TANT_QUE :
    while (eval_arbre(a->fils_gauche).val){
      if (exec_arbre(a->fils_gauche->frere_droit)){ return true; }
    }
    break;

  case A_AFFICHER :
    io_affiche(eval_arbre(a->fils_gauche), a->fils_gauche->frere_droit);
    break;

  case A_LIRE :
    io_lire(a->fils_gauche);
    break;

  case A_APPEL_PROC :
    appel_fctproc(valeur_exec_tab_decla(a->numdecl), a);
    break;

  case A_APPEL_FCT :
    appel_fctproc(valeur_exec_tab_decla(a->numdecl), a);
    break;

  case A_VIDE :  break;

  default:
    err_exec("Exec: Noeud non reconnu");
  }

  return false;
}

// Gestion de l'appel d'une fonction
void appel_fctproc(int num_reg, arbre a){
  int som = pilex_possom(pile_exec_g);
  charger_reg(num_reg);

  // Ajout des arguements
  ajout_arg(som + 1, num_reg, a->numdecl, 1, a->fils_gauche);
  // Changement de la région actuelle
  reg_actu_g = num_reg;
  // Déplacement de la base courante
  pilex_deplbase(som + 1, pile_exec_g);
  // Execution de l'arbre d'execution de la fonction
  exec_arbre(arbre_reg(num_reg));
}

// Charge la région d'une fonction
void charger_reg(int num_reg){
  int base_region_appl = pilex_posbase(pile_exec_g);
  chainage_dynamique(base_region_appl);
  chainage_statique(base_region_appl, nis_reg(num_reg));
  pilex_empn(taille_reg(num_reg) - nis_reg(num_reg) - 1, pile_exec_g);
}

// Crée un chainage dynamique <=> adresse de la région appelante
void chainage_dynamique(int base_region_appl){
  mem reg_appl = {REGAPPL, reg_actu_g, int2blob(base_region_appl)};
  pilex_emp(reg_appl, pile_exec_g);
}

// Crée un chainage statique <=> adresse des régions englobantes
void chainage_statique(int base_region_appl, int nis){
  int lim;
  mem reg_engl;

  // lim = min(nis(region actuelle), nis(region appelée))
  lim = (nis <= nis_reg(reg_actu_g)) ? nis : nis_reg(reg_actu_g);

  for (int i = 1; i <= lim; i++){
    // Copie du chainage statique de la région appelante
    pilex_emp(pilex_recbaseval(i, pile_exec_g), pile_exec_g);
  }

  // Si le nis de la region est supérieur au nis de la région appelante
  // => region incluse dans la région appelante
  if (nis > nis_reg(reg_actu_g)) {
    // Ajout de la région appelante dans les regions englobantes
    reg_engl = mem_init(int2blob(base_region_appl), REGENGL, reg_actu_g);
    pilex_emp(reg_engl, pile_exec_g);
  }
}

// Ajoute les arguments de la fonciton
void ajout_arg(int base_reg, int numreg, int numdecl, int arg_num, arbre a){
  // Défini si les arguments sont ceux d'une fonction ou d'une procedure
  int forp = (nature(numdecl) == FCT) ? 1 : 0;
  int nb_param = valeur_tab_representation(
    valeur_description_tab_decla(numdecl) + forp
    );
  int numlex_arg, nat_arg, numdecl_arg, dec_arg;
  ninja val_arg;
  mem arg;

  if (arg_num > nb_param){
    if (!est_vide(a)){
      err_exec("Erreur appel fonction/procedure: trop d'arguments");
    } else { return; }
  }

  if (est_vide(a)){
    err_exec("Erreur appel fonction/procedure: manque d'arguements");
  }

  // Numero lexico -> num decla -> decalage de l'argument
  numlex_arg = valeur_tab_representation(
      valeur_description_tab_decla(numdecl) + 2 * arg_num + forp
      );

  numdecl_arg = lex2decl(numlex_arg, PARAMETRE, numreg);
  dec_arg = valeur_exec_tab_decla(numdecl_arg);

  // Nature de l'arguement
  nat_arg = valeur_tab_representation(
      valeur_description_tab_decla(numdecl) + 2 * arg_num + forp - 1
      );

  // Evaluation de la valeur de l'arbre
  val_arg = eval_arbre(a->fils_gauche);

  if (val_arg.nat != type_conv(nat_arg)){
    err_exec("Err: arg fonction/procedure: type différents");
  }

  arg = mem_init(val_arg.val, val_arg.nat, numdecl_arg);
  pilex_modval(arg, base_reg + dec_arg + nis_reg(numreg) + 1, pile_exec_g);
  ajout_arg(base_reg, numreg, numdecl, arg_num + 1, a->fils_gauche->frere_droit);
}

// Gestion du retour de procedure/fonction
void retour(){
  mem addr_ret = pilex_recbaseval(0, pile_exec_g);
  int base = blob2int(addr_ret.data);
  int reg = addr_ret.id;

  // Déplacement de la base à la région appelante
  pilex_deplbase(base, pile_exec_g);
  // Dépilement de la région appelée
  pilex_depn(taille_reg(reg_actu_g), pile_exec_g);
  reg_actu_g = reg;
}

// Informations sur une variable décrite par l'arbre a
// <=>   Nature de la varible
//     + Decalage par rapport à la pile d'une variable
var_info info_pile_var(arbre a){
  int dec = 0;
  int numdecl = a->fils_gauche->numdecl;
  int reg_val = region(numdecl);
  var_info info;
  mem var;

  // Si la variable est dans la region
  if (reg_val == reg_actu_g){
    dec = pilex_posbase(pile_exec_g);
  } else {
    // Sinon on récupère la base de la région contenant la variable
    dec = blob2int(pilex_recbaseval(nis_reg(reg_val) + 1, pile_exec_g).data);
  }

  // Recupération des informations sur la variable
  info = info_var(a);
  info.dec += dec;

  // Modification de la nature de la variable
  var = pilex_recval(info.dec, pile_exec_g);
  var.nat = info.nat;
  var.id = numdecl;
  pilex_modval(var, info.dec, pile_exec_g);

  return info;
}

// Decalage par rapport à la base d'une variable
var_info info_var(arbre a){
  int numdecl = a->fils_gauche->numdecl;
  int type_numdecl;
  var_info info = {0, VOID}, val;

  type_numdecl = valeur_description_tab_decla(numdecl);
  val = info_artefact(type_numdecl, a->fils_gauche);

  // Décalage par rapport à la Base Courante...
  info.dec += valeur_exec_tab_decla(numdecl);
  // ...suite (Chainage statique) ...
  info.dec += nis_reg(region(numdecl));
  //...suite (Chainage dynamique)
  info.dec += (region(numdecl) == 0) ? 0 : 1;
  // Décalage dans la variable (i.e. struct & tab)
  info.dec += val.dec;
  info.nat = val.nat;

  return  info;
}

// Decalage d'un index/champ par rapport à "l'adresse" de la variable
var_info info_artefact(int numdecl, arbre a){
  int i, numlex_ch, dim, taille_type, ind_rep, taille_struct;
  arbre s;
  var_info info = {0, VOID}, rec;

  // Arrive lorsque la variable est un tableau (à la fin)
  if (est_vide(a)){
    return info;
  } else if (a->nature == A_VAR_SIMPLE){
    // Si la variable n'est pas un champ de structure
    if (a->numdecl != -1){
      info.nat = type_conv(valeur_description_tab_decla(a->numdecl));
    }
    return info;
  }

  // Index de representation du type
  ind_rep = valeur_description_tab_decla(numdecl);
  // Si la variable est une structure
  if (a->nature == A_STRUCT){
    taille_struct = valeur_tab_representation(ind_rep);

    // Recherche du champ conserné
    for (i = 1; i <= taille_struct * 3; i += 3){
      numlex_ch = valeur_tab_representation(ind_rep + i + 1);
      if (a->fils_gauche->numlex == numlex_ch){ break; }
    }

    numdecl = valeur_tab_representation(ind_rep + i);
    info.dec = valeur_tab_representation(ind_rep + i + 2);

    taille_type = valeur_exec_tab_decla(numdecl);
    // Si le type est primitif
    if (taille_type == 1){
      info.nat = type_conv(numdecl);
    }

    s = a->fils_gauche;
  }

  // Si la variable est un tableau
  if (a->nature == A_TAB){
    numdecl = valeur_tab_representation(ind_rep);

    taille_type = valeur_exec_tab_decla(numdecl);
    dim = valeur_tab_representation(ind_rep + 1);

    // Si le type est primitif
    if (taille_type == 1){
      info.nat = type_conv(numdecl);
    }

    info.dec = var_dec_tab(dim, ind_rep + 2, &taille_type, a->fils_gauche, &s);
  }

  // On récupère récursivement les infos sur la variable;
  rec = info_artefact(numdecl, s);
  info.dec += rec.dec;
  info.nat = rec.nat != VOID ? rec.nat : info.nat;

  return info;
}

// Decalage d'un index par rapport à "l'adresse" de la variable
int var_dec_tab(int dim, int ind_rep, int *taille_case, arbre a, arbre *suite){
  int min, max, ind, dec, dist;

  if (dim == 0) {
    if (!est_vide(a)){
      a = concat_pere_fils(creer_noeud(0, 0, A_STRUCT, 0, 0), a);
    }
    *suite = a;
    return 0;
  }

  if (est_vide(a)){
    err_exec("Erreur sur tableau: manque de dimension");
  }

  ind = blob2int(eval_arbre(a->fils_gauche).val);
  min = valeur_tab_representation(ind_rep);
  max = valeur_tab_representation(ind_rep + 1);

  if (ind < min || ind > max){
    err_exec("Erreur sur tableau: indice en dehors du tableau");
  }

  dist = max - min + 1;

  dec = var_dec_tab(
    dim - 1, ind_rep + 2, taille_case,
    a->fils_gauche->frere_droit, suite
    );
  dec += (ind - min) * (*taille_case);

  *taille_case *= dist;

  return dec;
}
