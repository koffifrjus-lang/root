# 🛡️ Audit de Sécurité Réseau & Analyse de Vulnérabilités (Côte d'Ivoire)

Ce projet implémente un pipeline d'automatisation d'audit de sécurité réseau en Bash sous environnement Termux. Il permet de centraliser, d'analyser et de classifier de manière autonome les vulnérabilités d'infrastructure (certificats SSL/TLS, protocoles d'administration et versions logicielles obsolètes) pour les trois principaux opérateurs de télécommunications en Côte d'Ivoire : **Orange, MTN et Moov**.

Le script est conçu pour fonctionner de manière performante en mode **100% hors-ligne**, assurant la continuité des opérations d'analyse et de mise en forme même en situation de connectivité réseau dégradée ou instable.

---

## 📂 Architecture du Projet Local

L'arborescence des fichiers au sein du dossier de travail `~/dossier_restaure` se structure comme suit :

*   **`analyser_alertes_global.sh`** : Script principal d'ingestion et d'analyse sémantique. Il parse les fichiers sources, extrait les hôtes/IP, classifie le niveau de gravité selon les standards de sécurité et génère le rapport formaté.
*   **`generer_remediation.sh`** : Script secondaire qui consomme le livrable final pour générer un plan de remédiation technique trié par ordre d'urgence opérationnelle.
*   **`scan_brut.txt`** : Base de données textuelle locale contenant l'historique brut des relevés d'infrastructure et les sorties de scans Nmap.
*   **`transcript.html`** : Fichier historique de transcription de session utilisé comme source d'extraction alternative pour reconstruire les bases de données corrompues.
*   **`.gitignore`** : Fichier de configuration Git excluant les fichiers temporaires de traitement (`Rapport_tmp.txt`, etc.) du suivi de version.

---

## 📊 Matrice de Classification des Risques

Le système de classification est calqué sur les standards industriels (CVSS/NIST) et utilise un affichage en texte brut universel pour garantir une compatibilité d'affichage absolue sur tous les éditeurs mobiles :

| Identifiant | Gravité | Déclencheur Technique | Conséquence & Impact | Action / Remédiation |
| :--- | :--- | :--- | :--- | :--- |
| **`SSL-EXPIRED`** | `[CRITIQUE]` | Certificat SSL/TLS expiré (2023-2026) | Interception des flux (MITM) et usurpation d'identité. | Renouvellement immédiat auprès d'une autorité de certification. |
| **`TELNET-OPEN`** | `[CRITIQUE]` | Port 23/TCP détecté à l'état `open` | Administration en texte clair. Vol d'identifiants réseau. | Désactivation du service et migration obligatoire vers SSH. |
| **`TLS-WARN-EXP`** | `[ELEVE]` | Expiration SSL/TLS imminente en 2026 | Interruption prochaine des services applicatifs ou web. | Planification du renouvellement du certificat sous 30 jours. |
| **`SRV-OBSOLETE`** | `[ELEVE]` | Version Apache 2.2 ou Nginx 1.1x détectée | Exposition à des CVEs publiques d'exécution de code ou DoS. | Mise à niveau immédiate vers les branches stables (Apache 2.4.x / Nginx 1.26+). |
| **`NET-SSH-EXPOSED`** | `[MOYEN]` | Port 22/TCP exposé publiquement | Cible privilégiée pour les attaques de force brute automatisées. | Restriction d'accès IP (Whitelisting) et authentification par clés privées. |
| **`SSL-VALID`** | `[FAIBLE]` | Certificat actif et valide au-delà de 2026 | Chiffrement robuste et conforme aux politiques de sécurité. | Aucune action requise. Surveillance et audit de routine. |

---

## 🚀 Utilisation et Déploiement Local

### 1. Exécution de l'audit complet
Pour analyser la base de données locale et régénérer le rapport tabulaire mis en forme, lancez :
```bash
./analyser_alertes_global.sh
```

### 2. Consultation du livrable visuel
Le rapport final structuré en colonnes alignées est exporté directement dans l'espace de stockage partagé de votre appareil Android. Vous pouvez le consulter à l'écran via :
```bash
cat /sdcard/Download/audit_alertes_general.txt
```

### 3. Génération du plan de remédiation prioritaire
Pour extraire la feuille de route des correctifs triée par urgence opérationnelle, exécutez :
```bash
./generer_remediation.sh && cat /sdcard/Download/plan_remediation_prioritaire.txt
```

---

## 🔄 Préparation du Commit pour la Synchronisation GitHub

Pour sauvegarder l'état actuel de votre code et de votre documentation en local dans votre historique Git (en attendant de faire un `git push` vers votre dépôt distant dès le retour d'une connexion internet stable) :

```bash
git add analyser_alertes_global.sh generer_remediation.sh README.md .gitignore
git commit -m "Feat: Finalisation de l architecture d audit hors-ligne multi-operateurs avec standardisation NIST"
```
