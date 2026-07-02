#!/bin/bash

MOTCLE="moov"
FICHIER_SCAN="scan_brut.txt"
DOSSIER_CIBLE="/sdcard/Download"

echo "IP;Port;Nom de domaine;SNI;Cle Publique;Date Expiration;Certificat" > "${DOSSIER_CIBLE}/resultats_${MOTCLE}_port80.csv"
echo "IP;Port;Nom de domaine;SNI;Cle Publique;Date Expiration;Certificat" > "${DOSSIER_CIBLE}/resultats_${MOTCLE}_port443.csv"

echo "[+] Extraction dynamique et correction des dates en cours..."

while read -r line; do
    if [[ "$line" =~ "Nmap scan report for" ]]; then
        DOM=$(echo "$line" | awk '{print $5}')
        IP=$(echo "$line" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
        [ -z "$DOM" ] && DOM="$IP"
        SNI="N/A"; PUBKEY="N/A"; EXP="N/A"; STATUT="N/A"
    fi

    if [[ "$line" =~ "Subject Alternative Name:" ]]; then
        SNI=$(echo "$line" | grep -oE 'DNS:[^ ,]+' | cut -d: -f2 | tr '\n' ',' | sed 's/,$//')
    fi
    if [[ "$line" =~ "Public Key bits:" ]]; then
        BITS=$(echo "$line" | grep -oE '[0-9]+')
        PUBKEY="rsa (${BITS} bits)"
    fi
    if [[ "$line" =~ "Not valid after:" ]]; then
        # Extraction propre de la date au format AAAA-MM-JJ
        EXP=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')
        [ -z "$EXP" ] && EXP=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
        STATUT="VALIDE ✅"
    fi

    if [[ "$line" =~ "80/tcp" && "$line" =~ "open" ]]; then
        echo "${IP};80/tcp;${DOM};N/A;N/A;N/A;N/A" >> "${DOSSIER_CIBLE}/resultats_${MOTCLE}_port80.csv"
    fi
    if [[ "$line" =~ "443/tcp" && "$line" =~ "open" ]]; then
        echo "${IP};443/tcp;${DOM};${SNI};${PUBKEY};${EXP};${STATUT}" >> "${DOSSIER_CIBLE}/resultats_${MOTCLE}_port443.csv"
    fi
done < "$FICHIER_SCAN"

echo "[+] Extraction complète et corrigée !"

