#!/bin/bash

echo "[+] Démarrage du nettoyage sécurisé de l'espace Termux..."

# 1. Nettoyage du cache des paquets d'installation Termux
pkg clean

# 2. Suppression ciblée des fichiers de scans bruts volumineux déjà traités
if [ -f "scan_orange_brut.txt" ]; then
    rm scan_orange_brut.txt
    echo "[-] Fichier brut Orange supprimé."
fi

if [ -f "scan_mtn_brut.txt" ]; then
    rm scan_mtn_brut.txt
    echo "[-] Fichier brut MTN supprimé."
fi

# 3. Vérification de l'espace disque restant
echo "[+] Espace disque actuel sur Termux :"
df -h . | awk 'NR==1 || NR==2'

echo "[+] Nettoyage terminé. Vos scripts (.sh) et listes de sous-domaines (.txt) sont intacts !"
