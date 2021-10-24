# TOUT POUR LA TABLE LEXICOGRAPHIQUE
SRC_DIR_TABLEX := TabLexico/src
OBJ_DIR_TABLEX := TabLexico/obj

# TOUT POUT LA TABLE DES DECLARATION
SRC_DIR_TABDECLA := TabDecla/src
OBJ_DIR_TABDECLA := TabDecla/obj

# TOUT POUT LA TABLE DE REPRESENTATION DES TYPES
SRC_DIR_TABTYPES := TabRepresentation/src
OBJ_DIR_TABTYPES := TabRepresentation/obj

# TOUT POUT LA TABLE DES REGION
SRC_DIR_TABREG := TabRegion/src
OBJ_DIR_TABREG := TabRegion/obj

# TOUT POUR LES ARBRES
SRC_DIR_ARBRES := arbres/src
OBJ_DIR_ARBRES := arbres/obj

# TOUT POUR LA GENERATION DU TEXTE INTERMEDIAIRE
SRC_DIR_GENTEXTE := GenTexte/src
OBJ_DIR_GENTEXTE := GenTexte/obj

# TOUT POUR LA VM
SRC_DIR_VM := VM/src
OBJ_DIR_VM := VM/obj
BIN_DIR_VM := VM/bin
EXE_VM := $(BIN_DIR_VM)/machine_virtuelle

# TOUT POUR LE COMPILATEUR
SRC_DIR_COMPIL := src
OBJ_DIR_COMPIL := obj
BIN_DIR_COMPIL := bin
EXE_COMPIL := $(BIN_DIR_COMPIL)/cpyrr

# TOUS LES EXECUTABLES (DONT CEUX DE TEST)
ALL_EXE  := $(EXE_COMPIL) $(EXE_VM)

