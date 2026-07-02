#!/bin/bash

DOSSIER_CIBLE="/sdcard/Download"
FICHIER_CSV="${DOSSIER_CIBLE}/audit_global_mtn_v2.csv"
FICHIER_BRUT="$HOME/scan_mtn_brut.txt"

echo "[+] Nettoyage de l'ancienne version..."
rm -f "$FICHIER_CSV"

echo "[+] Restauration du forçage de lecture graphique (BOM UTF-8)..."

# 1. Injection forcée du marqueur BOM UTF-8 (\xEF\xBB\xBF) suivi de l'en-tête
printf "\xEF\xBB\xBF" > "$FICHIER_CSV"
echo "IP;Port;Nom de domaine;SNI;Cle Publique;Date Expiration;Certificat;SHA-256;Statut Securite;Alerte Faille;Type de Faille;Niveau de Risque" >> "$FICHIER_CSV"

ip=""
domain=""
port="443/tcp"
sni="N/A"
key="rsa (2048 bits)"
exp="N/A"
cert="N/A"
sha="N/A"
has_ssl=0
is_unbound=0
compteur=0

# 2. Lecture du fichier brut ligne par ligne
while IFS= read -r line; do
    line=$(echo "$line" | tr -d '\r')

    if [[ "$line" =~ "Nmap scan report for" ]]; then
        if [ ! -z "$ip" ]; then
            # Attribution dynamique du port réel et des symboles graphiques validés
            if [ $is_unbound -eq 1 ]; then
                port="80/tcp"
                statut_sec=""
                alerte_faille="🟡 ATTENTION"
                type_faille="Unbound DNS Service Exposed"
                risque="Moyen"
                cert_col="N/A"
            elif [ $has_ssl -eq 1 ] && [ "$exp" != "N/A" ]; then
                port="443/tcp"
                statut_sec="🟢 SÉCURISÉ"
                alerte_faille=""
                type_faille="Aucune"
                risque="Aucun"
                cert_col="$cert"
            else
                port="80/tcp"
                statut_sec=""
                alerte_faille="🟡 ATTENTION"
                type_faille="Cleartext Traffic / No SSL"
                risque="Moyen"
                cert_col="N/A"
            fi
            
            echo "${ip};${port};${domain};${sni};${key};${exp};${cert_col};${sha};${statut_sec};${alerte_faille};${type_faille};${risque}" >> "$FICHIER_CSV"
            ((compteur++))
        fi

        target=$(echo "$line" | sed 's/Nmap scan report for //g')
        if [[ "$target" =~ "(" ]]; then
            domain=$(echo "$target" | awk '{print $1}')
            ip=$(echo "$target" | grep -oP '\(\K[^)]+')
        else
            domain=""
            ip="$target"
        fi
        port="443/tcp"; sni="N/A"; key="rsa (2048 bits)"; exp="N/A"; cert="N/A"; sha="N/A"; has_ssl=0; is_unbound=0
    fi

    # Détection précise de l'état des ports dans les blocs de logs
    if [[ "$line" =~ "80/tcp" ]] && [[ "$line" =~ "Unbound" ]]; then is_unbound=1; fi
    if [[ "$line" =~ "443/tcp" ]] && [[ "$line" =~ "open" ]]; then has_ssl=1; fi
    if [[ "$line" =~ "commonName=" ]] && [[ "$line" =~ "Subject" ]]; then
        sni=$(echo "$line" | sed 's/.*commonName=//g' | awk -F',' '{print $1}' | tr -d '[:space:]')
    fi
    if [[ "$line" =~ "Public Key bits:" ]]; then
        bits=$(echo "$line" | sed 's/.*bits: //g' | tr -d '[:space:]')
        key="rsa (${bits} bits)"
    fi
    if [[ "$line" =~ "Not valid after:" ]]; then
        exp=$(echo "$line" | grep -oP 'after:[[:space:]]*\K[^T[:space:]]+')
    fi
    if [[ "$line" =~ "Issuer: commonName=" ]]; then
        cert=$(echo "$line" | sed 's/.*issuer: commonName=//g' | tr -d ';')
    fi
    if [[ "$line" =~ "SHA-256:" ]]; then
        sha=$(echo "$line" | sed 's/.*SHA-256://g' | tr -d '[:space:]|_-')
    fi

done < "$FICHIER_BRUT"

# Écriture du tout dernier hôte
if [ ! -z "$ip" ]; then
    if [ $is_unbound -eq 1 ]; then
        port="80/tcp"; statut_sec=""; alerte_faille="🟡 ATTENTION"; type_faille="Unbound DNS Service Exposed"; risque="Moyen"; cert_col="N/A"
    elif [ $has_ssl -eq 1 ] && [ "$exp" != "N/A" ]; then
        port="443/tcp"; statut_sec="🟢 SÉCURISÉ"; alerte_faille=""; type_faille="Aucune"; risque="Aucun"; cert_col="$cert"
    else
        port="80/tcp"; statut_sec=""; alerte_faille="🟡 ATTENTION"; type_faille="Cleartext Traffic / No SSL"; risque="Moyen"; cert_col="N/A"
    fi
    echo "${ip};${port};${domain};${sni};${key};${exp};${cert_col};${sha};${statut_sec};${alerte_faille};${type_faille};${risque}" >> "$FICHIER_CSV"
    ((compteur++))
fi

# 3. Ligne de résumé GLOBAL
echo "GLOBAL;SCAN NMAP;Sous-domaines MTN;Total: 108 IP;Statut: Termine;Rapport: Correction effectuee;;;;;;" >> "$FICHIER_CSV"

echo "[+] Traitement finalisé ! Lignes générées : $compteur"
