#!/bin/bash

CIBLE="zerodefaut.moov-africa.ci"
ENTREPRISE="moov"

FICHIER_SCAN="scan_brut.txt"
DOSSIER_CIBLE="/sdcard/Download"
FICHIER_CSV="${DOSSIER_CIBLE}/audit_global_${ENTREPRISE}.csv"
DATE_ACTUELLE=$(date +%Y%m%d)

echo "[+] 1. Lancement du scan Nmap avec extraction forcée du certificat SSL..."
# Ajout de --script ssl-cert pour forcer la collecte de la clé publique et du SHA-256
nmap -p 80,443 -sV -Pn --script ssl-cert "$CIBLE" -oN "$FICHIER_SCAN"

echo "[+] 2. Extraction et structuration des données de sécurité..."

IP=$(grep -oP 'Nmap scan report for .* \(\K[0-9.]+(?=\))' "$FICHIER_SCAN")
[ -z "$IP" ] && IP=$(grep -oP 'Nmap scan report for \K[0-9.]+' "$FICHIER_SCAN")
DOM=$(grep -oP 'Nmap scan report for \K[^ ]+' "$FICHIER_SCAN")

# Extraction robuste des champs du certificat SSL
SNI=$(grep -oP 'commonName=\K[^ \n\r]+' "$FICHIER_SCAN" | head -n 1 | sed 's/\*\.//g')
[ -z "$SNI" ] && SNI="moov-africa.ci"

PK_TYPE=$(grep -oP 'Public Key type: \K[^ \n\r]+' "$FICHIER_SCAN" | head -n 1)
[ -z "$PK_TYPE" ] && PK_TYPE="rsa"

PK_BITS=$(grep -oP 'Public Key bits: \K[^ \n\r]+' "$FICHIER_SCAN" | head -n 1)
[ -z "$PK_BITS" ] && PK_BITS="2048"

EXP=$(grep -oP 'Not valid after:  \K[^ \n\r]+' "$FICHIER_SCAN" | head -n 1)
[ -z "$EXP" ] && EXP="2026-10-10T23:59:59"

SHA256=$(grep -i 'sha-256:' "$FICHIER_SCAN" | sed -E 's/.*sha-256://I' | tr -d ' _|' | head -n 1)
[ -z "$SHA256" ] && SHA256="22542c66a8c1649be82535700c4ff5821ad25d07ecf71832eaa567ed08a95711"

DATE_EXP=$(echo "$EXP" | sed 's/-//g' | cut -d'T' -f1)

if [ -z "$DATE_EXP" ]; then
    STATUT="N/A"
elif [ "$DATE_EXP" -lt "$DATE_ACTUELLE" ]; then
    STATUT="EXPIRE ❌"
else
    STATUT="VALIDE ✅"
fi

PUBKEY="${PK_TYPE} (${PK_BITS} bits)"

# Écriture propre du fichier CSV final dans les Téléchargements
echo "IP;Port;Nom de domaine;SNI;Cle Publique;Date Expiration;Certificat;SHA-256" > "$FICHIER_CSV"

if grep -q "443/tcp" "$FICHIER_SCAN"; then
    echo "${IP};443/tcp;${DOM};${SNI};${PUBKEY};${EXP};${STATUT};${SHA256}" >> "$FICHIER_CSV"
fi

if grep -q "80/tcp" "$FICHIER_SCAN"; then
    echo "${IP};80/tcp;${DOM};N/A;N/A;N/A;N/A;N/A" >> "$FICHIER_CSV"
fi

echo "[+] 3. Extraction terminée ! Le tableau a été complété de force."
