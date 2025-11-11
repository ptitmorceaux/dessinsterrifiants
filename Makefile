# Variables
NASM_FLAGS=-felf64 -Fdwarf -g
GCC_FLAGS=-lm -fPIC -fno-pie -no-pie -z noexecstack --for-linker /lib64/ld-linux-x86-64.so.2 -lX11

# Dossier des étapes et des fonctions
ETAPES_DIR=etapes
FUNCTIONS_DIR=functions
OUTPUT_DIR=output

# Liste des fichiers ASM dans functions/
FUNCTIONS_SOURCES=$(wildcard $(FUNCTIONS_DIR)/*.asm)
FUNCTIONS_OBJECTS := $(FUNCTIONS_SOURCES:.asm=.o)

# Règle principale : compiler toutes les étapes
all: etape1 etape2 etape3 etape4_1 etape4_2
	echo "Les exécutables des étapes sont dans $(OUTPUT_DIR)/"

# Fonction pour assembler un fichier et ses dépendances
assemble: 
	@if [ -z "$(file)" ]; then \
		echo "Erreur : Spécifiez un fichier comme second argument, exemple : make assedmble file=etape1"; \
		exit 1; \
	fi
	
	@if [ -f $(ETAPES_DIR)/$(file).asm ]; then \
		echo "Assemblage de $(ETAPES_DIR)/$(file).asm"; \
		set -e; \
		nasm $(NASM_FLAGS) $(ETAPES_DIR)/$(file).asm -o $(ETAPES_DIR)/$(file).o; \
		for func in $(FUNCTIONS_SOURCES); do \
			echo "Assemblage de $$func"; \
			set -e; \
			nasm $(NASM_FLAGS) $$func -o $(FUNCTIONS_DIR)/$$(basename $$func .asm).o; \
		done; \
	else \
		echo "Fichier $(ETAPES_DIR)/$@.asm non trouvé."; \
	fi

# Règle pour chaque étape, crée l'exécutable
etape1: $(ETAPES_DIR)/etape1.asm $(FUNCTIONS_SOURCES)
	mkdir -p $(OUTPUT_DIR)
	make assemble file=etape1
	gcc $(ETAPES_DIR)/etape1.o $(FUNCTIONS_OBJECTS) -o $(OUTPUT_DIR)/etape1.out $(GCC_FLAGS)
	rm -f $(ETAPES_DIR)/etape1.o $(FUNCTIONS_OBJECTS) && \
	echo "$(OUTPUT_DIR)/etape1.out a été crée"

etape2: $(ETAPES_DIR)/etape2.asm $(FUNCTIONS_SOURCES)
	mkdir -p $(OUTPUT_DIR)
	make assemble file=etape2
	gcc $(ETAPES_DIR)/etape2.o $(FUNCTIONS_OBJECTS) -o $(OUTPUT_DIR)/etape2.out $(GCC_FLAGS)
	rm -f $(ETAPES_DIR)/etape2.o $(FUNCTIONS_OBJECTS) && \
	echo "$(OUTPUT_DIR)/etape2.out a été crée"

etape3: $(ETAPES_DIR)/etape3.asm $(FUNCTIONS_SOURCES)
	mkdir -p $(OUTPUT_DIR)
	make assemble file=etape3
	gcc $(ETAPES_DIR)/etape3.o $(FUNCTIONS_OBJECTS) -o $(OUTPUT_DIR)/etape3.out $(GCC_FLAGS)
	rm -f $(ETAPES_DIR)/etape3.o $(FUNCTIONS_OBJECTS) && \
	echo "$(OUTPUT_DIR)/etape3.out a été crée"

etape4_1: $(ETAPES_DIR)/etape4_1.asm $(FUNCTIONS_SOURCES)
	mkdir -p $(OUTPUT_DIR)
	make assemble file=etape4_1
	gcc $(ETAPES_DIR)/etape4_1.o $(FUNCTIONS_OBJECTS) -o $(OUTPUT_DIR)/etape4_1.out $(GCC_FLAGS)
	rm -f $(ETAPES_DIR)/etape4_1.o $(FUNCTIONS_OBJECTS) && \
	echo "$(OUTPUT_DIR)/etape4_1.out a été crée"

etape4_2: $(ETAPES_DIR)/etape4_2.asm $(FUNCTIONS_SOURCES)
	mkdir -p $(OUTPUT_DIR)
	make assemble file=etape4_2
	gcc $(ETAPES_DIR)/etape4_2.o $(FUNCTIONS_OBJECTS) -o $(OUTPUT_DIR)/etape4_2.out $(GCC_FLAGS)
	rm -f $(ETAPES_DIR)/etape4_2.o $(FUNCTIONS_OBJECTS) && \
	echo "$(OUTPUT_DIR)/etape4_2.out a été crée"

# Nettoyage
clean:
	echo "Suppression des exécutables"
	rm -f */*.out && \
	rm -f $(OUTPUT_DIR)/ && \
	echo "Les exécutables ont été supprimés"

fclean: clean
	make clean
	echo "Suppression des fichiers objets"
	rm -f */*.o && \
	echo "Les fichiers exécutables et objects ont été supprimés"

re: clean fclean all

.PHONY: all clean fclean re
