#!/bin/bash
FICHIER_AUDIT="/sdcard/Download/audit_alertes_general.txt"
FICHIER_PLAN="/sdcard/Download/plan_remediation_prioritaire.txt"

echo "=== PLAN DE REMEDIATION PRIORITAIRE (CYBERSECURITE) ===" > "$FICHIER_PLAN"
echo -e "Généré le : $(date +%Y%m%d)\n" >> "$FICHIER_PLAN"

echo "🚨 [URGENCE ABSOLUE] FAILLES CRITIQUES À CORRIGER SOUS 24H :" >> "$FICHIER_PLAN"
grep "\[CRITIQUE\]" "$FICHIER_AUDIT" >> "$FICHIER_PLAN" || echo "  Aucune faille critique détectée." >> "$FICHIER_PLAN"

echo -e "\n⚠️ [PRIORITÉ HAUTE] EXPIRATIONS ET CLÉS FAIBLES À TRAITER SOUS 7 JOURS :" >> "$FICHIER_PLAN"
grep "\[ELEVE\]" "$FICHIER_AUDIT" >> "$FICHIER_PLAN" || echo "  Aucune faille élevée détectée." >> "$FICHIER_PLAN"

echo -e "\n🛡️ [PRIORITÉ MOYENNE] RECONFIGURATION DES ACCÈS RÉSEAU :" >> "$FICHIER_PLAN"
grep "\[MOYEN\]" "$FICHIER_AUDIT" >> "$FICHIER_PLAN" || echo "  Aucune faille moyenne détectée." >> "$FICHIER_PLAN"

echo -e "\n[+] Plan d action généré avec succès dans : $FICHIER_PLAN"
