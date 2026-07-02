#!/bin/bash

DOSSIER_CIBLE="/sdcard/Download"
FICHIER_CSV="${DOSSIER_CIBLE}/audit_global_orange.csv"

echo "[+] Nettoyage et réécriture du tableau Orange..."

# 1. Écriture de l'en-tête
echo "IP;Port;Nom de domaine;SNI;Cle Publique;Date Expiration;Certificat;SHA-256" > "$FICHIER_CSV"

# 2. Injection des lignes de données
echo "154.68.9.46;443/tcp;orange.ci;;orange.ci;rsa (2048 bits);2026-09-08T23:59:59;VALIDE ✅;ee7760796acd6b48cdd5ab365f7d298cd644a64a732a62b68b05e6121f1090a6" >> "$FICHIER_CSV"
echo "154.68.9.46;443/tcp;www.orange.ci;;orange.ci;rsa (2048 bits);2026-09-08T23:59:59;VALIDE ✅;ee7760796acd6b48cdd5ab365f7d298cd644a64a732a62b68b05e6121f1090a6" >> "$FICHIER_CSV"
echo "160.154.2.25;443/tcp;mail.orange.ci;mail.orange.ci;rsa (2048 bits);2026-04-11T12:00:00;EXPIRE ❌;b45a27c118e9a24bbd11059f33cd29810452f31aa9b027811ce45bc112aa45df" >> "$FICHIER_CSV"
echo "41.66.15.246;443/tcp;monespace.orange.ci;monespace.orange.ci;rsa (4096 bits);2026-11-20T23:59:59;VALIDE ✅;77af11bc329ea152bf01e23cd4421aa892ed48c11029c782fa3210ee24bc19de" >> "$FICHIER_CSV"
echo "154.68.9.46;80/tcp;orange.ci;N/A;N/A;N/A;N/A;N/A" >> "$FICHIER_CSV"
echo "160.154.2.25;80/tcp;mail.orange.ci;N/A;N/A;N/A;N/A;N/A" >> "$FICHIER_CSV"

echo "[+] Correction terminée avec succès !"

