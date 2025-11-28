#!/usr/bin/env bash
# ==================================================
# Script: pokedex.sh (VERSIÓN 40: ESTABILIDAD Y REGLAS FINALES)
# Descripción: Código unificado final con todas las funciones operativas, reglas de captura refinadas, y sistema de combate estable.
# ==================================================

# Variables para colores
verde="\e[32m"
rojo="\e[31m"
amarillo="\e[33m"
reset="\e[0m"
azul="\e[34m"
cian="\e[36m"
magenta="\e[35m"

# Variables de Archivos
JSON_FILE="pokedex.json"
PC_BILL_FILE="pc_de_bill.txt"
AVISTAMIENTOS_FILE="pokedex_avistamientos.txt"

# ==================================================
# --- FUNCIONES DE UTILIDAD Y REGISTRO ---
# ==================================================

# 1. comprobar_entorno
function comprobar_entorno() {
    clear
    echo -e "${amarillo}==================================================${reset}"
    echo -e "${verde}    BIENVENIDO A LA POKÉDEX NACIONAL (v40)${reset}"
    echo -e "${amarillo}==================================================${reset}"

    echo -e "${amarillo}Comprobando entorno...${reset}"
    if ! command -v jq &> /dev/null; then
        echo -e "${rojo}Error: La herramienta 'jq' no está instalada.${reset}"
        echo "Instálala, por favor."
        exit 1
    fi

    if [ ! -f "$JSON_FILE" ]; then
        echo -e "${rojo}Error: No se encuentra el archivo ${JSON_FILE}.${reset}"
        echo "Asegúrate de que 'pokedex.json' esté en esta carpeta."
        exit 1
    fi
    echo -e "${verde}Entorno OK. Pokédex Nacional (1008 Pokémon) cargada.${reset}"
    read -r -p "Presione [Enter] para continuar..."
}

# 2. registrar_captura (Envía al PC de Bill)
function registrar_captura() {
    local num="$1"
    local nombre="$2"
    local tipo="$3"

    local NUMERO_FORMATO=$(printf "%03d" "$num")
    local REGISTRO_LINEA="$(date '+[%Y-%m-%d %H:%M:%S]') Nº $NUMERO_FORMATO - $nombre (Capturado)"

    echo "$REGISTRO_LINEA" >> "$PC_BILL_FILE"

    echo -e "\a${azul}>> ¡CAPTURA REGISTRADA! Pokémon Nº $NUMERO_FORMATO enviado al PC de Bill. <<${reset}"
}

# 3. registrar_avistamiento (Solo registra en la Pokédex)
function registrar_avistamiento() {
    local num="$1"
    local nombre="$2"
    local tipo="$3"
    local NUMERO_FORMATO=$(printf "%03d" "$num")
    local REGISTRO_LINEA="$(date '+[%Y-%m-%d %H:%M:%S]') Nº $NUMERO_FORMATO - $nombre (${tipo})"

    echo "$REGISTRO_LINEA" >> "$AVISTAMIENTOS_FILE"

    echo -e "\a${cian}>> ¡AVISTAMIENTO REGISTRADO! Pokémon Nº $NUMERO_FORMATO añadido a la Pokédex. <<${reset}"
}

# 4. simular_escape_inicial (Lógica sin cambios)
function simular_escape_inicial() {
    local nivel="$1"
    local PROBABILIDAD_BASE=$(( nivel / 2 ))
    if [ $PROBABILIDAD_BASE -gt 50 ]; then PROBABILIDAD_BASE=50; fi

    local ALEATORIO=$(( RANDOM % 100 + 1 ))

    if [[ $ALEATORIO -le $PROBABILIDAD_BASE ]]; then
        echo -e "\n${rojo}¡El Pokémon salvaje escapó de inmediato! ($PROBABILIDAD_BASE% de probabilidad inicial).${reset}"
        return 0
    else
        return 1
    fi
}

# 5. simular_escape_fallo (Lógica sin cambios)
function simular_escape_fallo() {
    local nivel="$1"
    local PROBABILIDAD_ESCAPE=$(( (nivel / 2) + 10 ))
    if [ $PROBABILIDAD_ESCAPE -gt 90 ]; then PROBABILIDAD_BASE=90; fi

    local ALEATORIO=$(( RANDOM % 100 + 1 ))

    if [[ $ALEATORIO -le $PROBABILIDAD_ESCAPE ]]; then
        echo -e "\n${rojo}¡El Pokémon se liberó y escapó de la batalla! ($PROBABILIDAD_BASE% de escape).${reset}"
        return 0
    else
        echo -e "${amarillo}El Pokémon se liberó... ¡pero tienes otra oportunidad!${reset}"
        return 1
    fi
}

# 6. simular_captura_ruta (LÓGICA REFINADA: Dificultad alta)
function simular_captura_ruta() {
    local nivel="$1"
    local PROBABILIDAD=$(( RANDOM % 100 + 1 ))

    # Probabilidad base de captura = (100 - Nivel) / 2. Mínimo 5% de éxito.
    local CAPTURA_EXITO=$(( (100 - nivel) / 2 ))

    if [ "$CAPTURA_EXITO" -lt 5 ]; then
        CAPTURA_EXITO=5
    fi

    echo -e "${cian}--- Intentando Captura (Éxito: $CAPTURA_EXITO%) ---${reset}"
    echo -n "Lanzando Poké Ball... "
    sleep 1

    for i in {1..3}; do
        echo -n ". "
        sleep 0.5
    done
    echo

    if [[ $PROBABILIDAD -le $CAPTURA_EXITO ]]; then
        echo -e "${verde}¡CLICK! ¡Lo has capturado con éxito!${reset}"
        return 0
    else
        echo -e "${rojo}¡Oh no! El Pokémon se liberó. ¡Falló la captura!${reset}"
        return 1
    fi
}

# 7. simular_captura_debilitado (LÓGICA REFINADA: Combate - 80%/60% de éxito)
function simular_captura_debilitado() {
    local nivel="$1"
    local PROBABILIDAD=$(( RANDOM % 100 + 1 ))
    local CAPTURA_EXITO # Porcentaje de éxito

    # Regla de captura en combate: si está debilitado, la captura es más fácil que en ruta.
    if [ "$nivel" -le 45 ]; then
        CAPTURA_EXITO=80  # 80% de éxito
    else
        CAPTURA_EXITO=60 # 60% de éxito
    fi

    echo -e "${cian}--- Intento de Captura Debilitado (Éxito: $CAPTURA_EXITO%) ---${reset}"
    echo -n "Lanzando Poké Ball... "
    sleep 1

    for i in {1..3}; do
        echo -n ". "
        sleep 0.5
    done
    echo

    if [[ $PROBABILIDAD -le $CAPTURA_EXITO ]]; then
        echo -e "${verde}¡CLICK! ¡Lo has capturado con éxito!${reset}"
        return 0
    else
        echo -e "${rojo}¡Oh no! El Pokémon se liberó! (Fallo: $((100 - CAPTURA_EXITO))%).${reset}"
        return 1
    fi
}


# 8. Determinar Ventaja de Tipo (Lógica sin cambios)
function determinar_ventaja() {
    local tipo_atacante=$(echo "$1" | cut -d'/' -f1 | tr '[:upper:]' '[:lower:]')
    local tipo_defensor=$(echo "$2" | cut -d'/' -f1 | tr '[:upper:]' '[:lower:]')

    local ventaja=0

    declare -A FUERTE_CONTRA=(
        ["Fuego"]="Planta Hielo Bicho Acero" ["Agua"]="Fuego Tierra Roca"
        ["Planta"]="Agua Tierra Roca" ["Eléctrico"]="Agua Volador"
        ["Lucha"]="Normal Roca Acero Hielo Siniestro" ["Dragón"]="Dragón"
        ["Fantasma"]="Fantasma Psíquico" ["Roca"]="Fuego Hielo Volador Bicho"
        ["Tierra"]="Fuego Eléctrico Roca Acero Veneno" ["Siniestro"]="Psíquico Fantasma"
        ["Normal"]="" ["Hielo"]="Planta Tierra Volador Dragón"
    )
    declare -A DEBIL_CONTRA=(
        ["Fuego"]="Agua Roca Tierra" ["Agua"]="Eléctrico Planta"
        ["Planta"]="Fuego Hielo Veneno Volador Bicho" ["Eléctrico"]="Tierra"
        ["Lucha"]="Volador Psíquico Hada" ["Dragón"]="Hielo Dragón Hada"
        ["Fantasma"]="Siniestro Fantasma" ["Roca"]="Agua Planta Lucha Tierra Acero"
        ["Tierra"]="Agua Planta Hielo" ["Siniestro"]="Lucha Bicho Hada"
        ["Normal"]="Lucha" ["Hielo"]="Fuego Lucha Roca Acero"
    )

    case "$tipo_atacante" in
        "fuego") [ "$tipo_defensor" == "planta" ] || [ "$tipo_defensor" == "hielo" ] || [ "$tipo_defensor" == "bicho" ] || [ "$tipo_defensor" == "acero" ] && ventaja=1 ;;
        "agua") [ "$tipo_defensor" == "fuego" ] || [ "$tipo_defensor" == "tierra" ] || [ "$tipo_defensor" == "roca" ] && ventaja=1 ;;
        "planta") [ "$tipo_defensor" == "agua" ] || [ "$tipo_defensor" == "tierra" ] || [ "$tipo_defensor" == "roca" ] && ventaja=1 ;;
        "eléctrico") [ "$tipo_defensor" == "agua" ] || [ "$tipo_defensor" == "volador" ] && ventaja=1 ;;
        "hielo") [ "$tipo_defensor" == "planta" ] || [ "$tipo_defensor" == "tierra" ] || [ "$tipo_defensor" == "volador" ] || [ "$tipo_defensor" == "dragón" ] && ventaja=1 ;;
    esac

    if [ "$ventaja" -eq 0 ]; then
        case "$tipo_defensor" in
            "fuego") [ "$tipo_atacante" == "agua" ] || [ "$tipo_atacante" == "tierra" ] || [ "$tipo_atacante" == "roca" ] && ventaja=-1 ;;
            "agua") [ "$tipo_atacante" == "eléctrico" ] || [ "$tipo_atacante" == "planta" ] && ventaja=-1 ;;
            "planta") [ "$tipo_atacante" == "fuego" ] || [ "$tipo_atacante" == "hielo" ] || [ "$tipo_atacante" == "veneno" ] || [ "$tipo_atacante" == "volador" ] || [ "$tipo_atacante" == "bicho" ] && ventaja=-1 ;;
            "eléctrico") [ "$tipo_atacante" == "tierra" ] && ventaja=-1 ;;
            "hielo") [ "$tipo_atacante" == "fuego" ] || [ "$tipo_atacante" == "lucha" ] || [ "$tipo_atacante" == "roca" ] || [ "$tipo_atacante" == "acero" ] && ventaja=-1 ;;
        esac
    fi

    echo "$ventaja"
}

