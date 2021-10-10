# TOUT POUR LA TABLE LEXICOGRAPHIQUE
SRC_DIR_TABLEX := tablex/src
OBJ_DIR_TABLEX := tablex/obj
BIN_DIR_TABLEX := tablex/bin
EXE_TABLEX := $(BIN_DIR_TABLEX)/tablex_test

# TOUT POUT LA TABLE DES DECLARATION
SRC_DIR_TABDECL := tabdecl/src
OBJ_DIR_TABDECL := tabdecl/obj
BIN_DIR_TABDECL := tabdecl/bin
EXE_TABDECL := $(BIN_DIR_TABDECL)/tabdecl_test

# TOUT POUR LES ARBRES
SRC_DIR_ARBRES := arbres/src
OBJ_DIR_ARBRES := arbres/obj
BIN_DIR_ARBRES := arbres/bin
EXE_ARBRES := $(BIN_DIR_ARBRES)/arbres_test

# TOUT POUR LE COMPILATEUR
SRC_DIR_COMPIL := src
OBJ_DIR_COMPIL := obj
BIN_DIR_COMPIL := bin
EXE_COMPIL := $(BIN_DIR_COMPIL)/cpyrr

# TOUS LES EXECUTABLES (DONT CEUX DE TEST)
ALL_EXE  := $(EXE_TABLEX) $(EXE_TABDECL) $(EXE_ARBRES) $(EXE_COMPIL)

SRC_TABLEX := $(wildcard $(SRC_DIR_TABLEX)/*.c)
OBJ_TABLEX := $(SRC_TABLEX:$(SRC_DIR_TABLEX)/%.c=$(OBJ_DIR_TABLEX)/%.o)

SRC_TABDECL := $(wildcard $(SRC_DIR_TABDECL)/*.c)
OBJ_TABDECL := $(SRC_TABDECL:$(SRC_DIR_TABDECL)/%.c=$(OBJ_DIR_TABDECL)/%.o)

SRC_ARBRES := $(wildcard $(SRC_DIR_ARBRES)/*.c)
OBJ_ARBRES := $(SRC_ARBRES:$(SRC_DIR_ARBRES)/%.c=$(OBJ_DIR_ARBRES)/%.o)
OBJ_ARBRES := $(OBJ_ARBRES) $(OBJ_DIR_TABLEX)/tablex.o

SRC_COMPIL := $(SRC_DIR_COMPIL)/cpyrr.*
OBJ_COMPIL := $(OBJ_DIR_COMPIL)/*.o
OBJ_COMPIL_EXT := $(OBJ_DIR_TABLEX)/tablex.o $(OBJ_DIR_TABDECL)/tabdecl.o
OBJ_COMPIL_EXT := $(OBJ_COMPIL_EXT) $(OBJ_DIR_ARBRES)/arbres.o

CC := gcc
CPPFLAGS := -Iinc -MMD -MP
CFLAGS   := -Wall -pedantic -g -O2
LDFLAGS  :=
LDLIBS   := -lm

.PHONY: all clean

all: $(ALL_EXE)

################################ EXECUTABLES ###################################

# COMPILATION DE L'EXECUTABLE DU COMPILATEUR CPYRR
$(EXE_COMPIL): obj bin $(SRC_COMPIL) $(OBJ_COMPIL_EXT)
	bison -dv $(SRC_DIR_COMPIL)/cpyrr.y
	mv cpyrr.tab.* cpyrr.output $(OBJ_DIR_COMPIL)
	flex $(SRC_DIR_COMPIL)/cpyrr.l
	mv lex.yy.c $(OBJ_DIR_COMPIL)
	gcc -o $(OBJ_DIR_COMPIL)/lex.yy.o -c $(OBJ_DIR_COMPIL)/lex.yy.c
	gcc -o $(OBJ_DIR_COMPIL)/cpyrr.tab.o -c $(OBJ_DIR_COMPIL)/cpyrr.tab.c
	gcc -o $(EXE_COMPIL) $(OBJ_COMPIL) $(OBJ_COMPIL_EXT)

# COMPILATION DE L'EXECUTABLE DE TEST DE LA TABLE LEXICOGRAPHIQUE
$(EXE_TABLEX): $(OBJ_TABLEX) | $(BIN_DIR_TABLEX)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

# COMPILATION DE L'EXECUTABLE DE TEST DE LA TABLE DES DECLARATIONS
$(EXE_TABDECL): $(OBJ_TABDECL) | $(BIN_DIR_TABDECL)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

# COMPILATION DE L'EXECUTABLE DE TEST DES ARBRES
$(EXE_ARBRES): $(OBJ_ARBRES) | $(BIN_DIR_ARBRES)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@


########################## COMPILATION DES SOURCES #############################
$(OBJ_DIR_TABLEX)/%.o: $(SRC_DIR_TABLEX)/%.c | $(OBJ_DIR_TABLEX)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR_TABDECL)/%.o: $(SRC_DIR_TABDECL)/%.c | $(OBJ_DIR_TABDECL)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR_ARBRES)/%.o: $(SRC_DIR_ARBRES)/%.c | $(OBJ_DIR_ARBRES)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@


########################### CREATION DES DOSSIERS ##############################
$(BIN_DIR_TABLEX) $(OBJ_DIR_TABLEX) $(BIN_DIR_TABDECL) $(OBJ_DIR_TABDECL):
	mkdir -p $@

$(BIN_DIR_COMPIL) $(OBJ_DIR_COMPIL) $(BIN_DIR_ARBRES) $(OBJ_DIR_ARBRES):
	mkdir -p $@


################################# NETTOYAGE ####################################
clean:
	@$(RM) -rv $(OBJ_DIR_TABLEX) $(OBJ_DIR_TABDECL) $(OBJ_DIR_COMPIL)
	@$(RM) -rv $(OBJ_DIR_ARBRES)

############################# NETTOYAGE COMPLET ################################
clean_all:
	@$(RM) -rv $(BIN_DIR_TABLEX) $(OBJ_DIR_TABLEX) $(BIN_DIR_TABDECL)
	@$(RM) -rv $(OBJ_DIR_TABDECL) $(BIN_DIR_COMPIL) $(OBJ_DIR_COMPIL)
	@$(RM) -rv $(BIN_DIR_ARBRES) $(OBJ_DIR_ARBRES)

-include $(OBJ_TABLEX:.o=.d)
-include $(OBJ_TABDECL:.o=.d)
-include $(OBJ_ARBRES:.o=.d)
