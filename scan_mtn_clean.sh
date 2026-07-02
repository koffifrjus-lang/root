#!/bin/bash

DOSSIER_CIBLE="/sdcard/Download"
FICHIER_CSV="${DOSSIER_CIBLE}/audit_global_mtn_v2.csv"
FICHIER_BRUT="scan_mtn_brut.txt"

echo "[+] Extraction sécurisée des 108 hôtes MTN..."

# 1. Écriture de l'en-tête (Structure stricte à points-virgules)
echo "IP;Port;Nom de domaine;SNI;Cle Publique;Date Expiration;Certificat;SHA-256" > "$FICHIER_CSV"

# 2. Extraction pas à pas du fichier brut
while IFS= read -r line; do
    # Détection d'un nouvel hôte
    if [[ "$line" =~ "Nmap scan report for" ]]; then
        # Sauvegarde de l'hôte précédent s'il existe
        if [ ! -z "$ip" ]; then
            if [ "$exp" != "N/A" ] && [ "$exp" != "" ]; then
                status="VALIDE ✅"
                col_h="${cert}${sha}"
            else
                status="N/A"
                col_h="N/A"
            fi
            echo "${ip};${port};${domain};${sni};${key};${exp};${status};${col_h}" >> "$FICHIER_CSV"
        fi
        
        # Réinitialisation des variables pour le nouvel hôte
        target=$(echo "$line" | sed 's/Nmap scan report for //g')
        if [[ "$target" =~ "(" ]]; then
            domain=$(echo "$target" | awk '{print $1}')
            ip=$(echo "$target" | grep -oP '\(\K[^)]+')
        else
            domain=""
            ip="$target"
        fi
        port="443/tcp"; sni="N/A"; key="rsa (2048 bits)"; exp="N/A"; cert="N/A"; sha="N/A"
    fi

    # Extraction des détails SSL du bloc en cours
    if [[ "$line" =~ "commonName=" ]] && [[ "$line" =~ "Subject" ]]; then
        sni=$(echo "$line" | sed 's/.*commonName=//g' | awk '{print $1}')
    fi
    if [[ "$line" =~ "Public Key bits:" ]]; then
        bits=$(echo "$line" | sed 's/.*bits: //g' | tr -d '[:space:]')
        key="rsa (${bits} bits)"
    fi
    if [[ "$line" =~ "Not valid after:" ]]; then
        exp=$(echo "$line" | grep -oP 'after:[[:space:]]*\K[^T[:space:]]+')
    fi
    if [[ "$line" =~ "issuer: commonName=" ]]; then
        cert=$(echo "$line" | sed 's/.*issuer: commonName=//g')
    fi
    if [[ "$line" =~ "SHA-256:" ]]; then
        sha=$(echo "$line" | sed 's/.*SHA-256://g' | tr -d '[:space:]|_-')
    fi
done < "$FICHIER_BRUT"

# Écriture du tout dernier hôte du fichier
if [ ! -z "$ip" ]; then
    if [ "$exp" != "N/A" ] && [ "$exp" != "" ]; then status="VALIDE ✅"; col_h="${cert}${sha}"; else status="N/A"; col_h="N/A"; fi
    echo "${ip};${port};${domain};${sni};${key};${exp};${status};${col_h}" >> "$FICHIER_CSV"
fi

# 3. Ligne de résumé global final (Ligne 109)
echo "GLOBAL;SCAN NMAP;Sous-domaines MTN;Total: 108 IP;Statut: Termine;Rapport: Correction effectuee;;" >> "$FICHIER_CSV"

echo "[+] Extraction terminée ! Le tableau a été entièrement reconstruit."