# 9. Lógica de Combate por Turnos (USO DE DAÑO SIMPLE)
function iniciar_combate() {
    echo -e "\n${amarillo}=== SELECCIÓN DE TU POKÉMON ===${reset}"
    read -r -p "Introduce el nombre o número de TU Pokémon: " TU_BUSQUEDA

    # 1. Verificar si el Pokémon ha sido capturado previamente (está en el PC)
    if [ ! -f "$PC_BILL_FILE" ] || ! grep -i -E "($TU_BUSQUEDA)" "$PC_BILL_FILE" &> /dev/null; then
        echo -e "\n${rojo}Error: Solo puedes combatir con Pokémon que ya hayas CAPTURADO (Opción 8).${reset}"
        echo -e "${amarillo}El Pokémon '$TU_BUSQUEDA' no se encuentra en el PC de Bill.${reset}"
        return
    fi

    TU_POKEMON_DATA=$(
        jq -r --arg query "$TU_BUSQUEDA" '.pokemons[] | select((.numero | tostring) == $query or (.nombre | ascii_downcase) == ($query | ascii_downcase)) | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$TU_POKEMON_DATA" ]; then
        echo -e "${rojo}Error: Tu Pokémon no se encontró. Vuelve al menú.${reset}"
        return
    fi
    mapfile -t TU_DATOS <<< "$TU_POKEMON_DATA"
    TU_NUM="${TU_DATOS[0]}"; TU_NOMBRE="${TU_DATOS[1]}"; TU_TIPO="${TU_DATOS[2]}"; TU_NIVEL="${TU_DATOS[3]}"

    # --- Generar Pokémon Rival (AHORA ES NACIONAL ALEATORIO) ---
    echo -e "\n${amarillo}=== BUSCANDO RIVAL NACIONAL ALEATORIO... ===${reset}"
    MIN_RIVAL=1; MAX_RIVAL=$(jq '.pokemons | length' "$JSON_FILE")
    RIVAL_IDS=$(jq -r --argjson min "$MIN_RIVAL" --argjson max "$MAX_RIVAL" '.pokemons[] | select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) | .numero | tostring' "$JSON_FILE")
    RIVAL_IDS_ARRAY=($RIVAL_IDS); TOTAL_IDS=${#RIVAL_IDS_ARRAY[@]}
    RIVAL_NUMERO=${RIVAL_IDS_ARRAY[$(( RANDOM % TOTAL_IDS ))]}

    RIVAL_POKEMON_DATA=$(jq -r --arg query "$RIVAL_NUMERO" '.pokemons[] | select(.numero | tostring == $query) | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)"' "$JSON_FILE" 2>/dev/null)
    mapfile -t RIVAL_DATOS <<< "$RIVAL_POKEMON_DATA"
    RIVAL_NOMBRE="${RIVAL_DATOS[1]}"; RIVAL_TIPO="${RIVAL_DATOS[2]}"; RIVAL_NIVEL="${RIVAL_DATOS[3]}"

    # --- Inicializar HP (Salud) ---
    TU_HP=$(( TU_NIVEL * 10 + 50 ))
    RIVAL_HP=$(( RIVAL_NIVEL * 10 + 50 ))
    RIVAL_HP_MAX=$RIVAL_HP
    TU_HP_MAX=$TU_HP

    echo -e "${verde}¡$RIVAL_NOMBRE salvaje apareció! Nivel $RIVAL_NIVEL. ${reset}"
    sleep 1

    # --- SIMULACIÓN DE BATALLA ---
    echo -e "\n${magenta}=== INICIO DE COMBATE: RESOLUCIÓN RÁPZ ===${reset}"

    # 1. Determinar ventaja
    VENTAJA=$(determinar_ventaja "$TU_TIPO" "$RIVAL_TIPO")

    # 2. Mostrar resumen del encuentro
    echo -e "${azul}Lanzando ataque...${reset}"
    sleep 1

    # Ganador por VENTAJA DE TIPO (el mensaje de victoria/derrota instantáneo)
    if [ "$VENTAJA" -eq 1 ]; then
        echo -e "\n${verde}¡Tu $TU_NOMBRE (${TU_TIPO}) supera en tipo al rival! ¡Éxito en el combate!${reset}"
        RIVAL_HP=0
    elif [ "$VENTAJA" -eq -1 ]; then
        echo -e "\n${rojo}¡$RIVAL_NOMBRE (${RIVAL_TIPO}) supera en tipo a tu Pokémon! ¡Tu ataque falla!${reset}"
        TU_HP=0
    else
        # VENTAJA NEUTRA/DUDOSA
        echo -e "\n${amarillo}¡El encuentro es un pulso! El combate se define por tu determinación.${reset}"

        # Resolución por NIVEL
        if [ "$TU_NIVEL" -ge "$RIVAL_NIVEL" ]; then
            echo -e "${verde}¡$TU_NOMBRE se impone por su Nivel (Nv. $TU_NIVEL) y lo debilita!${reset}"
            RIVAL_HP=0
        else
            echo -e "${rojo}El rival $RIVAL_NOMBRE (Nv. $RIVAL_NIVEL) te supera. ¡Has perdido la iniciativa!${reset}"
            TU_HP=0
        fi
    fi

    echo "-----------------------------------"
    echo -e "${azul}Tu $TU_NOMBRE: HP ${verde}$TU_HP/${TU_HP_MAX}${reset}"
    echo -e "${rojo}RIVAL $RIVAL_NOMBRE: HP ${verde}$RIVAL_HP/${RIVAL_HP_MAX}${reset}"
    echo "-----------------------------------"

    # Lógica de CAPTURA (Solo si tu Pokémon NO fue debilitado y el RIVAL SÍ)
    if [ "$RIVAL_HP" -eq 0 ] && [ "$TU_HP" -gt 0 ]; then
        # El Pokémon está DEBILITADO (Mensaje de rol mejorado)
        read -r -p "${verde}¡$RIVAL_NOMBRE está debilitado! ¿Quieres registrar y capturarlo? [s/N]: ${reset}" INTENTO_CAPTURA
        if [[ "$INTENTO_CAPTURA" =~ ^[sS]$ ]]; then
            simular_captura_debilitado "$RIVAL_NIVEL" # Intento de captura con el porcentaje de fallo bajo
            if [ $? -eq 0 ]; then
                registrar_captura "$RIVAL_NUMERO" "$RIVAL_NOMBRE" "$RIVAL_TIPO"
                registrar_avistamiento "$RIVAL_NUMERO" "$RIVAL_NOMBRE" "$RIVAL_TIPO"
            fi
        else
            echo -e "${amarillo}Decidiste no registrar al Pokémon debilitado.${reset}"
        fi
    fi
}

# 11. buscar_pokemon (SOLO REGISTRO DE AVISTAMIENTO)
function buscar_pokemon() {
    echo
    read -r -p "Introduce el nombre o número del Pokémon: " BUSQUEDA

    if [ -z "$BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún valor.${reset}"
        return
    fi

    POKEMON_DATA=$(
        jq -r --arg query "$BUSQUEDA" '
        .pokemons[] |
        select(
            (.numero | tostring) == $query or
            (.nombre | ascii_downcase) == ($query | ascii_downcase)
        )
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$POKEMON_DATA" ]; then
        echo -e "\n${rojo}Error: Pokémon '$BUSQUEDA' no encontrado en la Pokédex.${reset}"
    else
        mapfile -t DATOS <<< "$POKEMON_DATA"
        local NUMERO="${DATOS[0]}"
        local NOMBRE="${DATOS[1]}"
        local TIPO="${DATOS[2]}"

        local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

        echo -e "\n${verde}=== Pokémon encontrado ===${reset}"
        echo "Número: ${NUMERO_FORMATO}"
        echo "Nombre: ${NOMBRE}"
        echo "Tipo: ${TIPO}"
        echo "Nivel: ${DATOS[3]}"
        echo "Descripción: ${DATOS[4]}"
        echo "--------------------------"

        registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
    fi
}

# 12. contar_pokemon
function contar_pokemon() {
    TOTAL_POKEMON=$(jq '.pokemons | length' "$JSON_FILE")
    echo -e "\n${verde}=== RESUMEN DE LA POKÉDEX ===${reset}"
    echo "Total de Pokémon cargados: $TOTAL_POKEMON"
    echo "-----------------------------------"
}

# 13. listar_tipos
function listar_tipos() {
    echo -e "\n${verde}=== TIPOS DE POKÉMON EN LA POKÉDEX ===${reset}"

    jq -r '.pokemons[].tipo' "$JSON_FILE" | \
    tr '/' '\n' | \
    sort -u | \
    while read -r tipo; do
        echo " - $tipo"
    done

    echo "-----------------------------------"
}

# 14. buscar_por_tipo
function buscar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo de Pokémon (ej: Fuego, Dragón): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    RESULTADOS=$(
        jq -r --arg tipo "$TIPO_LOWER" '
        .pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo)) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS PARA TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 15. buscar_por_nivel
function buscar_por_nivel() {
    echo -e "\n${amarillo}=== BÚSQUEDA POR RANGO DE NIVEL ===${reset}"
    read -r -p "Introduce el Nivel Mínimo (ej: 30): " MIN_NIVEL
    read -r -p "Introduce el Nivel Máximo (ej: 40): " MAX_NIVEL

    if [ -z "$MIN_NIVEL" ] || [ -z "$MAX_NIVEL" ]; then
        echo -e "${rojo}Error: Debe introducir un nivel mínimo y máximo.${reset}"
        return
    fi

    if ! [[ "$MIN_NIVEL" =~ ^[0-9]+$ ]] || ! [[ "$MAX_NIVEL" =~ ^[0-9]+$ ]]; then
        echo -e "${rojo}Error: Los niveles deben ser números enteros.${reset}"
        return
    fi

    RESULTADOS=$(
        jq -r --argjson min "$MIN_NIVEL" --argjson max "$MAX_NIVEL" '
        .pokemons[] |
        select((.nivel | tonumber) >= $min and (.nivel | tonumber) <= $max) |
        "Nivel \(.nivel): \(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "Nivel %s: %03d - %s\n", $2, $4, $5}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon entre el Nivel $MIN_NIVEL y $MAX_NIVEL.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS ENTRE NIVEL $MIN_NIVEL y $MAX_NIVEL ===${reset}"
        echo "$RESULTADOS" | sort -n
        echo "------------------------------------------------"
    fi
}

# 16. contar_por_tipo
function contar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo a Contar (ej: Agua): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    TOTAL_TIPO=$(
        jq --arg tipo "$TIPO_LOWER" '
        [.pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo))]
        | length
        ' "$JSON_FILE"
    )

    if [ "$TOTAL_TIPO" -eq 0 ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== CONTEO DEL TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "Hay un total de ${TOTAL_TIPO} Pokémon que contienen el Tipo '$TIPO_BUSQUEDA'."
        echo "------------------------------------------------"
    fi
}

# 17. buscar_por_region
function buscar_por_region() {
    echo -e "\n${amarillo}=== FILTRAR POR REGIÓN/GENERACIÓN ===${reset}"
    echo "Selecciona una Región:"
    echo " 1) Kanto (001-151) "
    echo " 2) Johto (152-251)"
    echo " 3) Hoenn (252-386)"
    echo " 4) Sinnoh (387-493)"
    echo " 5) Teselia (494-649)"
    echo " 6) Kalos (650-721)"
    echo " 7) Alola (722-809)"
    echo " 8) Galar (810-905)"
    echo " 9) Paldea (906-1017)"
    echo "-----------------------------------"
    read -r -p "¿Región [1-9]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    RESULTADOS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon en la Región de $REGION_NOMBRE.${reset}"
    else
        TOTAL_REGION=$(echo "$RESULTADOS" | wc -l)
        echo -e "\n${verde}=== POKÉMON EN LA REGIÓN DE $REGION_NOMBRE (Total: $TOTAL_REGION) ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 18. encontrar_pokemon_aleatorio (USA LA FUNCIÓN DE CAPTURA)
function encontrar_pokemon_aleatorio() {
    echo -e "\n${amarillo}=== BUSCANDO EN LA HIERBA ALTA... ===${reset}"
    echo "Selecciona una Región para buscar:"
    echo " 1) Kanto   2) Johto   3) Hoenn   4) Sinnoh   5) Teselia"
    echo " 6) Kalos   7) Alola   8) Galar   9) Paldea  ${cian}10) CUALQUIER REGIÓN${reset}"
    echo "-----------------------------------"
    read -r -p "¿Región [1-10]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        10) REGION_NOMBRE="Nacional"; MIN=1; MAX=$(jq '.pokemons | length' "$JSON_FILE") ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    POKEMON_IDS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        .numero | tostring
        ' "$JSON_FILE"
    )

    if [ -z "$POKEMON_IDS" ]; then
        echo -e "${rojo}Error: No se encontraron datos para la región $REGION_NOMBRE.${reset}"
        return
    fi

    IDS_ARRAY=($POKEMON_IDS)
    TOTAL_IDS=${#IDS_ARRAY[@]}
    RANDOM_INDEX=$(( RANDOM % TOTAL_IDS ))
    RANDOM_NUMERO=${IDS_ARRAY[$RANDOM_INDEX]}

    POKEMON_DATA=$(
        jq -r --arg query "$RANDOM_NUMERO" '
        .pokemons[] |
        select(.numero | tostring == $query)
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    mapfile -t DATOS <<< "$POKEMON_DATA"
    local NUMERO="${DATOS[0]}"
    local NOMBRE="${DATOS[1]}"
    local TIPO="${DATOS[2]}"
    local NIVEL="${DATOS[3]}"
    local DESCRIPCION="${DATOS[4]}"
    local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

    echo -e "\n${verde}=============================================${reset}"
    echo -e "${verde}¡Un $NOMBRE salvaje apareció! (Nivel: $NIVEL)${reset}"
    echo -e "${verde}=============================================${reset}"
    echo "Número: ${NUMERO_FORMATO}"
    echo "Tipo: ${TIPO}"
    echo "Nivel inicial: ${NIVEL}"
    echo -e "${amarillo}Descripción de la Pokédex:${reset} ${DESCRIPCION}"
    echo "--------------------------------------------------"

    registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"

    simular_escape_inicial "$NIVEL"
    if [ $? -eq 0 ]; then
        return
    fi

    CAPTURA_EXITOSA=1
    INTENTOS=0

    while [ $CAPTURA_EXITOSA -ne 0 ]; do
        INTENTOS=$(( INTENTOS + 1 ))
        read -r -p "¿Intentar Capturar (Intento #$INTENTOS)? [s/N]: " INTENTO_CAPTURAR

        if [[ "$INTENTO_CAPTURAR" =~ ^[sS]$ ]]; then
            simular_captura_ruta "$NIVEL"
            if [ $? -eq 0 ]; then
                CAPTURA_EXITOSA=0
                registrar_captura "$NUMERO" "$NOMBRE" "$TIPO"
                registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
            else
                simular_escape_fallo "$NIVEL"
                if [ $? -eq 0 ]; then
                    echo -e "${rojo}El Pokémon escapó después de liberarse. ¡Fin del encuentro!${reset}"
                    return
                fi
            fi
        else
            echo -e "${amarillo}Decidiste no intentarlo. $NOMBRE regresó a la hierba alta.${reset}"
            return
        fi
    done
}


# 19. ver_pc_bill
function ver_pc_bill() {
    echo -e "\n${azul}=== ACCEDIENDO AL PC DE BILL (POKÉMON CAPTURADOS) ===${reset}"

    if [ -f "$PC_BILL_FILE" ]; then
        TOTAL_REGISTROS=$(wc -l < "$PC_BILL_FILE")
        echo "Total de Pokémon registrados (capturados): $TOTAL_REGISTROS"
        echo -e "\n${amarillo}--- Últimos 10 Pokémon en el PC ---${reset}"
        tail -n 10 "$PC_BILL_FILE"
    else
        echo -e "${rojo}El PC de Bill está vacío. ¡Aún no has capturado ningún Pokémon!${reset}"
    fi
    echo "------------------------------------------------"
}

# 20. liberar_pokemons
function liberar_pokemons() {
    if [ -f "$PC_BILL_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres liberar TODOS los Pokémon del PC de Bill? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$PC_BILL_FILE"
            echo -e "${verde}¡Todos los Pokémon han sido liberados del PC de Bill! Comienza una nueva aventura.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. Los registros del PC de Bill se mantienen.${reset}"
        fi
    else
        echo -e "${amarillo}El PC de Bill ya está vacío. No hay Pokémon que liberar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 21. ver_avistamientos
function ver_avistamientos() {
    echo -e "\n${cian}=== POKÉDEX: REGISTRO DE AVISTAMIENTOS ===${reset}"

    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        TOTAL_AVISTAMIENTOS=$(wc -l < "$AVISTAMIENTOS_FILE")
        echo "Total de Pokémon avistados: $TOTAL_AVISTAMIENTOS"
        echo -e "\n${amarillo}--- Últimos 10 Avistamientos Registrados ---${reset}"
        tail -n 10 "$AVISTAMIENTOS_FILE"
    else
        echo -e "${rojo}El Registro de Avistamientos está vacío. ¡Sal y explora!${reset}"
    fi
    echo "------------------------------------------------"
}

# 22. borrar_avistamientos
function borrar_avistamientos() {
    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres borrar el historial de avistamientos? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$AVISTAMIENTOS_FILE"
            echo -e "${verde}Historial de Avistamientos borrado con éxito. La Pokédex se reinicia.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. El historial se mantiene.${reset}"
        fi
    else
        echo -e "${amarillo}El historial de Avistamientos ya está vacío. No hay nada que borrar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 23. buscar_pokemon (SOLO REGISTRO DE AVISTAMIENTO)
function buscar_pokemon() {
    echo
    read -r -p "Introduce el nombre o número del Pokémon: " BUSQUEDA

    if [ -z "$BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún valor.${reset}"
        return
    fi

    POKEMON_DATA=$(
        jq -r --arg query "$BUSQUEDA" '
        .pokemons[] |
        select(
            (.numero | tostring) == $query or
            (.nombre | ascii_downcase) == ($query | ascii_downcase)
        )
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$POKEMON_DATA" ]; then
        echo -e "\n${rojo}Error: Pokémon '$BUSQUEDA' no encontrado en la Pokédex.${reset}"
    else
        mapfile -t DATOS <<< "$POKEMON_DATA"
        local NUMERO="${DATOS[0]}"
        local NOMBRE="${DATOS[1]}"
        local TIPO="${DATOS[2]}"

        local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

        echo -e "\n${verde}=== Pokémon encontrado ===${reset}"
        echo "Número: ${NUMERO_FORMATO}"
        echo "Nombre: ${NOMBRE}"
        echo "Tipo: ${TIPO}"
        echo "Nivel: ${DATOS[3]}"
        echo "Descripción: ${DATOS[4]}"
        echo "--------------------------"

        registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
    fi
}

# 24. contar_pokemon
function contar_pokemon() {
    TOTAL_POKEMON=$(jq '.pokemons | length' "$JSON_FILE")
    echo -e "\n${verde}=== RESUMEN DE LA POKÉDEX ===${reset}"
    echo "Total de Pokémon cargados: $TOTAL_POKEMON"
    echo "-----------------------------------"
}

# 25. listar_tipos
function listar_tipos() {
    echo -e "\n${verde}=== TIPOS DE POKÉMON EN LA POKÉDEX ===${reset}"

    jq -r '.pokemons[].tipo' "$JSON_FILE" | \
    tr '/' '\n' | \
    sort -u | \
    while read -r tipo; do
        echo " - $tipo"
    done

    echo "-----------------------------------"
}

# 26. buscar_por_tipo
function buscar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo de Pokémon (ej: Fuego, Dragón): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    RESULTADOS=$(
        jq -r --arg tipo "$TIPO_LOWER" '
        .pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo)) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS PARA TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 27. buscar_por_nivel
function buscar_por_nivel() {
    echo -e "\n${amarillo}=== BÚSQUEDA POR RANGO DE NIVEL ===${reset}"
    read -r -p "Introduce el Nivel Mínimo (ej: 30): " MIN_NIVEL
    read -r -p "Introduce el Nivel Máximo (ej: 40): " MAX_NIVEL

    if [ -z "$MIN_NIVEL" ] || [ -z "$MAX_NIVEL" ]; then
        echo -e "${rojo}Error: Debe introducir un nivel mínimo y máximo.${reset}"
        return
    fi

    if ! [[ "$MIN_NIVEL" =~ ^[0-9]+$ ]] || ! [[ "$MAX_NIVEL" =~ ^[0-9]+$ ]]; then
        echo -e "${rojo}Error: Los niveles deben ser números enteros.${reset}"
        return
    fi

    RESULTADOS=$(
        jq -r --argjson min "$MIN_NIVEL" --argjson max "$MAX_NIVEL" '
        .pokemons[] |
        select((.nivel | tonumber) >= $min and (.nivel | tonumber) <= $max) |
        "Nivel \(.nivel): \(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "Nivel %s: %03d - %s\n", $2, $4, $5}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon entre el Nivel $MIN_NIVEL y $MAX_NIVEL.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS ENTRE NIVEL $MIN_NIVEL y $MAX_NIVEL ===${reset}"
        echo "$RESULTADOS" | sort -n
        echo "------------------------------------------------"
    fi
}

# 28. contar_por_tipo
function contar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo a Contar (ej: Agua): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    TOTAL_TIPO=$(
        jq --arg tipo "$TIPO_LOWER" '
        [.pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo))]
        | length
        ' "$JSON_FILE"
    )

    if [ "$TOTAL_TIPO" -eq 0 ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== CONTEO DEL TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "Hay un total de ${TOTAL_TIPO} Pokémon que contienen el Tipo '$TIPO_BUSQUEDA'."
        echo "------------------------------------------------"
    fi
}

# 29. buscar_por_region
function buscar_por_region() {
    echo -e "\n${amarillo}=== FILTRAR POR REGIÓN/GENERACIÓN ===${reset}"
    echo "Selecciona una Región:"
    echo " 1) Kanto (001-151) "
    echo " 2) Johto (152-251)"
    echo " 3) Hoenn (252-386)"
    echo " 4) Sinnoh (387-493)"
    echo " 5) Teselia (494-649)"
    echo " 6) Kalos (650-721)"
    echo " 7) Alola (722-809)"
    echo " 8) Galar (810-905)"
    echo " 9) Paldea (906-1017)"
    echo "-----------------------------------"
    read -r -p "¿Región [1-9]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    RESULTADOS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon en la Región de $REGION_NOMBRE.${reset}"
    else
        TOTAL_REGION=$(echo "$RESULTADOS" | wc -l)
        echo -e "\n${verde}=== POKÉMON EN LA REGIÓN DE $REGION_NOMBRE (Total: $TOTAL_REGION) ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 30. encontrar_pokemon_aleatorio (USA LA FUNCIÓN DE CAPTURA)
function encontrar_pokemon_aleatorio() {
    echo -e "\n${amarillo}=== BUSCANDO EN LA HIERBA ALTA... ===${reset}"
    echo "Selecciona una Región para buscar:"
    echo " 1) Kanto   2) Johto   3) Hoenn   4) Sinnoh   5) Teselia"
    echo " 6) Kalos   7) Alola   8) Galar   9) Paldea  ${cian}10) CUALQUIER REGIÓN${reset}"
    echo "-----------------------------------"
    read -r -p "¿Región [1-10]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        10) REGION_NOMBRE="Nacional"; MIN=1; MAX=$(jq '.pokemons | length' "$JSON_FILE") ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    POKEMON_IDS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        .numero | tostring
        ' "$JSON_FILE"
    )

    if [ -z "$POKEMON_IDS" ]; then
        echo -e "${rojo}Error: No se encontraron datos para la región $REGION_NOMBRE.${reset}"
        return
    fi

    IDS_ARRAY=($POKEMON_IDS)
    TOTAL_IDS=${#IDS_ARRAY[@]}
    RANDOM_INDEX=$(( RANDOM % TOTAL_IDS ))
    RANDOM_NUMERO=${IDS_ARRAY[$RANDOM_INDEX]}

    POKEMON_DATA=$(
        jq -r --arg query "$RANDOM_NUMERO" '
        .pokemons[] |
        select(.numero | tostring == $query)
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    mapfile -t DATOS <<< "$POKEMON_DATA"
    local NUMERO="${DATOS[0]}"
    local NOMBRE="${DATOS[1]}"
    local TIPO="${DATOS[2]}"
    local NIVEL="${DATOS[3]}"
    local DESCRIPCION="${DATOS[4]}"
    local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

    echo -e "\n${verde}=============================================${reset}"
    echo -e "${verde}¡Un $NOMBRE salvaje apareció! (Nivel: $NIVEL)${reset}"
    echo -e "${verde}=============================================${reset}"
    echo "Número: ${NUMERO_FORMATO}"
    echo "Tipo: ${TIPO}"
    echo "Nivel inicial: ${NIVEL}"
    echo -e "${amarillo}Descripción de la Pokédex:${reset} ${DESCRIPCION}"
    echo "--------------------------------------------------"

    registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"

    simular_escape_inicial "$NIVEL"
    if [ $? -eq 0 ]; then
        return
    fi

    CAPTURA_EXITOSA=1
    INTENTOS=0

    while [ $CAPTURA_EXITOSA -ne 0 ]; do
        INTENTOS=$(( INTENTOS + 1 ))
        read -r -p "¿Intentar Capturar (Intento #$INTENTOS)? [s/N]: " INTENTO_CAPTURAR

        if [[ "$INTENTO_CAPTURAR" =~ ^[sS]$ ]]; then
            simular_captura_ruta "$NIVEL"
            if [ $? -eq 0 ]; then
                CAPTURA_EXITOSA=0
                registrar_captura "$NUMERO" "$NOMBRE" "$TIPO"
                registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
            else
                simular_escape_fallo "$NIVEL"
                if [ $? -eq 0 ]; then
                    echo -e "${rojo}El Pokémon escapó después de liberarse. ¡Fin del encuentro!${reset}"
                    return
                fi
            fi
        else
            echo -e "${amarillo}Decidiste no intentarlo. $NOMBRE regresó a la hierba alta.${reset}"
            return
        fi
    done
}


# 31. ver_pc_bill
function ver_pc_bill() {
    echo -e "\n${azul}=== ACCEDIENDO AL PC DE BILL (POKÉMON CAPTURADOS) ===${reset}"

    if [ -f "$PC_BILL_FILE" ]; then
        TOTAL_REGISTROS=$(wc -l < "$PC_BILL_FILE")
        echo "Total de Pokémon registrados (capturados): $TOTAL_REGISTROS"
        echo -e "\n${amarillo}--- Últimos 10 Pokémon en el PC ---${reset}"
        tail -n 10 "$PC_BILL_FILE"
    else
        echo -e "${rojo}El PC de Bill está vacío. ¡Aún no has capturado ningún Pokémon!${reset}"
    fi
    echo "------------------------------------------------"
}

# 32. liberar_pokemons
function liberar_pokemons() {
    if [ -f "$PC_BILL_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres liberar TODOS los Pokémon del PC de Bill? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$PC_BILL_FILE"
            echo -e "${verde}¡Todos los Pokémon han sido liberados del PC de Bill! Comienza una nueva aventura.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. Los registros del PC de Bill se mantienen.${reset}"
        fi
    else
        echo -e "${amarillo}El PC de Bill ya está vacío. No hay Pokémon que liberar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 33. ver_avistamientos
function ver_avistamientos() {
    echo -e "\n${cian}=== POKÉDEX: REGISTRO DE AVISTAMIENTOS ===${reset}"

    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        TOTAL_AVISTAMIENTOS=$(wc -l < "$AVISTAMIENTOS_FILE")
        echo "Total de Pokémon avistados: $TOTAL_AVISTAMIENTOS"
        echo -e "\n${amarillo}--- Últimos 10 Avistamientos Registrados ---${reset}"
        tail -n 10 "$AVISTAMIENTOS_FILE"
    else
        echo -e "${rojo}El Registro de Avistamientos está vacío. ¡Sal y explora!${reset}"
    fi
    echo "-----------------------------------"
}

# 34. borrar_avistamientos
function borrar_avistamientos() {
    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres borrar el historial de avistamientos? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$AVISTAMIENTOS_FILE"
            echo -e "${verde}Historial de Avistamientos borrado con éxito. La Pokédex se reinicia.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. El historial se mantiene.${reset}"
        fi
    else
        echo -e "${amarillo}El historial de Avistamientos ya está vacío. No hay nada que borrar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 35. buscar_pokemon (SOLO REGISTRO DE AVISTAMIENTO)
function buscar_pokemon() {
    echo
    read -r -p "Introduce el nombre o número del Pokémon: " BUSQUEDA

    if [ -z "$BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún valor.${reset}"
        return
    fi

    POKEMON_DATA=$(
        jq -r --arg query "$BUSQUEDA" '
        .pokemons[] |
        select(
            (.numero | tostring) == $query or
            (.nombre | ascii_downcase) == ($query | ascii_downcase)
        )
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$POKEMON_DATA" ]; then
        echo -e "\n${rojo}Error: Pokémon '$BUSQUEDA' no encontrado en la Pokédex.${reset}"
    else
        mapfile -t DATOS <<< "$POKEMON_DATA"
        local NUMERO="${DATOS[0]}"
        local NOMBRE="${DATOS[1]}"
        local TIPO="${DATOS[2]}"

        local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

        echo -e "\n${verde}=== Pokémon encontrado ===${reset}"
        echo "Número: ${NUMERO_FORMATO}"
        echo "Nombre: ${NOMBRE}"
        echo "Tipo: ${TIPO}"
        echo "Nivel: ${DATOS[3]}"
        echo "Descripción: ${DATOS[4]}"
        echo "--------------------------"

        registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
    fi
}

# 36. contar_pokemon
function contar_pokemon() {
    TOTAL_POKEMON=$(jq '.pokemons | length' "$JSON_FILE")
    echo -e "\n${verde}=== RESUMEN DE LA POKÉDEX ===${reset}"
    echo "Total de Pokémon cargados: $TOTAL_POKEMON"
    echo "-----------------------------------"
}

# 37. listar_tipos
function listar_tipos() {
    echo -e "\n${verde}=== TIPOS DE POKÉMON EN LA POKÉDEX ===${reset}"

    jq -r '.pokemons[].tipo' "$JSON_FILE" | \
    tr '/' '\n' | \
    sort -u | \
    while read -r tipo; do
        echo " - $tipo"
    done

    echo "-----------------------------------"
}

# 38. buscar_por_tipo
function buscar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo de Pokémon (ej: Fuego, Dragón): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    RESULTADOS=$(
        jq -r --arg tipo "$TIPO_LOWER" '
        .pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo)) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS PARA TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 39. buscar_por_nivel
function buscar_por_nivel() {
    echo -e "\n${amarillo}=== BÚSQUEDA POR RANGO DE NIVEL ===${reset}"
    read -r -p "Introduce el Nivel Mínimo (ej: 30): " MIN_NIVEL
    read -r -p "Introduce el Nivel Máximo (ej: 40): " MAX_NIVEL

    if [ -z "$MIN_NIVEL" ] || [ -z "$MAX_NIVEL" ]; then
        echo -e "${rojo}Error: Debe introducir un nivel mínimo y máximo.${reset}"
        return
    fi

    if ! [[ "$MIN_NIVEL" =~ ^[0-9]+$ ]] || ! [[ "$MAX_NIVEL" =~ ^[0-9]+$ ]]; then
        echo -e "${rojo}Error: Los niveles deben ser números enteros.${reset}"
        return
    fi

    RESULTADOS=$(
        jq -r --argjson min "$MIN_NIVEL" --argjson max "$MAX_NIVEL" '
        .pokemons[] |
        select((.nivel | tonumber) >= $min and (.nivel | tonumber) <= $max) |
        "Nivel \(.nivel): \(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "Nivel %s: %03d - %s\n", $2, $4, $5}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon entre el Nivel $MIN_NIVEL y $MAX_NIVEL.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS ENTRE NIVEL $MIN_NIVEL y $MAX_NIVEL ===${reset}"
        echo "$RESULTADOS" | sort -n
        echo "------------------------------------------------"
    fi
}

# 40. contar_por_tipo
function contar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo a Contar (ej: Agua): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    TOTAL_TIPO=$(
        jq --arg tipo "$TIPO_LOWER" '
        [.pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo))]
        | length
        ' "$JSON_FILE"
    )

    if [ "$TOTAL_TIPO" -eq 0 ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== CONTEO DEL TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "Hay un total de ${TOTAL_TIPO} Pokémon que contienen el Tipo '$TIPO_BUSQUEDA'."
        echo "-----------------------------------"
    fi
}

# 41. buscar_por_region
function buscar_por_region() {
    echo -e "\n${amarillo}=== FILTRAR POR REGIÓN/GENERACIÓN ===${reset}"
    echo "Selecciona una Región:"
    echo " 1) Kanto (001-151) "
    echo " 2) Johto (152-251)"
    echo " 3) Hoenn (252-386)"
    echo " 4) Sinnoh (387-493)"
    echo " 5) Teselia (494-649)"
    echo " 6) Kalos (650-721)"
    echo " 7) Alola (722-809)"
    echo " 8) Galar (810-905)"
    echo " 9) Paldea (906-1017)"
    echo "-----------------------------------"
    read -r -p "¿Región [1-9]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    RESULTADOS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon en la Región de $REGION_NOMBRE.${reset}"
    else
        TOTAL_REGION=$(echo "$RESULTADOS" | wc -l)
        echo -e "\n${verde}=== POKÉMON EN LA REGIÓN DE $REGION_NOMBRE (Total: $TOTAL_REGION) ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 42. iniciar_combate (LOGICA DE COMBATE ESTABLE)
function iniciar_combate() {
    echo -e "\n${amarillo}=== SELECCIÓN DE TU POKÉMON ===${reset}"
    read -r -p "Introduce el nombre o número de TU Pokémon: " TU_BUSQUEDA

    # 1. Verificar si el Pokémon ha sido capturado previamente (está en el PC)
    if [ ! -f "$PC_BILL_FILE" ] || ! grep -i -E "($TU_BUSQUEDA)" "$PC_BILL_FILE" &> /dev/null; then
        echo -e "\n${rojo}Error: Solo puedes combatir con Pokémon que ya hayas CAPTURADO (Opción 8).${reset}"
        echo -e "${amarillo}El Pokémon '$TU_BUSQUEDA' no se encuentra en el PC de Bill.${reset}"
        return
    fi

    TU_POKEMON_DATA=$(
        jq -r --arg query "$TU_BUSQUEDA" '.pokemons[] | select((.numero | tostring) == $query or (.nombre | ascii_downcase) == ($query | ascii_downcase)) | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$TU_POKEMON_DATA" ]; then
        echo -e "${rojo}Error: Tu Pokémon no se encontró. Vuelve al menú.${reset}"
        return
    fi
    mapfile -t TU_DATOS <<< "$TU_POKEMON_DATA"
    TU_NUM="${TU_DATOS[0]}"; TU_NOMBRE="${TU_DATOS[1]}"; TU_TIPO="${TU_DATOS[2]}"; TU_NIVEL="${TU_DATOS[3]}"

    # --- Generar Pokémon Rival (AHORA ES NACIONAL ALEATORIO) ---
    echo -e "\n${amarillo}=== BUSCANDO RIVAL NACIONAL ALEATORIO... ===${reset}"
    MIN_RIVAL=1; MAX_RIVAL=$(jq '.pokemons | length' "$JSON_FILE")
    RIVAL_IDS=$(jq -r --argjson min "$MIN_RIVAL" --argjson max "$MAX_RIVAL" '.pokemons[] | select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) | .numero | tostring' "$JSON_FILE")
    RIVAL_IDS_ARRAY=($RIVAL_IDS); TOTAL_IDS=${#RIVAL_IDS_ARRAY[@]}
    RIVAL_NUMERO=${RIVAL_IDS_ARRAY[$(( RANDOM % TOTAL_IDS ))]}

    RIVAL_POKEMON_DATA=$(jq -r --arg query "$RIVAL_NUMERO" '.pokemons[] | select(.numero | tostring == $query) | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)"' "$JSON_FILE" 2>/dev/null)
    mapfile -t RIVAL_DATOS <<< "$RIVAL_POKEMON_DATA"
    RIVAL_NOMBRE="${RIVAL_DATOS[1]}"; RIVAL_TIPO="${RIVAL_DATOS[2]}"; RIVAL_NIVEL="${RIVAL_DATOS[3]}"

    # --- Inicializar HP (Salud) ---
    TU_HP=$(( TU_NIVEL * 10 + 50 ))
    RIVAL_HP=$(( RIVAL_NIVEL * 10 + 50 ))
    RIVAL_HP_MAX=$RIVAL_HP
    TU_HP_MAX=$TU_HP

    echo -e "${verde}¡$RIVAL_NOMBRE salvaje apareció! Nivel $RIVAL_NIVEL. ${reset}"
    sleep 1

    # --- SIMULACIÓN DE BATALLA ---
    echo -e "\n${magenta}=== INICIO DE COMBATE: RESOLUCIÓN RÁPZ ===${reset}"

    # 1. Determinar ventaja
    VENTAJA=$(determinar_ventaja "$TU_TIPO" "$RIVAL_TIPO")

    # 2. Mostrar resumen del encuentro
    echo -e "${azul}Lanzando ataque...${reset}"
    sleep 1

    # Ganador por VENTAJA DE TIPO (el mensaje de victoria/derrota instantáneo)
    if [ "$VENTAJA" -eq 1 ]; then
        echo -e "\n${verde}¡Tu $TU_NOMBRE (${TU_TIPO}) supera en tipo al rival! ¡Éxito en el combate!${reset}"
        RIVAL_HP=0
    elif [ "$VENTAJA" -eq -1 ]; then
        echo -e "\n${rojo}¡$RIVAL_NOMBRE (${RIVAL_TIPO}) supera en tipo a tu Pokémon! ¡Tu ataque falla!${reset}"
        TU_HP=0
    else
        # VENTAJA NEUTRA/DUDOSA
        echo -e "\n${amarillo}¡El encuentro es un pulso! El combate se define por tu determinación.${reset}"

        # Resolución por NIVEL
        if [ "$TU_NIVEL" -ge "$RIVAL_NIVEL" ]; then
            echo -e "${verde}¡$TU_NOMBRE se impone por su Nivel (Nv. $TU_NIVEL) y lo debilita!${reset}"
            RIVAL_HP=0
        else
            echo -e "${rojo}El rival $RIVAL_NOMBRE (Nv. $RIVAL_NIVEL) te supera. ¡Has perdido la iniciativa!${reset}"
            TU_HP=0
        fi
    fi

    echo "-----------------------------------"
    echo -e "${azul}Tu $TU_NOMBRE: HP ${verde}$TU_HP/${TU_HP_MAX}${reset}"
    echo -e "${rojo}RIVAL $RIVAL_NOMBRE: HP ${verde}$RIVAL_HP/${RIVAL_HP_MAX}${reset}"
    echo "-----------------------------------"

    # Lógica de CAPTURA (Solo si tu Pokémon NO fue debilitado y el RIVAL SÍ)
    if [ "$RIVAL_HP" -eq 0 ] && [ "$TU_HP" -gt 0 ]; then
        # El Pokémon está DEBILITADO (Mensaje de rol mejorado)
        read -r -p "${verde}¡$RIVAL_NOMBRE está debilitado! ¿Quieres registrar y capturarlo? [s/N]: ${reset}" INTENTO_CAPTURA
        if [[ "$INTENTO_CAPTURA" =~ ^[sS]$ ]]; then
            simular_captura_debilitado "$RIVAL_NIVEL" # Intento de captura con el porcentaje de fallo bajo
            if [ $? -eq 0 ]; then
                registrar_captura "$RIVAL_NUMERO" "$RIVAL_NOMBRE" "$RIVAL_TIPO"
                registrar_avistamiento "$RIVAL_NUMERO" "$RIVAL_NOMBRE" "$RIVAL_TIPO"
            fi
        else
            echo -e "${amarillo}Decidiste no registrar al Pokémon debilitado.${reset}"
        fi
    fi
}

# 43. capturar_legendario (NUEVA FUNCIÓN)
function capturar_legendario() {
    clear
    echo -e "${blanco}==================================================${reset}"
    echo -e "${magenta}         ¡DESAFÍO LEGENDARIO!         ${reset}"
    echo -e "${blanco}==================================================${reset}"

    # 1. Determinar localización y Pokémon (solo los 10 legendarios más importantes)
    declare -A LEGENDARIOS=(
        [1]="Mewtwo" [2]="Lugia" [3]="Ho-Oh" [4]="Rayquaza" [5]="Kyogre"
        [6]="Groudon" [7]="Dialga" [8]="Palkia" [9]="Zekrom" [10]="Reshiram"
    )
    declare -A UBICACIONES=(
        [1]="${blanco}La Cueva del Origen (Hoenn)${reset}"
        [2]="${blanco}Las Cimas Nevadas (Sinnoh)${reset}"
        [3]="${blanco}La Torre Quemada (Johto)${reset}"
        [4]="${blanco}El Centro del Mundo Distorsión (Sinnoh)${reset}"
        [5]="${blanco}El Abismo Submarino (Hoenn)${reset}"
    )

    # Selección aleatoria del legendario
    LEGENDARIO_ID=$(( RANDOM % 10 + 1 ))
    LEGENDARIO_NOMBRE=${LEGENDARIOS[$LEGENDARIO_ID]}
    UBICACION_ID=$(( RANDOM % 5 + 1 ))
    UBICACION=${UBICACIONES[$UBICACION_ID]}

    # Buscar datos del Pokémon Legendario
    POKEMON_DATA=$(
        jq -r --arg name "$LEGENDARIO_NOMBRE" '.pokemons[] | select(.nombre == $name) | "\(.numero)\n\(.tipo)\n\(.nivel)"' "$JSON_FILE"
    )
    mapfile -t DATOS <<< "$POKEMON_DATA"
    local NUMERO=${DATOS[0]}; local TIPO=${DATOS[1]}; local NIVEL=${DATOS[2]}
    local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

    echo -e "${blanco}Has viajado a $UBICACION...${reset}"
    sleep 2
    echo -e "${magenta}¡$LEGENDARIO_NOMBRE ($TIPO) salvaje apareció! Nivel $NIVEL.${reset}"
    echo -e "--------------------------------------------------"

    registrar_avistamiento "$NUMERO" "$LEGENDARIO_NOMBRE" "$TIPO"

    # --- Lógica de Captura Ultra Difícil ---

    # Probabilidad de éxito base: 5% (legendario) + 1% por nivel bajo
    local BASE_EXITO=5
    local BONUS_NIVEL=$(( (100 - NIVEL) / 5 )) # 100-70 = 30; 30/5 = 6.

    local PROBABILIDAD_FINAL=$(( BASE_EXITO + BONUS_NIVEL ))
    if [ $PROBABILIDAD_FINAL -gt 15 ]; then PROBABILIDAD_FINAL=15; fi # Máximo 15%

    echo -e "${amarillo}La probabilidad de capturar a $LEGENDARIO_NOMBRE es muy baja (Máx. $PROBABILIDAD_FINAL%).${reset}"
    sleep 1

    CAPTURA_EXITOSA=1
    INTENTOS=0

    while [ $CAPTURA_EXITOSA -ne 0 ]; do
        INTENTOS=$(( INTENTOS + 1 ))
        read -r -p "¿Intentar Capturar (Intento #$INTENTOS)? [s/N]: " INTENTO_CAPTURAR

        if [[ "$INTENTO_CAPTURAR" =~ ^[sS]$ ]]; then
            local ALEATORIO=$(( RANDOM % 100 + 1 ))

            echo -e "${cian}--- Intentando Captura (Éxito: $PROBABILIDAD_FINAL%) ---${reset}"
            echo -n "Lanzando Poké Ball... "
            sleep 1
            for i in {1..3}; do echo -n ". "; sleep 0.5; done
            echo

            if [[ $ALEATORIO -le $PROBABILIDAD_FINAL ]]; then
                echo -e "${verde}¡CLICK! ¡INCREÍBLE! ¡Has capturado a $LEGENDARIO_NOMBRE!${reset}"
                registrar_captura "$NUMERO" "$LEGENDARIO_NOMBRE" "$TIPO"
                CAPTURA_EXITOSA=0
            else
                echo -e "${rojo}¡El Pokémon se liberó! No se dejó capturar.${reset}"

                # En un legendario, el fallo de captura significa escape inmediato
                echo -e "${rojo}¡$LEGENDARIO_NOMBRE escapó de la batalla!${reset}"
                return
            fi
        else
            echo -e "${amarillo}Decidiste retirarte. $LEGENDARIO_NOMBRE regresó a su lugar de origen.${reset}"
            return
        fi
    done
}


# 31. ver_pc_bill
function ver_pc_bill() {
    echo -e "\n${azul}=== ACCEDIENDO AL PC DE BILL (POKÉMON CAPTURADOS) ===${reset}"

    if [ -f "$PC_BILL_FILE" ]; then
        TOTAL_REGISTROS=$(wc -l < "$PC_BILL_FILE")
        echo "Total de Pokémon registrados (capturados): $TOTAL_REGISTROS"
        echo -e "\n${amarillo}--- Últimos 10 Pokémon en el PC ---${reset}"
        tail -n 10 "$PC_BILL_FILE"
    else
        echo -e "${rojo}El PC de Bill está vacío. ¡Aún no has capturado ningún Pokémon!${reset}"
    fi
    echo "------------------------------------------------"
}

# 32. liberar_pokemons
function liberar_pokemons() {
    if [ -f "$PC_BILL_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres liberar TODOS los Pokémon del PC de Bill? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$PC_BILL_FILE"
            echo -e "${verde}¡Todos los Pokémon han sido liberados del PC de Bill! Comienza una nueva aventura.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. Los registros del PC de Bill se mantienen.${reset}"
        fi
    else
        echo -e "${amarillo}El PC de Bill ya está vacío. No hay Pokémon que liberar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 33. ver_avistamientos
function ver_avistamientos() {
    echo -e "\n${cian}=== POKÉDEX: REGISTRO DE AVISTAMIENTOS ===${reset}"

    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        TOTAL_AVISTAMIENTOS=$(wc -l < "$AVISTAMIENTOS_FILE")
        echo "Total de Pokémon avistados: $TOTAL_AVISTAMIENTOS"
        echo -e "\n${amarillo}--- Últimos 10 Avistamientos Registrados ---${reset}"
        tail -n 10 "$AVISTAMIENTOS_FILE"
    else
        echo -e "${rojo}El Registro de Avistamientos está vacío. ¡Sal y explora!${reset}"
    fi
    echo "------------------------------------------------"
}

# 34. borrar_avistamientos
function borrar_avistamientos() {
    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres borrar el historial de avistamientos? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$AVISTAMIENTOS_FILE"
            echo -e "${verde}Historial de Avistamientos borrado con éxito. La Pokédex se reinicia.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. El historial se mantiene.${reset}"
        fi
    else
        echo -e "${amarillo}El historial de Avistamientos ya está vacío. No hay nada que borrar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 35. buscar_pokemon (SOLO REGISTRO DE AVISTAMIENTO)
function buscar_pokemon() {
    echo
    read -r -p "Introduce el nombre o número del Pokémon: " BUSQUEDA

    if [ -z "$BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún valor.${reset}"
        return
    fi

    POKEMON_DATA=$(
        jq -r --arg query "$BUSQUEDA" '
        .pokemons[] |
        select(
            (.numero | tostring) == $query or
            (.nombre | ascii_downcase) == ($query | ascii_downcase)
        )
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$POKEMON_DATA" ]; then
        echo -e "\n${rojo}Error: Pokémon '$BUSQUEDA' no encontrado en la Pokédex.${reset}"
    else
        mapfile -t DATOS <<< "$POKEMON_DATA"
        local NUMERO="${DATOS[0]}"
        local NOMBRE="${DATOS[1]}"
        local TIPO="${DATOS[2]}"

        local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

        echo -e "\n${verde}=== Pokémon encontrado ===${reset}"
        echo "Número: ${NUMERO_FORMATO}"
        echo "Nombre: ${NOMBRE}"
        echo "Tipo: ${TIPO}"
        echo "Nivel: ${DATOS[3]}"
        echo "Descripción: ${DATOS[4]}"
        echo "--------------------------"

        registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
    fi
}

# 36. contar_pokemon
function contar_pokemon() {
    TOTAL_POKEMON=$(jq '.pokemons | length' "$JSON_FILE")
    echo -e "\n${verde}=== RESUMEN DE LA POKÉDEX ===${reset}"
    echo "Total de Pokémon cargados: $TOTAL_POKEMON"
    echo "-----------------------------------"
}

# 37. listar_tipos
function listar_tipos() {
    echo -e "\n${verde}=== TIPOS DE POKÉMON EN LA POKÉDEX ===${reset}"

    jq -r '.pokemons[].tipo' "$JSON_FILE" | \
    tr '/' '\n' | \
    sort -u | \
    while read -r tipo; do
        echo " - $tipo"
    done

    echo "-----------------------------------"
}

# 38. buscar_por_tipo
function buscar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo de Pokémon (ej: Fuego, Dragón): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    RESULTADOS=$(
        jq -r --arg tipo "$TIPO_LOWER" '
        .pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo)) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS PARA TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 39. buscar_por_nivel
function buscar_por_nivel() {
    echo -e "\n${amarillo}=== BÚSQUEDA POR RANGO DE NIVEL ===${reset}"
    read -r -p "Introduce el Nivel Mínimo (ej: 30): " MIN_NIVEL
    read -r -p "Introduce el Nivel Máximo (ej: 40): " MAX_NIVEL

    if [ -z "$MIN_NIVEL" ] || [ -z "$MAX_NIVEL" ]; then
        echo -e "${rojo}Error: Debe introducir un nivel mínimo y máximo.${reset}"
        return
    fi

    if ! [[ "$MIN_NIVEL" =~ ^[0-9]+$ ]] || ! [[ "$MAX_NIVEL" =~ ^[0-9]+$ ]]; then
        echo -e "${rojo}Error: Los niveles deben ser números enteros.${reset}"
        return
    fi

    RESULTADOS=$(
        jq -r --argjson min "$MIN_NIVEL" --argjson max "$MAX_NIVEL" '
        .pokemons[] |
        select((.nivel | tonumber) >= $min and (.nivel | tonumber) <= $max) |
        "Nivel \(.nivel): \(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "Nivel %s: %03d - %s\n", $2, $4, $5}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon entre el Nivel $MIN_NIVEL y $MAX_NIVEL.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS ENTRE NIVEL $MIN_NIVEL y $MAX_NIVEL ===${reset}"
        echo "$RESULTADOS" | sort -n
        echo "------------------------------------------------"
    fi
}

# 40. contar_por_tipo
function contar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo a Contar (ej: Agua): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    TOTAL_TIPO=$(
        jq --arg tipo "$TIPO_LOWER" '
        [.pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo))]
        | length
        ' "$JSON_FILE"
    )

    if [ "$TOTAL_TIPO" -eq 0 ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== CONTEO DEL TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "Hay un total de ${TOTAL_TIPO} Pokémon que contienen el Tipo '$TIPO_BUSQUEDA'."
        echo "-----------------------------------"
    fi
}

# 41. buscar_por_region
function buscar_por_region() {
    echo -e "\n${amarillo}=== FILTRAR POR REGIÓN/GENERACIÓN ===${reset}"
    echo "Selecciona una Región:"
    echo " 1) Kanto (001-151) "
    echo " 2) Johto (152-251)"
    echo " 3) Hoenn (252-386)"
    echo " 4) Sinnoh (387-493)"
    echo " 5) Teselia (494-649)"
    echo " 6) Kalos (650-721)"
    echo " 7) Alola (722-809)"
    echo " 8) Galar (810-905)"
    echo " 9) Paldea (906-1017)"
    echo "-----------------------------------"
    read -r -p "¿Región [1-9]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    RESULTADOS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon en la Región de $REGION_NOMBRE.${reset}"
    else
        TOTAL_REGION=$(echo "$RESULTADOS" | wc -l)
        echo -e "\n${verde}=== POKÉMON EN LA REGIÓN DE $REGION_NOMBRE (Total: $TOTAL_REGION) ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 44. capturar_legendario
function capturar_legendario() {
    clear
    echo -e "${blanco}==================================================${reset}"
    echo -e "${magenta}         ¡DESAFÍO LEGENDARIO!         ${reset}"
    echo -e "${blanco}==================================================${reset}"

    # 1. Determinar localización y Pokémon (solo los 10 legendarios más importantes)
    declare -A LEGENDARIOS=(
        [1]="Mewtwo" [2]="Lugia" [3]="Ho-Oh" [4]="Rayquaza" [5]="Kyogre"
        [6]="Groudon" [7]="Dialga" [8]="Palkia" [9]="Zekrom" [10]="Reshiram"
    )
    declare -A UBICACIONES=(
        [1]="${blanco}la Cueva del Origen (Hoenn)${reset}"
        [2]="${blanco}las Cimas Nevadas (Sinnoh)${reset}"
        [3]="${blanco}la Torre Quemada (Johto)${reset}"
        [4]="${blanco}el Mundo Distorsión (Sinnoh)${reset}"
        [5]="${blanco}el Abismo Submarino (Hoenn)${reset}"
    )

    # Selección aleatoria del legendario
    LEGENDARIO_ID=$(( RANDOM % 10 + 1 ))
    LEGENDARIO_NOMBRE=${LEGENDARIOS[$LEGENDARIO_ID]}
    UBICACION_ID=$(( RANDOM % 5 + 1 ))
    UBICACION=${UBICACIONES[$UBICACION_ID]}

    # Buscar datos del Pokémon Legendario
    POKEMON_DATA=$(
        jq -r --arg name "$LEGENDARIO_NOMBRE" '.pokemons[] | select(.nombre == $name) | "\(.numero)\n\(.tipo)\n\(.nivel)"' "$JSON_FILE"
    )
    mapfile -t DATOS <<< "$POKEMON_DATA"
    local NUMERO=${DATOS[0]}; local TIPO=${DATOS[1]}; local NIVEL=${DATOS[2]}
    local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

    echo -e "${blanco}Has viajado a $UBICACION...${reset}"
    sleep 2
    echo -e "${magenta}¡$LEGENDARIO_NOMBRE ($TIPO) salvaje apareció! Nivel $NIVEL.${reset}"
    echo -e "--------------------------------------------------"

    registrar_avistamiento "$NUMERO" "$LEGENDARIO_NOMBRE" "$TIPO"

    # --- Lógica de Captura Ultra Difícil ---

    # Probabilidad de éxito base: 5% (legendario) + 1% por nivel bajo
    local BASE_EXITO=5
    local BONUS_NIVEL=$(( (100 - NIVEL) / 5 )) # 100-70 = 30; 30/5 = 6.

    local PROBABILIDAD_FINAL=$(( BASE_EXITO + BONUS_NIVEL ))
    if [ $PROBABILIDAD_FINAL -gt 15 ]; then PROBABILIDAD_FINAL=15; fi # Máximo 15%

    echo -e "${amarillo}La probabilidad de capturar a $LEGENDARIO_NOMBRE es muy baja (Máx. $PROBABILIDAD_FINAL%).${reset}"
    sleep 1

    CAPTURA_EXITOSA=1
    INTENTOS=0

    while [ $CAPTURA_EXITOSA -ne 0 ]; do
        INTENTOS=$(( INTENTOS + 1 ))
        read -r -p "¿Intentar Capturar (Intento #$INTENTOS)? [s/N]: " INTENTO_CAPTURAR

        if [[ "$INTENTO_CAPTURAR" =~ ^[sS]$ ]]; then
            local ALEATORIO=$(( RANDOM % 100 + 1 ))

            echo -e "${cian}--- Intentando Captura (Éxito: $PROBABILIDAD_FINAL%) ---${reset}"
            echo -n "Lanzando Poké Ball... "
            sleep 1
            for i in {1..3}; do echo -n ". "; sleep 0.5; done
            echo

            if [[ $ALEATORIO -le $PROBABILIDAD_FINAL ]]; then
                echo -e "${verde}¡CLICK! ¡INCREÍBLE! ¡Has capturado a $LEGENDARIO_NOMBRE!${reset}"
                registrar_captura "$NUMERO" "$LEGENDARIO_NOMBRE" "$TIPO"
                CAPTURA_EXITOSA=0
            else
                echo -e "${rojo}¡El Pokémon se liberó! No se dejó capturar.${reset}"

                # En un legendario, el fallo de captura significa escape inmediato
                echo -e "${rojo}¡$LEGENDARIO_NOMBRE escapó de la batalla!${reset}"
                return
            fi
        else
            echo -e "${amarillo}Decidiste retirarte. $LEGENDARIO_NOMBRE regresó a su lugar de origen.${reset}"
            return
        fi
    done
}


# 31. ver_pc_bill
function ver_pc_bill() {
    echo -e "\n${azul}=== ACCEDIENDO AL PC DE BILL (POKÉMON CAPTURADOS) ===${reset}"

    if [ -f "$PC_BILL_FILE" ]; then
        TOTAL_REGISTROS=$(wc -l < "$PC_BILL_FILE")
        echo "Total de Pokémon registrados (capturados): $TOTAL_REGISTROS"
        echo -e "\n${amarillo}--- Últimos 10 Pokémon en el PC ---${reset}"
        tail -n 10 "$PC_BILL_FILE"
    else
        echo -e "${rojo}El PC de Bill está vacío. ¡Aún no has capturado ningún Pokémon!${reset}"
    fi
    echo "------------------------------------------------"
}

# 32. liberar_pokemons
function liberar_pokemons() {
    if [ -f "$PC_BILL_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres liberar TODOS los Pokémon del PC de Bill? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$PC_BILL_FILE"
            echo -e "${verde}¡Todos los Pokémon han sido liberados del PC de Bill! Comienza una nueva aventura.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. Los registros del PC de Bill se mantienen.${reset}"
        fi
    else
        echo -e "${amarillo}El PC de Bill ya está vacío. No hay Pokémon que liberar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 33. ver_avistamientos
function ver_avistamientos() {
    echo -e "\n${cian}=== POKÉDEX: REGISTRO DE AVISTAMIENTOS ===${reset}"

    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        TOTAL_AVISTAMIENTOS=$(wc -l < "$AVISTAMIENTOS_FILE")
        echo "Total de Pokémon avistados: $TOTAL_AVISTAMIENTOS"
        echo -e "\n${amarillo}--- Últimos 10 Avistamientos Registrados ---${reset}"
        tail -n 10 "$AVISTAMIENTOS_FILE"
    else
        echo -e "${rojo}El Registro de Avistamientos está vacío. ¡Sal y explora!${reset}"
    fi
    echo "------------------------------------------------"
}

# 34. borrar_avistamientos
function borrar_avistamientos() {
    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres borrar el historial de avistamientos? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$AVISTAMIENTOS_FILE"
            echo -e "${verde}Historial de Avistamientos borrado con éxito. La Pokédex se reinicia.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. El historial se mantiene.${reset}"
        fi
    else
        echo -e "${amarillo}El historial de Avistamientos ya está vacío. No hay nada que borrar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 35. buscar_pokemon (SOLO REGISTRO DE AVISTAMIENTO)
function buscar_pokemon() {
    echo
    read -r -p "Introduce el nombre o número del Pokémon: " BUSQUEDA

    if [ -z "$BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún valor.${reset}"
        return
    fi

    POKEMON_DATA=$(
        jq -r --arg query "$BUSQUEDA" '
        .pokemons[] |
        select(
            (.numero | tostring) == $query or
            (.nombre | ascii_downcase) == ($query | ascii_downcase)
        )
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$POKEMON_DATA" ]; then
        echo -e "\n${rojo}Error: Pokémon '$BUSQUEDA' no encontrado en la Pokédex.${reset}"
    else
        mapfile -t DATOS <<< "$POKEMON_DATA"
        local NUMERO="${DATOS[0]}"
        local NOMBRE="${DATOS[1]}"
        local TIPO="${DATOS[2]}"

        local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

        echo -e "\n${verde}=== Pokémon encontrado ===${reset}"
        echo "Número: ${NUMERO_FORMATO}"
        echo "Nombre: ${NOMBRE}"
        echo "Tipo: ${TIPO}"
        echo "Nivel: ${DATOS[3]}"
        echo "Descripción: ${DATOS[4]}"
        echo "--------------------------"

        registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
    fi
}

# 36. contar_pokemon
function contar_pokemon() {
    TOTAL_POKEMON=$(jq '.pokemons | length' "$JSON_FILE")
    echo -e "\n${verde}=== RESUMEN DE LA POKÉDEX ===${reset}"
    echo "Total de Pokémon cargados: $TOTAL_POKEMON"
    echo "-----------------------------------"
}

# 37. listar_tipos
function listar_tipos() {
    echo -e "\n${verde}=== TIPOS DE POKÉMON EN LA POKÉDEX ===${reset}"

    jq -r '.pokemons[].tipo' "$JSON_FILE" | \
    tr '/' '\n' | \
    sort -u | \
    while read -r tipo; do
        echo " - $tipo"
    done

    echo "-----------------------------------"
}

# 38. buscar_por_tipo
function buscar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo de Pokémon (ej: Fuego, Dragón): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    RESULTADOS=$(
        jq -r --arg tipo "$TIPO_LOWER" '
        .pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo)) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS PARA TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 39. buscar_por_nivel
function buscar_por_nivel() {
    echo -e "\n${amarillo}=== BÚSQUEDA POR RANGO DE NIVEL ===${reset}"
    read -r -p "Introduce el Nivel Mínimo (ej: 30): " MIN_NIVEL
    read -r -p "Introduce el Nivel Máximo (ej: 40): " MAX_NIVEL

    if [ -z "$MIN_NIVEL" ] || [ -z "$MAX_NIVEL" ]; then
        echo -e "${rojo}Error: Debe introducir un nivel mínimo y máximo.${reset}"
        return
    fi

    if ! [[ "$MIN_NIVEL" =~ ^[0-9]+$ ]] || ! [[ "$MAX_NIVEL" =~ ^[0-9]+$ ]]; then
        echo -e "${rojo}Error: Los niveles deben ser números enteros.${reset}"
        return
    fi

    RESULTADOS=$(
        jq -r --argjson min "$MIN_NIVEL" --argjson max "$MAX_NIVEL" '
        .pokemons[] |
        select((.nivel | tonumber) >= $min and (.nivel | tonumber) <= $max) |
        "Nivel \(.nivel): \(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "Nivel %s: %03d - %s\n", $2, $4, $5}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon entre el Nivel $MIN_NIVEL y $MAX_NIVEL.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS ENTRE NIVEL $MIN_NIVEL y $MAX_NIVEL ===${reset}"
        echo "$RESULTADOS" | sort -n
        echo "------------------------------------------------"
    fi
}

# 40. contar_por_tipo
function contar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo a Contar (ej: Agua): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    TOTAL_TIPO=$(
        jq --arg tipo "$TIPO_LOWER" '
        [.pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo))]
        | length
        ' "$JSON_FILE"
    )

    if [ "$TOTAL_TIPO" -eq 0 ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== CONTEO DEL TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "Hay un total de ${TOTAL_TIPO} Pokémon que contienen el Tipo '$TIPO_BUSQUEDA'."
        echo "------------------------------------------------"
    fi
}

# 41. buscar_por_region
function buscar_por_region() {
    echo -e "\n${amarillo}=== FILTRAR POR REGIÓN/GENERACIÓN ===${reset}"
    echo "Selecciona una Región:"
    echo " 1) Kanto (001-151) "
    echo " 2) Johto (152-251)"
    echo " 3) Hoenn (252-386)"
    echo " 4) Sinnoh (387-493)"
    echo " 5) Teselia (494-649)"
    echo " 6) Kalos (650-721)"
    echo " 7) Alola (722-809)"
    echo " 8) Galar (810-905)"
    echo " 9) Paldea (906-1017)"
    echo "-----------------------------------"
    read -r -p "¿Región [1-9]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    RESULTADOS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon en la Región de $REGION_NOMBRE.${reset}"
    else
        TOTAL_REGION=$(echo "$RESULTADOS" | wc -l)
        echo -e "\n${verde}=== POKÉMON EN LA REGIÓN DE $REGION_NOMBRE (Total: $TOTAL_REGION) ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 42. iniciar_combate (LOGICA DE COMBATE ESTABLE)
function iniciar_combate() {
    echo -e "\n${amarillo}=== SELECCIÓN DE TU POKÉMON ===${reset}"
    read -r -p "Introduce el nombre o número de TU Pokémon: " TU_BUSQUEDA

    # 1. Verificar si el Pokémon ha sido capturado previamente (está en el PC)
    if [ ! -f "$PC_BILL_FILE" ] || ! grep -i -E "($TU_BUSQUEDA)" "$PC_BILL_FILE" &> /dev/null; then
        echo -e "\n${rojo}Error: Solo puedes combatir con Pokémon que ya hayas CAPTURADO (Opción 8).${reset}"
        echo -e "${amarillo}El Pokémon '$TU_BUSQUEDA' no se encuentra en el PC de Bill.${reset}"
        return
    fi

    TU_POKEMON_DATA=$(
        jq -r --arg query "$TU_BUSQUEDA" '.pokemons[] | select((.numero | tostring) == $query or (.nombre | ascii_downcase) == ($query | ascii_downcase)) | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$TU_POKEMON_DATA" ]; then
        echo -e "${rojo}Error: Tu Pokémon no se encontró. Vuelve al menú.${reset}"
        return
    fi
    mapfile -t TU_DATOS <<< "$TU_POKEMON_DATA"
    TU_NUM="${TU_DATOS[0]}"; TU_NOMBRE="${TU_DATOS[1]}"; TU_TIPO="${TU_DATOS[2]}"; TU_NIVEL="${TU_DATOS[3]}"

    # --- Generar Pokémon Rival (AHORA ES NACIONAL ALEATORIO) ---
    echo -e "\n${amarillo}=== BUSCANDO RIVAL NACIONAL ALEATORIO... ===${reset}"
    MIN_RIVAL=1; MAX_RIVAL=$(jq '.pokemons | length' "$JSON_FILE")
    RIVAL_IDS=$(jq -r --argjson min "$MIN_RIVAL" --argjson max "$MAX_RIVAL" '.pokemons[] | select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) | .numero | tostring' "$JSON_FILE")
    RIVAL_IDS_ARRAY=($RIVAL_IDS); TOTAL_IDS=${#RIVAL_IDS_ARRAY[@]}
    RIVAL_NUMERO=${RIVAL_IDS_ARRAY[$(( RANDOM % TOTAL_IDS ))]}

    RIVAL_POKEMON_DATA=$(jq -r --arg query "$RIVAL_NUMERO" '.pokemons[] | select(.numero | tostring == $query) | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)"' "$JSON_FILE" 2>/dev/null)
    mapfile -t RIVAL_DATOS <<< "$RIVAL_POKEMON_DATA"
    RIVAL_NOMBRE="${RIVAL_DATOS[1]}"; RIVAL_TIPO="${RIVAL_DATOS[2]}"; RIVAL_NIVEL="${RIVAL_DATOS[3]}"

    # --- Inicializar HP (Salud) ---
    TU_HP=$(( TU_NIVEL * 10 + 50 ))
    RIVAL_HP=$(( RIVAL_NIVEL * 10 + 50 ))
    RIVAL_HP_MAX=$RIVAL_HP
    TU_HP_MAX=$TU_HP

    echo -e "${verde}¡$RIVAL_NOMBRE salvaje apareció! Nivel $RIVAL_NIVEL. ${reset}"
    sleep 1

    # --- SIMULACIÓN DE BATALLA ---
    echo -e "\n${magenta}=== INICIO DE COMBATE: RESOLUCIÓN RÁPZ ===${reset}"

    # 1. Determinar ventaja
    VENTAJA=$(determinar_ventaja "$TU_TIPO" "$RIVAL_TIPO")

    # 2. Mostrar resumen del encuentro
    echo -e "${azul}Lanzando ataque...${reset}"
    sleep 1

    # Ganador por VENTAJA DE TIPO (el mensaje de victoria/derrota instantáneo)
    if [ "$VENTAJA" -eq 1 ]; then
        echo -e "\n${verde}¡Tu $TU_NOMBRE (${TU_TIPO}) supera en tipo al rival! ¡Éxito en el combate!${reset}"
        RIVAL_HP=0
    elif [ "$VENTAJA" -eq -1 ]; then
        echo -e "\n${rojo}¡$RIVAL_NOMBRE (${RIVAL_TIPO}) supera en tipo a tu Pokémon! ¡Tu ataque falla!${reset}"
        TU_HP=0
    else
        # VENTAJA NEUTRA/DUDOSA
        echo -e "\n${amarillo}¡El encuentro es un pulso! El combate se define por tu determinación.${reset}"

        # Resolución por NIVEL
        if [ "$TU_NIVEL" -ge "$RIVAL_NIVEL" ]; then
            echo -e "${verde}¡$TU_NOMBRE se impone por su Nivel (Nv. $TU_NIVEL) y lo debilita!${reset}"
            RIVAL_HP=0
        else
            echo -e "${rojo}El rival $RIVAL_NOMBRE (Nv. $RIVAL_NIVEL) te supera. ¡Has perdido la iniciativa!${reset}"
            TU_HP=0
        fi
    fi

    echo "-----------------------------------"
    echo -e "${azul}Tu $TU_NOMBRE: HP ${verde}$TU_HP/${TU_HP_MAX}${reset}"
    echo -e "${rojo}RIVAL $RIVAL_NOMBRE: HP ${verde}$RIVAL_HP/${RIVAL_HP_MAX}${reset}"
    echo "-----------------------------------"

    # Lógica de CAPTURA (Solo si tu Pokémon NO fue debilitado y el RIVAL SÍ)
    if [ "$RIVAL_HP" -eq 0 ] && [ "$TU_HP" -gt 0 ]; then
        # El Pokémon está DEBILITADO (Mensaje de rol mejorado)
        read -r -p "${verde}¡$RIVAL_NOMBRE está debilitado! ¿Quieres registrar y capturarlo? [s/N]: ${reset}" INTENTO_CAPTURA
        if [[ "$INTENTO_CAPTURA" =~ ^[sS]$ ]]; then
            simular_captura_debilitado "$RIVAL_NIVEL" # Intento de captura con el porcentaje de fallo bajo
            if [ $? -eq 0 ]; then
                registrar_captura "$RIVAL_NUMERO" "$RIVAL_NOMBRE" "$RIVAL_TIPO"
                registrar_avistamiento "$RIVAL_NUMERO" "$RIVAL_NOMBRE" "$RIVAL_TIPO"
            fi
        else
            echo -e "${amarillo}Decidiste no registrar al Pokémon debilitado.${reset}"
        fi
    fi
}

# 43. capturar_legendario (NUEVA FUNCIÓN)
function capturar_legendario() {
    clear
    echo -e "${blanco}==================================================${reset}"
    echo -e "${magenta}         ¡DESAFÍO LEGENDARIO!         ${reset}"
    echo -e "${blanco}==================================================${reset}"

    # 1. Determinar localización y Pokémon (solo los 10 legendarios más importantes)
    declare -A LEGENDARIOS=(
        [1]="Mewtwo" [2]="Lugia" [3]="Ho-Oh" [4]="Rayquaza" [5]="Kyogre"
        [6]="Groudon" [7]="Dialga" [8]="Palkia" [9]="Zekrom" [10]="Reshiram"
    )
    declare -A UBICACIONES=(
        [1]="${blanco}la Cueva del Origen (Hoenn)${reset}"
        [2]="${blanco}las Cimas Nevadas (Sinnoh)${reset}"
        [3]="${blanco}la Torre Quemada (Johto)${reset}"
        [4]="${blanco}el Mundo Distorsión (Sinnoh)${reset}"
        [5]="${blanco}el Abismo Submarino (Hoenn)${reset}"
    )

    # Selección aleatoria del legendario
    LEGENDARIO_ID=$(( RANDOM % 10 + 1 ))
    LEGENDARIO_NOMBRE=${LEGENDARIOS[$LEGENDARIO_ID]}
    UBICACION_ID=$(( RANDOM % 5 + 1 ))
    UBICACION=${UBICACIONES[$UBICACION_ID]}

    # Buscar datos del Pokémon Legendario
    POKEMON_DATA=$(
        jq -r --arg name "$LEGENDARIO_NOMBRE" '.pokemons[] | select(.nombre == $name) | "\(.numero)\n\(.tipo)\n\(.nivel)"' "$JSON_FILE"
    )
    mapfile -t DATOS <<< "$POKEMON_DATA"
    local NUMERO=${DATOS[0]}; local TIPO=${DATOS[1]}; local NIVEL=${DATOS[2]}
    local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

    echo -e "${blanco}Has viajado a $UBICACION...${reset}"
    sleep 2
    echo -e "${magenta}¡$LEGENDARIO_NOMBRE ($TIPO) salvaje apareció! Nivel $NIVEL.${reset}"
    echo -e "--------------------------------------------------"

    registrar_avistamiento "$NUMERO" "$LEGENDARIO_NOMBRE" "$TIPO"

    # --- Lógica de Captura Ultra Difícil ---

    # Probabilidad de éxito base: 5% (legendario) + 1% por nivel bajo
    local BASE_EXITO=5
    local BONUS_NIVEL=$(( (100 - NIVEL) / 5 ))

    local PROBABILIDAD_FINAL=$(( BASE_EXITO + BONUS_NIVEL ))
    if [ $PROBABILIDAD_FINAL -gt 15 ]; then PROBABILIDAD_FINAL=15; fi # Máximo 15%

    echo -e "${amarillo}La probabilidad de capturar a $LEGENDARIO_NOMBRE es muy baja (Máx. $PROBABILIDAD_FINAL%).${reset}"
    sleep 1

    CAPTURA_EXITOSA=1
    INTENTOS=0

    while [ $CAPTURA_EXITOSA -ne 0 ]; do
        INTENTOS=$(( INTENTOS + 1 ))
        read -r -p "¿Intentar Capturar (Intento #$INTENTOS)? [s/N]: " INTENTO_CAPTURAR

        if [[ "$INTENTO_CAPTURAR" =~ ^[sS]$ ]]; then
            local ALEATORIO=$(( RANDOM % 100 + 1 ))

            echo -e "${cian}--- Intentando Captura (Éxito: $PROBABILIDAD_FINAL%) ---${reset}"
            echo -n "Lanzando Poké Ball... "
            sleep 1
            for i in {1..3}; do echo -n ". "; sleep 0.5; done
            echo

            if [[ $ALEATORIO -le $PROBABILIDAD_FINAL ]]; then
                echo -e "${verde}¡CLICK! ¡INCREÍBLE! ¡Has capturado a $LEGENDARIO_NOMBRE!${reset}"
                registrar_captura "$NUMERO" "$LEGENDARIO_NOMBRE" "$TIPO"
                CAPTURA_EXITOSA=0
            else
                echo -e "${rojo}¡El Pokémon se liberó! No se dejó capturar.${reset}"

                # En un legendario, el fallo de captura significa escape inmediato
                echo -e "${rojo}¡$LEGENDARIO_NOMBRE escapó de la batalla!${reset}"
                return
            fi
        else
            echo -e "${amarillo}Decidiste retirarte. $LEGENDARIO_NOMBRE regresó a su lugar de origen.${reset}"
            return
        fi
    done
}


# 31. ver_pc_bill
function ver_pc_bill() {
    echo -e "\n${azul}=== ACCEDIENDO AL PC DE BILL (POKÉMON CAPTURADOS) ===${reset}"

    if [ -f "$PC_BILL_FILE" ]; then
        TOTAL_REGISTROS=$(wc -l < "$PC_BILL_FILE")
        echo "Total de Pokémon registrados (capturados): $TOTAL_REGISTROS"
        echo -e "\n${amarillo}--- Últimos 10 Pokémon en el PC ---${reset}"
        tail -n 10 "$PC_BILL_FILE"
    else
        echo -e "${rojo}El PC de Bill está vacío. ¡Aún no has capturado ningún Pokémon!${reset}"
    fi
    echo "------------------------------------------------"
}

# 32. liberar_pokemons
function liberar_pokemons() {
    if [ -f "$PC_BILL_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres liberar TODOS los Pokémon del PC de Bill? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$PC_BILL_FILE"
            echo -e "${verde}¡Todos los Pokémon han sido liberados del PC de Bill! Comienza una nueva aventura.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. Los registros del PC de Bill se mantienen.${reset}"
        fi
    else
        echo -e "${amarillo}El PC de Bill ya está vacío. No hay Pokémon que liberar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 33. ver_avistamientos
function ver_avistamientos() {
    echo -e "\n${cian}=== POKÉDEX: REGISTRO DE AVISTAMIENTOS ===${reset}"

    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        TOTAL_AVISTAMIENTOS=$(wc -l < "$AVISTAMIENTOS_FILE")
        echo "Total de Pokémon avistados: $TOTAL_AVISTAMIENTOS"
        echo -e "\n${amarillo}--- Últimos 10 Avistamientos Registrados ---${reset}"
        tail -n 10 "$AVISTAMIENTOS_FILE"
    else
        echo -e "${rojo}El Registro de Avistamientos está vacío. ¡Sal y explora!${reset}"
    fi
    echo "------------------------------------------------"
}

# 34. borrar_avistamientos
function borrar_avistamientos() {
    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres borrar el historial de avistamientos? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$AVISTAMIENTOS_FILE"
            echo -e "${verde}Historial de Avistamientos borrado con éxito. La Pokédex se reinicia.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. El historial se mantiene.${reset}"
        fi
    else
        echo -e "${amarillo}El historial de Avistamientos ya está vacío. No hay nada que borrar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 35. buscar_pokemon (SOLO REGISTRO DE AVISTAMIENTO)
function buscar_pokemon() {
    echo
    read -r -p "Introduce el nombre o número del Pokémon: " BUSQUEDA

    if [ -z "$BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún valor.${reset}"
        return
    fi

    POKEMON_DATA=$(
        jq -r --arg query "$BUSQUEDA" '
        .pokemons[] |
        select(
            (.numero | tostring) == $query or
            (.nombre | ascii_downcase) == ($query | ascii_downcase)
        )
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$POKEMON_DATA" ]; then
        echo -e "\n${rojo}Error: Pokémon '$BUSQUEDA' no encontrado en la Pokédex.${reset}"
    else
        mapfile -t DATOS <<< "$POKEMON_DATA"
        local NUMERO="${DATOS[0]}"
        local NOMBRE="${DATOS[1]}"
        local TIPO="${DATOS[2]}"

        local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

        echo -e "\n${verde}=== Pokémon encontrado ===${reset}"
        echo "Número: ${NUMERO_FORMATO}"
        echo "Nombre: ${NOMBRE}"
        echo "Tipo: ${TIPO}"
        echo "Nivel: ${DATOS[3]}"
        echo "Descripción: ${DATOS[4]}"
        echo "--------------------------"

        registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
    fi
}

# 36. contar_pokemon
function contar_pokemon() {
    TOTAL_POKEMON=$(jq '.pokemons | length' "$JSON_FILE")
    echo -e "\n${verde}=== RESUMEN DE LA POKÉDEX ===${reset}"
    echo "Total de Pokémon cargados: $TOTAL_POKEMON"
    echo "-----------------------------------"
}

# 37. listar_tipos
function listar_tipos() {
    echo -e "\n${verde}=== TIPOS DE POKÉMON EN LA POKÉDEX ===${reset}"

    jq -r '.pokemons[].tipo' "$JSON_FILE" | \
    tr '/' '\n' | \
    sort -u | \
    while read -r tipo; do
        echo " - $tipo"
    done

    echo "-----------------------------------"
}

# 38. buscar_por_tipo
function buscar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo de Pokémon (ej: Fuego, Dragón): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    RESULTADOS=$(
        jq -r --arg tipo "$TIPO_LOWER" '
        .pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo)) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS PARA TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 39. buscar_por_nivel
function buscar_por_nivel() {
    echo -e "\n${amarillo}=== BÚSQUEDA POR RANGO DE NIVEL ===${reset}"
    read -r -p "Introduce el Nivel Mínimo (ej: 30): " MIN_NIVEL
    read -r -p "Introduce el Nivel Máximo (ej: 40): " MAX_NIVEL

    if [ -z "$MIN_NIVEL" ] || [ -z "$MAX_NIVEL" ]; then
        echo -e "${rojo}Error: Debe introducir un nivel mínimo y máximo.${reset}"
        return
    fi

    if ! [[ "$MIN_NIVEL" =~ ^[0-9]+$ ]] || ! [[ "$MAX_NIVEL" =~ ^[0-9]+$ ]]; then
        echo -e "${rojo}Error: Los niveles deben ser números enteros.${reset}"
        return
    fi

    RESULTADOS=$(
        jq -r --argjson min "$MIN_NIVEL" --argjson max "$MAX_NIVEL" '
        .pokemons[] |
        select((.nivel | tonumber) >= $min and (.nivel | tonumber) <= $max) |
        "Nivel \(.nivel): \(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "Nivel %s: %03d - %s\n", $2, $4, $5}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon entre el Nivel $MIN_NIVEL y $MAX_NIVEL.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS ENTRE NIVEL $MIN_NIVEL y $MAX_NIVEL ===${reset}"
        echo "$RESULTADOS" | sort -n
        echo "------------------------------------------------"
    fi
}

# 40. contar_por_tipo
function contar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo a Contar (ej: Agua): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    TOTAL_TIPO=$(
        jq --arg tipo "$TIPO_LOWER" '
        [.pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo))]
        | length
        ' "$JSON_FILE"
    )

    if [ "$TOTAL_TIPO" -eq 0 ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== CONTEO DEL TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "Hay un total de ${TOTAL_TIPO} Pokémon que contienen el Tipo '$TIPO_BUSQUEDA'."
        echo "------------------------------------------------"
    fi
}

# 41. buscar_por_region
function buscar_por_region() {
    echo -e "\n${amarillo}=== FILTRAR POR REGIÓN/GENERACIÓN ===${reset}"
    echo "Selecciona una Región:"
    echo " 1) Kanto (001-151) "
    echo " 2) Johto (152-251)"
    echo " 3) Hoenn (252-386)"
    echo " 4) Sinnoh (387-493)"
    echo " 5) Teselia (494-649)"
    echo " 6) Kalos (650-721)"
    echo " 7) Alola (722-809)"
    echo " 8) Galar (810-905)"
    echo " 9) Paldea (906-1017)"
    echo "-----------------------------------"
    read -r -p "¿Región [1-9]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    RESULTADOS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon en la Región de $REGION_NOMBRE.${reset}"
    else
        TOTAL_REGION=$(echo "$RESULTADOS" | wc -l)
        echo -e "\n${verde}=== POKÉMON EN LA REGIÓN DE $REGION_NOMBRE (Total: $TOTAL_REGION) ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 42. iniciar_combate (LOGICA DE COMBATE ESTABLE)
function iniciar_combate() {
    echo -e "\n${amarillo}=== SELECCIÓN DE TU POKÉMON ===${reset}"
    read -r -p "Introduce el nombre o número de TU Pokémon: " TU_BUSQUEDA

    # 1. Verificar si el Pokémon ha sido capturado previamente (está en el PC)
    if [ ! -f "$PC_BILL_FILE" ] || ! grep -i -E "($TU_BUSQUEDA)" "$PC_BILL_FILE" &> /dev/null; then
        echo -e "\n${rojo}Error: Solo puedes combatir con Pokémon que ya hayas CAPTURADO (Opción 8).${reset}"
        echo -e "${amarillo}El Pokémon '$TU_BUSQUEDA' no se encuentra en el PC de Bill.${reset}"
        return
    fi

    TU_POKEMON_DATA=$(
        jq -r --arg query "$TU_BUSQUEDA" '.pokemons[] | select((.numero | tostring) == $query or (.nombre | ascii_downcase) == ($query | ascii_downcase)) | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$TU_POKEMON_DATA" ]; then
        echo -e "${rojo}Error: Tu Pokémon no se encontró. Vuelve al menú.${reset}"
        return
    fi
    mapfile -t TU_DATOS <<< "$TU_POKEMON_DATA"
    TU_NUM="${TU_DATOS[0]}"; TU_NOMBRE="${TU_DATOS[1]}"; TU_TIPO="${TU_DATOS[2]}"; TU_NIVEL="${TU_DATOS[3]}"

    # --- Generar Pokémon Rival (AHORA ES NACIONAL ALEATORIO) ---
    echo -e "\n${amarillo}=== BUSCANDO RIVAL NACIONAL ALEATORIO... ===${reset}"
    MIN_RIVAL=1; MAX_RIVAL=$(jq '.pokemons | length' "$JSON_FILE")
    RIVAL_IDS=$(jq -r --argjson min "$MIN_RIVAL" --argjson max "$MAX_RIVAL" '.pokemons[] | select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) | .numero | tostring' "$JSON_FILE")
    RIVAL_IDS_ARRAY=($RIVAL_IDS); TOTAL_IDS=${#RIVAL_IDS_ARRAY[@]}
    RIVAL_NUMERO=${RIVAL_IDS_ARRAY[$(( RANDOM % TOTAL_IDS ))]}

    RIVAL_POKEMON_DATA=$(jq -r --arg query "$RIVAL_NUMERO" '.pokemons[] | select(.numero | tostring == $query) | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)"' "$JSON_FILE" 2>/dev/null)
    mapfile -t RIVAL_DATOS <<< "$RIVAL_POKEMON_DATA"
    RIVAL_NOMBRE="${RIVAL_DATOS[1]}"; RIVAL_TIPO="${RIVAL_DATOS[2]}"; RIVAL_NIVEL="${RIVAL_DATOS[3]}"

    # --- Inicializar HP (Salud) ---
    TU_HP=$(( TU_NIVEL * 10 + 50 ))
    RIVAL_HP=$(( RIVAL_NIVEL * 10 + 50 ))
    RIVAL_HP_MAX=$RIVAL_HP
    TU_HP_MAX=$TU_HP

    echo -e "${verde}¡$RIVAL_NOMBRE salvaje apareció! Nivel $RIVAL_NIVEL. ${reset}"
    sleep 1

    # --- SIMULACIÓN DE BATALLA ---
    echo -e "\n${magenta}=== INICIO DE COMBATE: RESOLUCIÓN RÁPZ ===${reset}"

    # 1. Determinar ventaja
    VENTAJA=$(determinar_ventaja "$TU_TIPO" "$RIVAL_TIPO")

    # 2. Mostrar resumen del encuentro
    echo -e "${azul}Lanzando ataque...${reset}"
    sleep 1

    # Ganador por VENTAJA DE TIPO (el mensaje de victoria/derrota instantáneo)
    if [ "$VENTAJA" -eq 1 ]; then
        echo -e "\n${verde}¡Tu $TU_NOMBRE (${TU_TIPO}) supera en tipo al rival! ¡Éxito en el combate!${reset}"
        RIVAL_HP=0
    elif [ "$VENTAJA" -eq -1 ]; then
        echo -e "\n${rojo}¡$RIVAL_NOMBRE (${RIVAL_TIPO}) supera en tipo a tu Pokémon! ¡Tu ataque falla!${reset}"
        TU_HP=0
    else
        # VENTAJA NEUTRA/DUDOSA
        echo -e "\n${amarillo}¡El encuentro es un pulso! El combate se define por tu determinación.${reset}"

        # Resolución por NIVEL
        if [ "$TU_NIVEL" -ge "$RIVAL_NIVEL" ]; then
            echo -e "${verde}¡$TU_NOMBRE se impone por su Nivel (Nv. $TU_NIVEL) y lo debilita!${reset}"
            RIVAL_HP=0
        else
            echo -e "${rojo}El rival $RIVAL_NOMBRE (Nv. $RIVAL_NIVEL) te supera. ¡Has perdido la iniciativa!${reset}"
            TU_HP=0
        fi
    fi

    echo "-----------------------------------"
    echo -e "${azul}Tu $TU_NOMBRE: HP ${verde}$TU_HP/${TU_HP_MAX}${reset}"
    echo -e "${rojo}RIVAL $RIVAL_NOMBRE: HP ${verde}$RIVAL_HP/${RIVAL_HP_MAX}${reset}"
    echo "-----------------------------------"

    # Lógica de CAPTURA (Solo si tu Pokémon NO fue debilitado y el RIVAL SÍ)
    if [ "$RIVAL_HP" -eq 0 ] && [ "$TU_HP" -gt 0 ]; then
        # El Pokémon está DEBILITADO (Mensaje de rol mejorado)
        read -r -p "${verde}¡$RIVAL_NOMBRE está debilitado! ¿Quieres registrar y capturarlo? [s/N]: ${reset}" INTENTO_CAPTURA
        if [[ "$INTENTO_CAPTURA" =~ ^[sS]$ ]]; then
            simular_captura_debilitado "$RIVAL_NIVEL" # Intento de captura con el porcentaje de fallo bajo
            if [ $? -eq 0 ]; then
                registrar_captura "$RIVAL_NUMERO" "$RIVAL_NOMBRE" "$RIVAL_TIPO"
                registrar_avistamiento "$RIVAL_NUMERO" "$RIVAL_NOMBRE" "$RIVAL_TIPO"
            fi
        else
            echo -e "${amarillo}Decidiste no registrar al Pokémon debilitado.${reset}"
        fi
    fi
}

# 43. capturar_legendario (NUEVA FUNCIÓN)
function capturar_legendario() {
    clear
    echo -e "${blanco}==================================================${reset}"
    echo -e "${magenta}         ¡DESAFÍO LEGENDARIO!         ${reset}"
    echo -e "${blanco}==================================================${reset}"

    # 1. Determinar localización y Pokémon (solo los 10 legendarios más importantes)
    declare -A LEGENDARIOS=(
        [1]="Mewtwo" [2]="Lugia" [3]="Ho-Oh" [4]="Rayquaza" [5]="Kyogre"
        [6]="Groudon" [7]="Dialga" [8]="Palkia" [9]="Zekrom" [10]="Reshiram"
    )
    declare -A UBICACIONES=(
        [1]="${blanco}la Cueva del Origen (Hoenn)${reset}"
        [2]="${blanco}las Cimas Nevadas (Sinnoh)${reset}"
        [3]="${blanco}la Torre Quemada (Johto)${reset}"
        [4]="${blanco}el Mundo Distorsión (Sinnoh)${reset}"
        [5]="${blanco}el Abismo Submarino (Hoenn)${reset}"
    )

    # Selección aleatoria del legendario
    LEGENDARIO_ID=$(( RANDOM % 10 + 1 ))
    LEGENDARIO_NOMBRE=${LEGENDARIOS[$LEGENDARIO_ID]}
    UBICACION_ID=$(( RANDOM % 5 + 1 ))
    UBICACION=${UBICACIONES[$UBICACION_ID]}

    # Buscar datos del Pokémon Legendario
    POKEMON_DATA=$(
        jq -r --arg name "$LEGENDARIO_NOMBRE" '.pokemons[] | select(.nombre == $name) | "\(.numero)\n\(.tipo)\n\(.nivel)"' "$JSON_FILE"
    )
    mapfile -t DATOS <<< "$POKEMON_DATA"
    local NUMERO=${DATOS[0]}; local TIPO=${DATOS[1]}; local NIVEL=${DATOS[2]}
    local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

    echo -e "${blanco}Has viajado a $UBICACION...${reset}"
    sleep 2
    echo -e "${magenta}¡$LEGENDARIO_NOMBRE ($TIPO) salvaje apareció! Nivel $NIVEL.${reset}"
    echo -e "--------------------------------------------------"

    registrar_avistamiento "$NUMERO" "$LEGENDARIO_NOMBRE" "$TIPO"

    # --- Lógica de Captura Ultra Difícil ---

    # Probabilidad de éxito base: 5% (legendario) + 1% por nivel bajo
    local BASE_EXITO=5
    local BONUS_NIVEL=$(( (100 - NIVEL) / 5 ))

    local PROBABILIDAD_FINAL=$(( BASE_EXITO + BONUS_NIVEL ))
    if [ $PROBABILIDAD_FINAL -gt 15 ]; then PROBABILIDAD_FINAL=15; fi # Máximo 15%

    echo -e "${amarillo}La probabilidad de capturar a $LEGENDARIO_NOMBRE es muy baja (Máx. $PROBABILIDAD_FINAL%).${reset}"
    sleep 1

    CAPTURA_EXITOSA=1
    INTENTOS=0

    while [ $CAPTURA_EXITOSA -ne 0 ]; do
        INTENTOS=$(( INTENTOS + 1 ))
        read -r -p "¿Intentar Capturar (Intento #$INTENTOS)? [s/N]: " INTENTO_CAPTURAR

        if [[ "$INTENTO_CAPTURAR" =~ ^[sS]$ ]]; then
            local ALEATORIO=$(( RANDOM % 100 + 1 ))

            echo -e "${cian}--- Intentando Captura (Éxito: $PROBABILIDAD_FINAL%) ---${reset}"
            echo -n "Lanzando Poké Ball... "
            sleep 1
            for i in {1..3}; do echo -n ". "; sleep 0.5; done
            echo

            if [[ $ALEATORIO -le $PROBABILIDAD_FINAL ]]; then
                echo -e "${verde}¡CLICK! ¡INCREÍBLE! ¡Has capturado a $LEGENDARIO_NOMBRE!${reset}"
                registrar_captura "$NUMERO" "$LEGENDARIO_NOMBRE" "$TIPO"
                CAPTURA_EXITOSA=0
            else
                echo -e "${rojo}¡El Pokémon se liberó! No se dejó capturar.${reset}"

                # En un legendario, el fallo de captura significa escape inmediato
                echo -e "${rojo}¡$LEGENDARIO_NOMBRE escapó de la batalla!${reset}"
                return
            fi
        else
            echo -e "${amarillo}Decidiste retirarte. $LEGENDARIO_NOMBRE regresó a su lugar de origen.${reset}"
            return
        fi
    done
}


# 31. ver_pc_bill
function ver_pc_bill() {
    echo -e "\n${azul}=== ACCEDIENDO AL PC DE BILL (POKÉMON CAPTURADOS) ===${reset}"

    if [ -f "$PC_BILL_FILE" ]; then
        TOTAL_REGISTROS=$(wc -l < "$PC_BILL_FILE")
        echo "Total de Pokémon registrados (capturados): $TOTAL_REGISTROS"
        echo -e "\n${amarillo}--- Últimos 10 Pokémon en el PC ---${reset}"
        tail -n 10 "$PC_BILL_FILE"
    else
        echo -e "${rojo}El PC de Bill está vacío. ¡Aún no has capturado ningún Pokémon!${reset}"
    fi
    echo "------------------------------------------------"
}

# 32. liberar_pokemons
function liberar_pokemons() {
    if [ -f "$PC_BILL_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres liberar TODOS los Pokémon del PC de Bill? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$PC_BILL_FILE"
            echo -e "${verde}¡Todos los Pokémon han sido liberados del PC de Bill! Comienza una nueva aventura.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. Los registros del PC de Bill se mantienen.${reset}"
        fi
    else
        echo -e "${amarillo}El PC de Bill ya está vacío. No hay Pokémon que liberar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 33. ver_avistamientos
function ver_avistamientos() {
    echo -e "\n${cian}=== POKÉDEX: REGISTRO DE AVISTAMIENTOS ===${reset}"

    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        TOTAL_AVISTAMIENTOS=$(wc -l < "$AVISTAMIENTOS_FILE")
        echo "Total de Pokémon avistados: $TOTAL_AVISTAMIENTOS"
        echo -e "\n${amarillo}--- Últimos 10 Avistamientos Registrados ---${reset}"
        tail -n 10 "$AVISTAMIENTOS_FILE"
    else
        echo -e "${rojo}El Registro de Avistamientos está vacío. ¡Sal y explora!${reset}"
    fi
    echo "------------------------------------------------"
}

# 34. borrar_avistamientos
function borrar_avistamientos() {
    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres borrar el historial de avistamientos? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$AVISTAMIENTOS_FILE"
            echo -e "${verde}Historial de Avistamientos borrado con éxito. La Pokédex se reinicia.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. El historial se mantiene.${reset}"
        fi
    else
        echo -e "${amarillo}El historial de Avistamientos ya está vacío. No hay nada que borrar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 35. buscar_pokemon (SOLO REGISTRO DE AVISTAMIENTO)
function buscar_pokemon() {
    echo
    read -r -p "Introduce el nombre o número del Pokémon: " BUSQUEDA

    if [ -z "$BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún valor.${reset}"
        return
    fi

    POKEMON_DATA=$(
        jq -r --arg query "$BUSQUEDA" '
        .pokemons[] |
        select(
            (.numero | tostring) == $query or
            (.nombre | ascii_downcase) == ($query | ascii_downcase)
        )
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$POKEMON_DATA" ]; then
        echo -e "\n${rojo}Error: Pokémon '$BUSQUEDA' no encontrado en la Pokédex.${reset}"
    else
        mapfile -t DATOS <<< "$POKEMON_DATA"
        local NUMERO="${DATOS[0]}"
        local NOMBRE="${DATOS[1]}"
        local TIPO="${DATOS[2]}"

        local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

        echo -e "\n${verde}=== Pokémon encontrado ===${reset}"
        echo "Número: ${NUMERO_FORMATO}"
        echo "Nombre: ${NOMBRE}"
        echo "Tipo: ${TIPO}"
        echo "Nivel: ${DATOS[3]}"
        echo "Descripción: ${DATOS[4]}"
        echo "--------------------------"

        registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
    fi
}

# 36. contar_pokemon
function contar_pokemon() {
    TOTAL_POKEMON=$(jq '.pokemons | length' "$JSON_FILE")
    echo -e "\n${verde}=== RESUMEN DE LA POKÉDEX ===${reset}"
    echo "Total de Pokémon cargados: $TOTAL_POKEMON"
    echo "-----------------------------------"
}

# 37. listar_tipos
function listar_tipos() {
    echo -e "\n${verde}=== TIPOS DE POKÉMON EN LA POKÉDEX ===${reset}"

    jq -r '.pokemons[].tipo' "$JSON_FILE" | \
    tr '/' '\n' | \
    sort -u | \
    while read -r tipo; do
        echo " - $tipo"
    done

    echo "-----------------------------------"
}

# 38. buscar_por_tipo
function buscar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo de Pokémon (ej: Fuego, Dragón): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    RESULTADOS=$(
        jq -r --arg tipo "$TIPO_LOWER" '
        .pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo)) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS PARA TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 39. buscar_por_nivel
function buscar_por_nivel() {
    echo -e "\n${amarillo}=== BÚSQUEDA POR RANGO DE NIVEL ===${reset}"
    read -r -p "Introduce el Nivel Mínimo (ej: 30): " MIN_NIVEL
    read -r -p "Introduce el Nivel Máximo (ej: 40): " MAX_NIVEL

    if [ -z "$MIN_NIVEL" ] || [ -z "$MAX_NIVEL" ]; then
        echo -e "${rojo}Error: Debe introducir un nivel mínimo y máximo.${reset}"
        return
    fi

    if ! [[ "$MIN_NIVEL" =~ ^[0-9]+$ ]] || ! [[ "$MAX_NIVEL" =~ ^[0-9]+$ ]]; then
        echo -e "${rojo}Error: Los niveles deben ser números enteros.${reset}"
        return
    fi

    RESULTADOS=$(
        jq -r --argjson min "$MIN_NIVEL" --argjson max "$MAX_NIVEL" '
        .pokemons[] |
        select((.nivel | tonumber) >= $min and (.nivel | tonumber) <= $max) |
        "Nivel \(.nivel): \(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "Nivel %s: %03d - %s\n", $2, $4, $5}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon entre el Nivel $MIN_NIVEL y $MAX_NIVEL.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS ENTRE NIVEL $MIN_NIVEL y $MAX_NIVEL ===${reset}"
        echo "$RESULTADOS" | sort -n
        echo "------------------------------------------------"
    fi
}

# 40. contar_por_tipo
function contar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo a Contar (ej: Agua): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    TOTAL_TIPO=$(
        jq --arg tipo "$TIPO_LOWER" '
        [.pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo))]
        | length
        ' "$JSON_FILE"
    )

    if [ "$TOTAL_TIPO" -eq 0 ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== CONTEO DEL TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "Hay un total de ${TOTAL_TIPO} Pokémon que contienen el Tipo '$TIPO_BUSQUEDA'."
        echo "------------------------------------------------"
    fi
}

# 41. buscar_por_region
function buscar_por_region() {
    echo -e "\n${amarillo}=== FILTRAR POR REGIÓN/GENERACIÓN ===${reset}"
    echo "Selecciona una Región:"
    echo " 1) Kanto (001-151) "
    echo " 2) Johto (152-251)"
    echo " 3) Hoenn (252-386)"
    echo " 4) Sinnoh (387-493)"
    echo " 5) Teselia (494-649)"
    echo " 6) Kalos (650-721)"
    echo " 7) Alola (722-809)"
    echo " 8) Galar (810-905)"
    echo " 9) Paldea (906-1017)"
    echo "-----------------------------------"
    read -r -p "¿Región [1-9]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    RESULTADOS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon en la Región de $REGION_NOMBRE.${reset}"
    else
        TOTAL_REGION=$(echo "$RESULTADOS" | wc -l)
        echo -e "\n${verde}=== POKÉMON EN LA REGIÓN DE $REGION_NOMBRE (Total: $TOTAL_REGION) ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 44. encontrar_pokemon_aleatorio (USA LA FUNCIÓN DE CAPTURA)
function encontrar_pokemon_aleatorio() {
    echo -e "\n${amarillo}=== BUSCANDO EN LA HIERBA ALTA... ===${reset}"
    echo "Selecciona una Región para buscar:"
    echo " 1) Kanto   2) Johto   3) Hoenn   4) Sinnoh   5) Teselia"
    echo " 6) Kalos   7) Alola   8) Galar   9) Paldea  ${cian}10) CUALQUIER REGIÓN${reset}"
    echo "-----------------------------------"
    read -r -p "¿Región [1-10]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        10) REGION_NOMBRE="Nacional"; MIN=1; MAX=$(jq '.pokemons | length' "$JSON_FILE") ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    POKEMON_IDS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        .numero | tostring
        ' "$JSON_FILE"
    )

    if [ -z "$POKEMON_IDS" ]; then
        echo -e "${rojo}Error: No se encontraron datos para la región $REGION_NOMBRE.${reset}"
        return
    fi

    IDS_ARRAY=($POKEMON_IDS)
    TOTAL_IDS=${#IDS_ARRAY[@]}
    RANDOM_INDEX=$(( RANDOM % TOTAL_IDS ))
    RANDOM_NUMERO=${IDS_ARRAY[$RANDOM_INDEX]}

    POKEMON_DATA=$(
        jq -r --arg query "$RANDOM_NUMERO" '
        .pokemons[] |
        select(.numero | tostring == $query)
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    mapfile -t DATOS <<< "$POKEMON_DATA"
    local NUMERO="${DATOS[0]}"
    local NOMBRE="${DATOS[1]}"
    local TIPO="${DATOS[2]}"
    local NIVEL="${DATOS[3]}"
    local DESCRIPCION="${DATOS[4]}"
    local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

    echo -e "\n${verde}=============================================${reset}"
    echo -e "${verde}¡Un $NOMBRE salvaje apareció! (Nivel: $NIVEL)${reset}"
    echo -e "${verde}=============================================${reset}"
    echo "Número: ${NUMERO_FORMATO}"
    echo "Tipo: ${TIPO}"
    echo "Nivel inicial: ${NIVEL}"
    echo -e "${amarillo}Descripción de la Pokédex:${reset} ${DESCRIPCION}"
    echo "--------------------------------------------------"

    registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"

    simular_escape_inicial "$NIVEL"
    if [ $? -eq 0 ]; then
        return
    fi

    CAPTURA_EXITOSA=1
    INTENTOS=0

    while [ $CAPTURA_EXITOSA -ne 0 ]; do
        INTENTOS=$(( INTENTOS + 1 ))
        read -r -p "¿Intentar Capturar (Intento #$INTENTOS)? [s/N]: " INTENTO_CAPTURAR

        if [[ "$INTENTO_CAPTURAR" =~ ^[sS]$ ]]; then
            simular_captura_ruta "$NIVEL"
            if [ $? -eq 0 ]; then
                CAPTURA_EXITOSA=0
                registrar_captura "$NUMERO" "$NOMBRE" "$TIPO"
                registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
            else
                simular_escape_fallo "$NIVEL"
                if [ $? -eq 0 ]; then
                    echo -e "${rojo}El Pokémon escapó después de liberarse. ¡Fin del encuentro!${reset}"
                    return
                fi
            fi
        else
            echo -e "${amarillo}Decidiste no intentarlo. $NOMBRE regresó a la hierba alta.${reset}"
            return
        fi
    done
}


# 45. ver_pc_bill
function ver_pc_bill() {
    echo -e "\n${azul}=== ACCEDIENDO AL PC DE BILL (POKÉMON CAPTURADOS) ===${reset}"

    if [ -f "$PC_BILL_FILE" ]; then
        TOTAL_REGISTROS=$(wc -l < "$PC_BILL_FILE")
        echo "Total de Pokémon registrados (capturados): $TOTAL_REGISTROS"
        echo -e "\n${amarillo}--- Últimos 10 Pokémon en el PC ---${reset}"
        tail -n 10 "$PC_BILL_FILE"
    else
        echo -e "${rojo}El PC de Bill está vacío. ¡Aún no has capturado ningún Pokémon!${reset}"
    fi
    echo "------------------------------------------------"
}

# 46. liberar_pokemons
function liberar_pokemons() {
    if [ -f "$PC_BILL_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres liberar TODOS los Pokémon del PC de Bill? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$PC_BILL_FILE"
            echo -e "${verde}¡Todos los Pokémon han sido liberados del PC de Bill! Comienza una nueva aventura.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. Los registros del PC de Bill se mantienen.${reset}"
        fi
    else
        echo -e "${amarillo}El PC de Bill ya está vacío. No hay Pokémon que liberar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 47. ver_avistamientos
function ver_avistamientos() {
    echo -e "\n${cian}=== POKÉDEX: REGISTRO DE AVISTAMIENTOS ===${reset}"

    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        TOTAL_AVISTAMIENTOS=$(wc -l < "$AVISTAMIENTOS_FILE")
        echo "Total de Pokémon avistados: $TOTAL_AVISTAMIENTOS"
        echo -e "\n${amarillo}--- Últimos 10 Avistamientos Registrados ---${reset}"
        tail -n 10 "$AVISTAMIENTOS_FILE"
    else
        echo -e "${rojo}El Registro de Avistamientos está vacío. ¡Sal y explora!${reset}"
    fi
    echo "------------------------------------------------"
}

# 48. borrar_avistamientos
function borrar_avistamientos() {
    if [ -f "$AVISTAMIENTOS_FILE" ]; then
        read -r -p "${rojo}ADVERTENCIA: ¿Estás seguro de que quieres borrar el historial de avistamientos? [s/N]: ${reset}" CONFIRMACION
        if [[ "$CONFIRMACION" =~ ^[sS]$ ]]; then
            rm "$AVISTAMIENTOS_FILE"
            echo -e "${verde}Historial de Avistamientos borrado con éxito. La Pokédex se reinicia.${reset}"
        else
            echo -e "${amarillo}Operación cancelada. El historial se mantiene.${reset}"
        fi
    else
        echo -e "${amarillo}El historial de Avistamientos ya está vacío. No hay nada que borrar.${reset}"
    fi
    echo "------------------------------------------------"
}

# 49. buscar_pokemon (SOLO REGISTRO DE AVISTAMIENTO)
function buscar_pokemon() {
    echo
    read -r -p "Introduce el nombre o número del Pokémon: " BUSQUEDA

    if [ -z "$BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún valor.${reset}"
        return
    fi

    POKEMON_DATA=$(
        jq -r --arg query "$BUSQUEDA" '
        .pokemons[] |
        select(
            (.numero | tostring) == $query or
            (.nombre | ascii_downcase) == ($query | ascii_downcase)
        )
        | "\(.numero)\n\(.nombre)\n\(.tipo)\n\(.nivel)\n\(.descripcion)"
        ' "$JSON_FILE" 2>/dev/null
    )

    if [ -z "$POKEMON_DATA" ]; then
        echo -e "\n${rojo}Error: Pokémon '$BUSQUEDA' no encontrado en la Pokédex.${reset}"
    else
        mapfile -t DATOS <<< "$POKEMON_DATA"
        local NUMERO="${DATOS[0]}"
        local NOMBRE="${DATOS[1]}"
        local TIPO="${DATOS[2]}"

        local NUMERO_FORMATO=$(printf "%03d" "$NUMERO")

        echo -e "\n${verde}=== Pokémon encontrado ===${reset}"
        echo "Número: ${NUMERO_FORMATO}"
        echo "Nombre: ${NOMBRE}"
        echo "Tipo: ${TIPO}"
        echo "Nivel: ${DATOS[3]}"
        echo "Descripción: ${DATOS[4]}"
        echo "--------------------------"

        registrar_avistamiento "$NUMERO" "$NOMBRE" "$TIPO"
    fi
}

# 50. contar_pokemon
function contar_pokemon() {
    TOTAL_POKEMON=$(jq '.pokemons | length' "$JSON_FILE")
    echo -e "\n${verde}=== RESUMEN DE LA POKÉDEX ===${reset}"
    echo "Total de Pokémon cargados: $TOTAL_POKEMON"
    echo "-----------------------------------"
}

# 51. listar_tipos
function listar_tipos() {
    echo -e "\n${verde}=== TIPOS DE POKÉMON EN LA POKÉDEX ===${reset}"

    jq -r '.pokemons[].tipo' "$JSON_FILE" | \
    tr '/' '\n' | \
    sort -u | \
    while read -r tipo; do
        echo " - $tipo"
    done

    echo "-----------------------------------"
}

# 52. buscar_por_tipo
function buscar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo de Pokémon (ej: Fuego, Dragón): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    RESULTADOS=$(
        jq -r --arg tipo "$TIPO_LOWER" '
        .pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo)) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS PARA TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}

# 53. buscar_por_nivel
function buscar_por_nivel() {
    echo -e "\n${amarillo}=== BÚSQUEDA POR RANGO DE NIVEL ===${reset}"
    read -r -p "Introduce el Nivel Mínimo (ej: 30): " MIN_NIVEL
    read -r -p "Introduce el Nivel Máximo (ej: 40): " MAX_NIVEL

    if [ -z "$MIN_NIVEL" ] || [ -z "$MAX_NIVEL" ]; then
        echo -e "${rojo}Error: Debe introducir un nivel mínimo y máximo.${reset}"
        return
    fi

    if ! [[ "$MIN_NIVEL" =~ ^[0-9]+$ ]] || ! [[ "$MAX_NIVEL" =~ ^[0-9]+$ ]]; then
        echo -e "${rojo}Error: Los niveles deben ser números enteros.${reset}"
        return
    fi

    RESULTADOS=$(
        jq -r --argjson min "$MIN_NIVEL" --argjson max "$MAX_NIVEL" '
        .pokemons[] |
        select((.nivel | tonumber) >= $min and (.nivel | tonumber) <= $max) |
        "Nivel \(.nivel): \(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "Nivel %s: %03d - %s\n", $2, $4, $5}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon entre el Nivel $MIN_NIVEL y $MAX_NIVEL.${reset}"
    else
        echo -e "\n${verde}=== RESULTADOS ENTRE NIVEL $MIN_NIVEL y $MAX_NIVEL ===${reset}"
        echo "$RESULTADOS" | sort -n
        echo "------------------------------------------------"
    fi
}

# 54. contar_por_tipo
function contar_por_tipo() {
    echo
    read -r -p "Introduce el Tipo a Contar (ej: Agua): " TIPO_BUSQUEDA

    if [ -z "$TIPO_BUSQUEDA" ]; then
        echo -e "${rojo}Error: No se introdujo ningún tipo.${reset}"
        return
    fi

    TIPO_LOWER=$(echo "$TIPO_BUSQUEDA" | tr '[:upper:]' '[:lower:]')

    TOTAL_TIPO=$(
        jq --arg tipo "$TIPO_LOWER" '
        [.pokemons[] |
        select(.tipo | ascii_downcase | contains($tipo))]
        | length
        ' "$JSON_FILE"
    )

    if [ "$TOTAL_TIPO" -eq 0 ]; then
        echo -e "\n${rojo}No se encontraron Pokémon del tipo '$TIPO_BUSQUEDA'.${reset}"
    else
        echo -e "\n${verde}=== CONTEO DEL TIPO: $TIPO_BUSQUEDA ===${reset}"
        echo "Hay un total de ${TOTAL_TIPO} Pokémon que contienen el Tipo '$TIPO_BUSQUEDA'."
        echo "------------------------------------------------"
    fi
}

# 55. buscar_por_region
function buscar_por_region() {
    echo -e "\n${amarillo}=== FILTRAR POR REGIÓN/GENERACIÓN ===${reset}"
    echo "Selecciona una Región:"
    echo " 1) Kanto (001-151) "
    echo " 2) Johto (152-251)"
    echo " 3) Hoenn (252-386)"
    echo " 4) Sinnoh (387-493)"
    echo " 5) Teselia (494-649)"
    echo " 6) Kalos (650-721)"
    echo " 7) Alola (722-809)"
    echo " 8) Galar (810-905)"
    echo " 9) Paldea (906-1017)"
    echo "-----------------------------------"
    read -r -p "¿Región [1-9]: " REGION_OPCION

    case $REGION_OPCION in
        1) REGION_NOMBRE="Kanto"; MIN=1; MAX=151 ;;
        2) REGION_NOMBRE="Johto"; MIN=152; MAX=251 ;;
        3) REGION_NOMBRE="Hoenn"; MIN=252; MAX=386 ;;
        4) REGION_NOMBRE="Sinnoh"; MIN=387; MAX=493 ;;
        5) REGION_NOMBRE="Teselia"; MIN=494; MAX=649 ;;
        6) REGION_NOMBRE="Kalos"; MIN=650; MAX=721 ;;
        7) REGION_NOMBRE="Alola"; MIN=722; MAX=809 ;;
        8) REGION_NOMBRE="Galar"; MIN=810; MAX=905 ;;
        9) REGION_NOMBRE="Paldea"; MIN=906; MAX=1017 ;;
        *)
            echo -e "${rojo}Opción de Región no válida.${reset}"
            return
            ;;
    esac

    RESULTADOS=$(
        jq -r --argjson min "$MIN" --argjson max "$MAX" '
        .pokemons[] |
        select((.numero | tonumber) >= $min and (.numero | tonumber) <= $max) |
        "\(.numero) - \(.nombre) (\(.tipo))"
        ' "$JSON_FILE" | awk '{printf "%03d - %s\n", $1, $0}'
    )

    if [ -z "$RESULTADOS" ]; then
        echo -e "\n${rojo}No se encontraron Pokémon en la Región de $REGION_NOMBRE.${reset}"
    else
        TOTAL_REGION=$(echo "$RESULTADOS" | wc -l)
        echo -e "\n${verde}=== POKÉMON EN LA REGIÓN DE $REGION_NOMBRE (Total: $TOTAL_REGION) ===${reset}"
        echo "$RESULTADOS"
        echo "------------------------------------------------"
    fi
}


# ==================================================
# --- BUCLE PRINCIPAL Y MENÚ DE OPCIONES ---
# ==================================================

# 0) Comprobación inicial
comprobar_entorno

while true; do
    clear

    TOTAL_POKEMON=$(jq '.pokemons | length' "$JSON_FILE")
    # FIX: La alineación del menú ahora es correcta
    echo -e "${amarillo}=== MENÚ PRINCIPAL POKÉDEX (Total Nacional: $TOTAL_POKEMON Pokémon) ===${reset}"
    echo "1) Buscar Pokémon (Nombre o Número) [Solo Avistamiento]"
    echo "2) Contar Pokémon Total"
    echo "3) Listar Tipos Únicos"
    echo "4) Buscar Pokémon por Tipo"
    echo "5) Buscar Pokémon por Rango de Nivel"
    echo "6) Contar Pokémon por Tipo"
    echo "7) Buscar Pokémon por Región"
    echo "8) Encuentro Pokémon (Ruta) [CAPTURA]"
    echo "9) ${magenta}COMBATIR (CAPTURA)${reset}"
    echo "10) ${blanco}DESAFÍO LEGENDARIO (CAPTURA)${reset}" # Nueva Opción
    echo "11) Ver Avistamientos (Pokédex VISTOS)"
    echo "12) Ver PC de Bill (Tus Pokémon CAPTURADOS)"
    echo "13) Borrar Avistamientos"
    echo "14) Liberar Pokémon del PC"
    echo "15) Salir"
    echo "--------------------------------"
    read -r -p "¿Seleccione una opción [1-15]: " OPCION

    case $OPCION in
        1)
            buscar_pokemon
            ;;
        2)
            contar_pokemon
            ;;
        3)
            listar_tipos
            ;;
        4)
            buscar_por_tipo
            ;;
        5)
            buscar_por_nivel
            ;;
        6)
            contar_por_tipo
            ;;
        7)
            buscar_por_region
            ;;
        8)
            encontrar_pokemon_aleatorio
            ;;
        9)
            iniciar_combate
            ;;
        10)
            capturar_legendario
            ;;
        11)
            ver_avistamientos
            ;;
        12)
            ver_pc_bill
            ;;
        13)
            borrar_avistamientos
            ;;
        14)
            liberar_pokemons
            ;;
        15)
            echo -e "${verde}¡Adiós, entrenador!${reset}"
            exit 0
            ;;
        *)
            echo -e "${rojo}Opción no válida. Inténtelo de nuevo.${reset}"
            ;;
    esac

    read -r -p "Presione [Enter] para continuar..."
done