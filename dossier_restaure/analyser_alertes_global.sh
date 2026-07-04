#!/bin/bash
FICHIER_SORTIE="/sdcard/Download/audit_alertes_general.txt"
FICHIER_SOURCE="scan_brut.txt"
FICHIER_TEMP="Rapport_tmp.txt"
DIR_VPN="RESEAUX MOBILE"

echo -e "=== RAPPORT GLOBAL D AUDIT ET CONFIGURATIONS RESEAUX ===\n" > "$FICHIER_TEMP"
echo -e "ID|RESEAU|IP_SERVEUR|PORT|DOMAINE_HOST|GRAVITE|IDENTIFIANT_FAILLE|FICHIER_VPN_ASSOCIE|TYPE_TUNNEL|CHIFFREMENT|EN_TETE_PAYLOAD" >> "$FICHIER_TEMP"

DATE_ACTUELLE=$(date +%Y%m%d)
compteur=1

if [ -f "$FICHIER_SOURCE" ]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Nettoyage sécurisé sans xargs pour éviter l'erreur de guillemets
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        if [[ "$line" =~ "Nmap scan report for" ]]; then
            current_ip=$(echo "$line" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -n 1)
            current_domain=$(echo "$line" | awk '{print $5}' | tr -d '()')
            [ -z "$current_domain" ] && current_domain=$(echo "$line" | awk '{print $NF}')
            [ -z "$current_ip" ] && current_ip=$current_domain
            if [[ "${line,,}" =~ "orange" ]]; then current_network="ORANGE"
            elif [[ "${line,,}" =~ "mtn" ]]; then current_network="MTN"
            elif [[ "${line,,}" =~ "moov" ]]; then current_network="MOOV"
            else current_network="AUTRE"
            fi
        fi

        if [[ "$line" =~ "Not valid after" ]]; then
            expiry_raw=$(echo "$line" | awk -F'after: ' '{print $2}' | awk '{print $1}' | cut -d'T' -f1)
            expiry_num=$(echo "$expiry_raw" | tr -d '-')
            if [[ "$line" =~ "2023" || "$line" =~ "2024" || "$line" =~ "2025" ]]; then
                echo "N°$compteur|${current_network}|${current_ip}|443|${current_domain}|[CRITIQUE]|SSL-EXPIRED|Aucun|Aucun|Aucun|Certificat_expire" >> "$FICHIER_TEMP"
            elif [[ "$line" =~ "2026" ]]; then
                if [ "$expiry_num" -le "$DATE_ACTUELLE" ]; then
                    echo "N°$compteur|${current_network}|${current_ip}|443|${current_domain}|[CRITIQUE]|SSL-EXPIRED|Aucun|Aucun|Aucun|Certificat_expire" >> "$FICHIER_TEMP"
                else
                    echo "N°$compteur|${current_network}|${current_ip}|443|${current_domain}|[ELEVE]|TLS-WARN-EXP|Aucun|Aucun|Aucun|Expiration_imminente" >> "$FICHIER_TEMP"
                fi
            else
                echo "N°$compteur|${current_network}|${current_ip}|443|${current_domain}|[FAIBLE]|SSL-VALID|Aucun|Aucun|Aucun|Certificat_valide" >> "$FICHIER_TEMP"
            fi
            compteur=$((compteur+1))
        fi

        if [[ "$line" =~ "23/tcp" && "$line" =~ "open" ]]; then
            echo "N°$compteur|${current_network}|${current_ip}|23|${current_domain}|[CRITIQUE]|TELNET-OPEN|Aucun|Aucun|Aucun|Telnet_en_clair" >> "$FICHIER_TEMP"
            compteur=$((compteur+1))
        fi
        if [[ "$line" =~ "22/tcp" && "$line" =~ "open" ]]; then
            echo "N°$compteur|${current_network}|${current_ip}|22|${current_domain}|[MOYEN]|SSH-EXPOSED|Aucun|Aucun|Aucun|SSH_expose" >> "$FICHIER_TEMP"
            compteur=$((compteur+1))
        fi
    done < "$FICHIER_SOURCE"
fi

if [ -d "$DIR_VPN" ]; then
    cd "$DIR_VPN" || exit
    for fichier in *; do
        [ -f "$fichier" ] || continue
        extension="${fichier##*.}"
        
        if [[ "${fichier,,}" =~ "orange" ]]; then vpn_network="ORANGE"
        elif [[ "${fichier,,}" =~ "mtn" ]]; then vpn_network="MTN"
        elif [[ "${fichier,,}" =~ "moov" ]]; then vpn_network="MOOV"
        else vpn_network="AUTRE"
        fi

        if [ "$extension" == "dark" ]; then
            tunnel_type="Dark_Tunnel"
            chiffrement="Base64/JSON"
            payload="Header_Payload_Protege"
        elif [ "$extension" == "hc" ]; then
            tunnel_type="HTTP_Custom"
            chiffrement="Binaire_AES"
            payload="Bloc_AES_Chiffre"
        elif [ "$extension" == "bdnet" ]; then
            tunnel_type="BDNet_VPN"
            chiffrement="Zlib_Pack"
            payload="Structure_Zlib_Scellee"
        else
            tunnel_type="Tunnel_Inconnu"
            chiffrement="Inconnu"
            payload="Brut"
        fi

        # Remplacement des espaces par des underscores dans le nom du fichier pour l'affichage en tableau
        nom_propre=$(echo "$fichier" | tr ' ' '_')
        echo "N°$compteur|${vpn_network}|Statique|Tunnel|Fichier_Config|[CONFIG]|VPN-INJECT|${nom_propre}|${tunnel_type}|${chiffrement}|${payload}" >> "../$FICHIER_TEMP"
        compteur=$((compteur+1))
    done
    cd ..
fi

column -t -s "|" "$FICHIER_TEMP" > "$FICHIER_SORTIE"
rm -f "$FICHIER_TEMP"
echo "[+] Rapport unifié nettoyé généré sans erreur !"