SRC_TABLEX := $(wildcard $(SRC_DIR_TABLEX)/*.c)
OBJ_TABLEX := $(SRC_TABLEX:$(SRC_DIR_TABLEX)/%.c=$(OBJ_DIR_TABLEX)/%.o)

SRC_TABDECLA := $(wildcard $(SRC_DIR_TABDECLA)/*.c)
OBJ_TABDECLA := $(SRC_TABDECLA:$(SRC_DIR_TABDECLA)/%.c=$(OBJ_DIR_TABDECLA)/%.o)

SRC_TABTYPES := $(wildcard $(SRC_DIR_TABTYPES)/*.c)
OBJ_TABTYPES := $(SRC_TABTYPES:$(SRC_DIR_TABTYPES)/%.c=$(OBJ_DIR_TABTYPES)/%.o)

SRC_TABREG := $(wildcard $(SRC_DIR_TABREG)/*.c)
OBJ_TABREG := $(SRC_TABREG:$(SRC_DIR_TABREG)/%.c=$(OBJ_DIR_TABREG)/%.o)

SRC_TABDECLA := $(wildcard $(SRC_DIR_TABDECLA)/*.c)
OBJ_TABDECLA := $(SRC_TABDECLA:$(SRC_DIR_TABDECLA)/%.c=$(OBJ_DIR_TABDECLA)/%.o)
OBJ_TABDECLA := $(OBJ_TABDECLA) $(OBJ_DIR_TABLEX)/TabLexico.o

SRC_ARBRES := $(wildcard $(SRC_DIR_ARBRES)/*.c)
OBJ_ARBRES := $(SRC_ARBRES:$(SRC_DIR_ARBRES)/%.c=$(OBJ_DIR_ARBRES)/%.o)
OBJ_ARBRES := $(OBJ_ARBRES) $(OBJ_DIR_TABLEX)/TabLexico.o

SRC_GENTEXTE := $(wildcard $(SRC_DIR_GENTEXTE)/*.c)
OBJ_GENTEXTE := $(SRC_GENTEXTE:$(SRC_DIR_GENTEXTE)/%.c=$(OBJ_DIR_GENTEXTE)/%.o)

SRC_VM := $(wildcard $(SRC_DIR_VM)/*.c)
OBJ_VM := $(SRC_VM:$(SRC_DIR_VM)/%.c=$(OBJ_DIR_VM)/%.o)
OBJ_VM := $(OBJ_VM) $(OBJ_COMPIL_EXT) $(OBJ_DIR_COMPIL)/fct_aux_yacc.o

SRC_COMPIL := $(SRC_DIR_COMPIL)/*
OBJ_COMPIL := $(OBJ_DIR_COMPIL)/*.o
OBJ_COMPIL_EXT := $(OBJ_DIR_TABLEX)/TabLexico.o
OBJ_COMPIL_EXT := $(OBJ_COMPIL_EXT) $(OBJ_DIR_TABDECLA)/TabDecla.o
OBJ_COMPIL_EXT := $(OBJ_COMPIL_EXT) $(OBJ_DIR_ARBRES)/arbres.o
OBJ_COMPIL_EXT := $(OBJ_COMPIL_EXT) $(OBJ_DIR_TABTYPES)/TabRepresentation.o
OBJ_COMPIL_EXT := $(OBJ_COMPIL_EXT) $(OBJ_DIR_TABREG)/TabRegion.o
OBJ_COMPIL_EXT := $(OBJ_COMPIL_EXT) $(OBJ_DIR_GENTEXTE)/GenTexte.o

CC := gcc
CPPFLAGS := -Iinc -MMD -MP
CFLAGS   := -Wall -pedantic -g -O3
LDFLAGS  :=
LDLIBS   := -lm

.PHONY: all clean

all: $(ALL_EXE)

################################ EXECUTABLES ###################################

# COMPILATION DE L'EXECUTABLE DU COMPILATEUR CPYRR
$(EXE_COMPIL): obj bin $(SRC_COMPIL) $(OBJ_COMPIL_EXT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $(SRC_DIR_COMPIL)/fct_aux_lex.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $(SRC_DIR_COMPIL)/fct_aux_yacc.c
	mv fct_aux* $(OBJ_DIR_COMPIL)
	bison -dv $(SRC_DIR_COMPIL)/cpyrr.y
	mv cpyrr.tab.* cpyrr.output $(OBJ_DIR_COMPIL)
	flex $(SRC_DIR_COMPIL)/cpyrr.l
	mv lex.yy.c $(OBJ_DIR_COMPIL)
	gcc -o $(OBJ_DIR_COMPIL)/lex.yy.o -c $(OBJ_DIR_COMPIL)/lex.yy.c
	gcc -o $(OBJ_DIR_COMPIL)/cpyrr.tab.o -c $(OBJ_DIR_COMPIL)/cpyrr.tab.c
	gcc -o $(EXE_COMPIL) $(OBJ_COMPIL) $(OBJ_COMPIL_EXT)

$(EXE_VM): $(OBJ_DIR_VM) $(BIN_DIR_VM) $(OBJ_VM) $(OBJ_COMPIL_EXT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $(EXE_VM) $(OBJ_VM) $(OBJ_COMPIL_EXT)

########################## COMPILATION DES SOURCES #############################
$(OBJ_DIR_TABLEX)/%.o: $(SRC_DIR_TABLEX)/%.c | $(OBJ_DIR_TABLEX)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR_TABDECLA)/%.o: $(SRC_DIR_TABDECLA)/%.c | $(OBJ_DIR_TABDECLA)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR_TABTYPES)/%.o: $(SRC_DIR_TABTYPES)/%.c | $(OBJ_DIR_TABTYPES)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR_TABREG)/%.o: $(SRC_DIR_TABREG)/%.c | $(OBJ_DIR_TABREG)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR_ARBRES)/%.o: $(SRC_DIR_ARBRES)/%.c | $(OBJ_DIR_ARBRES)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR_GENTEXTE)/%.o: $(SRC_DIR_GENTEXTE)/%.c | $(OBJ_DIR_GENTEXTE)
		$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR_VM)/%.o: $(SRC_DIR_VM)/%.c | $(OBJ_DIR_VM)
		$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

########################### CREATION DES DOSSIERS ##############################
$(OBJ_DIR_TABLEX) $(OBJ_DIR_TABTYPES) $(OBJ_DIR_ARBRES) $(OBJ_DIR_TABDECLA):
	mkdir -p $@
$(OBJ_DIR_TABREG) $(OBJ_DIR_COMPIL) $(BIN_DIR_COMPIL) $(OBJ_DIR_GENTEXTE) :
	mkdir -p $@
$(OBJ_DIR_VM) $(BIN_DIR_VM):
	mkdir -p $@

################################# NETTOYAGE ####################################
clean:
	@$(RM) -rv $(OBJ_DIR_TABLEX) $(OBJ_DIR_TABDECLA) $(OBJ_DIR_TABTYPES)
	@$(RM) -rv $(OBJ_DIR_TABREG) $(OBJ_DIR_ARBRES) $(OBJ_DIR_COMPIL)
	@$(RM) -rv $(OBJ_DIR_GENTEXTE) $(OBJ_DIR_VM)

############################# NETTOYAGE COMPLET ################################
clean_all:
	@$(RM) -rv $(OBJ_DIR_TABLEX) $(OBJ_DIR_TABDECLA) $(OBJ_DIR_TABTYPES)
	@$(RM) -rv $(OBJ_DIR_TABREG) $(OBJ_DIR_ARBRES) $(OBJ_DIR_COMPIL)
	@$(RM) -rv $(BIN_DIR_COMPIL) $(OBJ_DIR_GENTEXTE) $(OBJ_DIR_VM) $(BIN_DIR_VM)
