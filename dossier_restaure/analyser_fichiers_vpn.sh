#!/bin/bash
DOSSIER_SOURCE="RESEAUX MOBILE"
FICHIER_SORTIE="/sdcard/Download/audit_configurations_vpn.csv"

echo "Fichier;Type_Extension;Methode_Chiffrement;Payload_Ou_Signature;Statut_Fichier" > "$FICHIER_SORTIE"

cd "$DOSSIER_SOURCE" || exit 1

for fichier in *; do
    [ -f "$fichier" ] || continue
    extension="${fichier##*.}"
    
    methode="Inconnue"
    signature="Aucune_Empreinte_Lisible"

    if [ "$extension" == "dark" ]; then
        methode="Base64 / JSON Décodé"
        # 1. Tentative de décodage agressif du Base64 masqué dans le fichier .dark
        extraction_brute=$(cat "$fichier" 2>/dev/null | tr -d '\r\n ' | grep -oE '[a-zA-Z0-9+/=]{20,}' | head -n 1)
        
        if [ -n "$extraction_brute" ]; then
            decodage=$(echo "$extraction_brute" | base64 -d 2>/dev/null | strings | grep -oE '([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}' | head -n 1)
            if [ -n "$decodage" ]; then
                signature="Host_Trouve: $decodage"
            else
                # Deuxième essai si le JSON est partiellement en clair
                signature=$(strings "$fichier" | grep -E '(host|sni|payload)' | head -n 1 | tr -d '";{}')
                [ -z "$signature" ] && signature="Bloc_Base64_Protege"
            fi
        fi
    elif [ "$extension" == "hc" ]; then
        methode="Binaire AES (HTTP Custom)"
        signature="Chiffrement_Lourd_Bloque"
    elif [ "$extension" == "bdnet" ]; then
        methode="Compression Propriétaire (BDNet)"
        signature="Structure_Zlib_Obscure"
    fi

    echo "${fichier};${extension};${methode};${signature};Analyse_Poussee_Terminee" >> "$FICHIER_SORTIE"
done

echo "[+] Décodage agressif terminé !"
