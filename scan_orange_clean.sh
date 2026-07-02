#!/bin/bash

MOTCLE="orange"
FICHIER_SCAN="scan_orange_brut.txt"
DOSSIER_CIBLE="/sdcard/Download"
FICHIER_CSV="${DOSSIER_CIBLE}/audit_global_orange.csv"

echo "IP;Port;Nom de domaine;SNI;Cle Publique;Date Expiration;Certificat;SHA-256" > "$FICHIER_CSV"
echo "[+] Extraction dynamique et nettoyage Orange en cours..."

while read -r raw_line; do
    # Nettoyage des barres verticales et espaces en début de ligne
    line=$(echo "$raw_line" | sed 's/^[ \t|_\\]*//g')

    if [[ "$raw_line" =~ "Nmap scan report for" ]]; then
        DOM=$(echo "$raw_line" | awk '{print $5}')
        IP=$(echo "$raw_line" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
        [ -z "$DOM" ] && DOM="$IP"
        SNI="N/A"; PUBKEY="N/A"; EXP="N/A"; STATUT="N/A"; SHA256="N/A"
    fi

    if [[ "$line" =~ "Subject Alternative Name:" ]]; then
        SNI=$(echo "$line" | grep -oE 'DNS:[^ ,]+' | cut -d: -f2 | tr '\n' ',' | sed 's/,$//')
    fi
    if [[ "$line" =~ "Public Key bits:" ]]; then
        BITS=$(echo "$line" | grep -oE '[0-9]+')
        PUBKEY="rsa (${BITS} bits)"
    fi
    if [[ "$line" =~ "Not valid after:" ]]; then
        EXP=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')
        [ -z "$EXP" ] && EXP=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
        STATUT="VALIDE ✅"
    fi
    if [[ "$line" =~ "SHA-256:" ]]; then
        SHA_PART1=$(echo "$line" | cut -d: -f2- | tr -d ' ')
        read -r next_raw
        SHA_PART2=$(echo "$next_raw" | sed 's/^[ \t|_\\]*//g' | tr -d ' ')
        SHA256="${SHA_PART1}${SHA_PART2}"
    fi

    if [[ "$line" =~ "80/tcp" && "$line" =~ "open" ]]; then
        echo "${IP};80/tcp;${DOM};N/A;N/A;N/A;N/A;N/A" >> "$FICHIER_CSV"
    fi
    if [[ "$line" =~ "443/tcp" && "$line" =~ "open" ]]; then
        echo "${IP};443/tcp;${DOM};${SNI};${PUBKEY};${EXP};${STATUT};${SHA256}" >> "$FICHIER_CSV"
    fi
done < "$FICHIER_SCAN"

echo "[+] Fichier d'audit Orange mis à jour avec succès !"

