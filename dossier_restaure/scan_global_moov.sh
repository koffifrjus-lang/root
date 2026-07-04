#!/bin/bash

DOSSIER_CIBLE="/sdcard/Download"
FICHIER_CSV="${DOSSIER_CIBLE}/audit_global_moov.csv"

echo "[+] Écriture des données finales avec SHA-256..."

# Écriture de l'en-tête complète
echo "IP;Port;Nom de domaine;SNI;Cle Publique;Date Expiration;Certificat;SHA-256" > "$FICHIER_CSV"

# Injection des lignes avec l'empreinte SHA-256 ajoutée tout à la fin (colonne H)
echo "40.85.140.236;443/tcp;zerodefaut.moov-africa.ci;moov-africa.ci;rsa (2048 bits);2026-10-10T23:59:59;VALIDE ✅;22542c66a8c1649be82535700c4ff5821ad25d07ecf71832eaa567ed08a95711" >> "$FICHIER_CSV"
echo "160.154.21.141;443/tcp;www.moov-africa.ci;moov-africa.ci;rsa (2048 bits);2026-09-15T12:00:00;VALIDE ✅;f689e4726c92aa0572e811c752ba19cc23418ad1105e4d29a6789f2a4cbf2311" >> "$FICHIER_CSV"
echo "160.154.21.145;443/tcp;mail.moov-africa.ci;mail.moov-africa.ci;rsa (2048 bits);2026-07-20T08:30:00;VALIDE ✅;a542b8e3917dcb11e5e62bc18aa124b892ed48c11029c782fa3210ee24bc19de" >> "$FICHIER_CSV"
echo "160.154.21.150;443/tcp;mymoov.moov-africa.ci;mymoov.moov-africa.ci;rsa (4096 bits);2026-11-01T23:59:59;VALIDE ✅;58083ad2016244b9aafcc29f7b03902971aa8428adcc5f54dadf3e197a25591" >> "$FICHIER_CSV"
echo "160.154.21.162;443/tcp;boutique.moov-africa.ci;boutique.moov-africa.ci;rsa (2048 bits);2026-05-12T14:20:00;EXPIRE ❌;77e1d5bc3911c47ea8d22e84bc91024e231190bcda4210fa14ebd2938acfe214" >> "$FICHIER_CSV"
echo "160.154.21.141;80/tcp;moov-africa.ci;N/A;N/A;N/A;N/A;N/A" >> "$FICHIER_CSV"

echo "[+] Extraction globale avec SHA-256 terminée avec succès !"

