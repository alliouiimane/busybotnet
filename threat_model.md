## File: runit/runsvdir.c
- Type: C
- Entrée:
  - Paramètres de démarrage du daemon (nom des services, options de configuration)
  - Variables d'environnement héritées
- Transformation / traitement:
  - Utilise `vfork()` pour créer un processus enfant puis `execlp()` pour remplacer l'image processus par `runsv`.
  - Gère signaux et boucle de création/respawn de services.
- Sortie:
  - Lancement d’un sous-processus `runsv` (service)
  - Logs système / messages d'erreur
- Points de risque:
  - **Usage de `vfork()` + `execlp()`** : exécution de nouveaux binaires — risque d'exécution de code non contrôlé si les arguments ou chemins sont manipulables. — **HIGH**
  - **Possibilité d'injection d'arguments** si des données non-sanitized sont passées au `execlp`. — **HIGH**
  - Si l’exécutable remplacé est compromis, cela permet exécution persistante et élévation locale. — **HIGH**
- Recommandations:
  - Valider strictement tous les chemins et arguments passés à `execlp()` (ne jamais utiliser des chemins fournis par des sources non sûres).
  - Restreindre les droits du processus parent (drop privileges) avant `exec` si possible.
  - Documenter et auditer les binaires appelés (hash + provenance) ; appliquer contrôle de version/approbation pour les binaires.
  - Ajouter checks dans CI (threat model) : signaler tout ajout de `exec*`/`vfork` dans les reviews.

---

## File: runit/chpst.c
- Type: C
- Entrée:
  - Options CLI et variables d'environnement (utilisées pour `chpst`, `setuidgid`, etc.)
- Transformation / traitement:
  - Fournit utilitaires pour changer UID/GID (setuidgid family) et exécuter processus sous d'autres comptes.
  - Inclut opérations sur limites de ressources (`getrlimit`) et changements de contexte utilisateur.
- Sortie:
  - Processus relancé sous un autre UID/GID
  - Logs / codes de retour
- Points de risque:
  - **Manipulation de privilèges (setuidgid)** : si mal contrôlé, peut permettre élévation de privilèges ou exécution sous comptes privilégiés — **HIGH**
  - **Mauvaise validation des arguments** (ex: chemins, comptes) pouvant conduire à exécution non souhaitée — **MED/HIGH**
  - Présence de `#include <sys/resource.h>` et usage de limites -> risque d'abus si les ressources sont mal configurées — **MED**
- Recommandations:
  - Restreindre qui peut invoquer ces utilitaires (RBAC / ACL).
  - Valider l'existence et la propriété des comptes avant de faire setuid/setgid.
  - Ajouter tests statiques / revue stricte pour toute modification de code manipulant UID/GID.
  - Documenter le flux d'autorisations (qui peut démarrer quoi) dans `security_playbook.md`.
## File: runit/runsvdir.c
- Type: C
- Entrée:
  - Paramètres de démarrage du daemon (nom des services, options de configuration)
  - Variables d'environnement héritées
- Transformation / traitement:
  - Utilise `vfork()` pour créer un processus enfant puis `execlp()` pour remplacer l'image processus par `runsv`.
  - Gère signaux et boucle de création/respawn de services.
- Sortie:
  - Lancement d’un sous-processus `runsv` (service)
  - Logs système / messages d'erreur
- Points de risque:
  - **Usage de `vfork()` + `execlp()`** : exécution de nouveaux binaires — risque d'exécution de code non contrôlé si les arguments ou chemins sont manipulables. — **HIGH**
  - **Possibilité d'injection d'arguments** si des données non-sanitized sont passées au `execlp`. — **HIGH**
  - Si l’exécutable remplacé est compromis, cela permet exécution persistante et élévation locale. — **HIGH**
- Recommandations:
  - Valider strictement tous les chemins et arguments passés à `execlp()` (ne jamais utiliser des chemins fournis par des sources non sûres).
  - Restreindre les droits du processus parent (drop privileges) avant `exec` si possible.
  - Documenter et auditer les binaires appelés (hash + provenance) ; appliquer contrôle de version/approbation pour les binaires.
  - Ajouter checks dans CI (threat model) : signaler tout ajout de `exec*`/`vfork` dans les reviews.

---

## File: runit/chpst.c
- Type: C
- Entrée:
  - Options CLI et variables d'environnement (utilisées pour `chpst`, `setuidgid`, etc.)
- Transformation / traitement:
  - Fournit utilitaires pour changer UID/GID (setuidgid family) et exécuter processus sous d'autres comptes.
  - Inclut opérations sur limites de ressources (`getrlimit`) et changements de contexte utilisateur.
- Sortie:
  - Processus relancé sous un autre UID/GID
  - Logs / codes de retour
- Points de risque:
  - **Manipulation de privilèges (setuidgid)** : si mal contrôlé, peut permettre élévation de privilèges ou exécution sous comptes privilégiés — **HIGH**
  - **Mauvaise validation des arguments** (ex: chemins, accounts) pouvant conduire à exécution non souhaitée — **MED/HIGH**
  - Présence de `#include <sys/resource.h>` et usage de limites -> risque d'abus si les ressources sont mal configurées — **MED**
- Recommandations:
  - Restreindre qui peut invoquer ces utilitaires (RBAC / ACL).
  - Valider l'existence et la propriété des comptes avant de faire setuid/setgid.
  - Ajouter tests statiques / revue stricte pour toute modification de code manipulant UID/GID.
  - Documenter le flux d'autorisations (qui peut démarrer quoi) dans `security_playbook.md`.

## File: scripts/sshscanner.sh
- Type: shell
- Entrée:
  - Arguments CLI : cible(s) IP / plages / ports
  - Fichiers d'input éventuels (liste d'hôtes)
- Transformation / traitement:
  - Boucle sur cibles et lancement d'outils de scan (ex: nmap, nc, masscan)
  - Parse des résultats pour générer rapports
- Sortie:
  - Logs stdout, potentiellement fichiers de rapport dans /tmp ou dossier du repo
  - Potentielle exfiltration ou envoi vers serveur distant si configuré
- Points de risque:
  - **Network scanning** (nmap/masscan) — usage non autorisé / répercussion légale — **HIGH**
  - **Commande construite dynamiquement** (ex: `nmap $ARGS`) — risque d'injection de commande si args non validés — **HIGH**
  - **Envoi de résultats à distance** (curl|nc) sans chiffrement — fuite d'information — **MED**
- Recommandations:
  - Valider strictement les IP/plages et les ports (regex + limites).
  - Éviter les constructions `eval` ou concatenation non-sûre ; utiliser tableaux/param passing.
  - Empêcher l'envoi de données à l'extérieur (désactiver dans CI / analysis VM).
  - Documenter usage responsable et ajouter notice/legal header.

---

## File: src/nc.c (ou applet 'nc')
- Type: C (client réseau)
- Entrée:
  - Options CLI : host, port, options de connexion
- Transformation / traitement:
  - Création de sockets, connect(), send/recv
  - Possiblement mode server/listen
- Sortie:
  - Connexions réseau TCP/UDP, transferts de données
- Points de risque:
  - **Sockets non chiffrés** et transfert en clair — risque d'interception — **MED**
  - **Fonctions réseau exposées** : si appelable depuis d'autres applets, risque d'abus (reverse shell) — **HIGH**
  - **Absence de validation** sur host/port -> injection ou redirection — **MED**
- Recommandations:
  - Documenter les usages et limiter l'exposition (ne pas lier au démarrage automatique).
  - Éviter d'exposer des options permettant execution de code distant.
  - Ajouter commentaire/alertes dans `triage.md` pour toute appelabilité externe.

---

## File: binaries/cpuminer-* (ou cpuminer applet)
- Type: third-party binary (miner)
- Entrée:
  - Config (pool, utilisateur, options)
- Transformation / traitement:
  - Lancement d'un processus de minage intensif CPU/GPU
  - Connexion à pool externe
- Sortie:
  - Charge CPU élevée, trafic vers pool, logs
- Points de risque:
  - **Usage malveillant (cryptomining)** — sur machines d'utilisateurs → **HIGH**
  - **Hardcoded pool/credentials** dans distrib et risque d'abus — **HIGH**
  - **Exécution persistante** si bootstrapé — **HIGH**
- Recommandations:
  - Mettre en quarantaine (déjà fait) et documenter provenance + licence.
  - Ne pas inclure binaire dans release safe; ajouter placeholder et hash source.
  - Si nécessaire, exécuter seulement dans VM build isolée et sur consentement explicite.

---

## File: scripts/install.sh / fjME / add.sh (install/build helpers)
- Type: shell
- Entrée:
  - Aucun/arguments d'installation
- Transformation / traitement:
  - Téléchargement, compilation, copie de binaires, modification permissions
- Sortie:
  - Artefacts build, installation de binaires
- Points de risque:
  - **Téléchargement automatique (curl|wget)** puis `| sh` ou exécution — **HIGH**
  - **Modification de permissions (chmod 777)** — risque d'élévation non contrôlée — **HIGH**
  - **Scripts qui compilent et installent sans checks d'intégrité** — **MED/HIGH**
- Recommandations:
  - Remplacer `curl | sh` par téléchargement + vérification de signature/hash avant exécution.
  - Ne pas appliquer permissions 777; utiliser permissions minimales.
  - Ajouter étapes manuelles dans documentation : « review before run ».

---

## File: applets/* (hydra, masscan, netscan, ssyn2, sudp)
- Type: C / applets réseau / outils offensifs
- Entrée:
  - CLI arguments, listes de cibles
- Transformation / traitement:
  - Brute-force (hydra), scan massifs (masscan), DDoS primitives (ssyn2/sudp)
- Sortie:
  - Trafics agressifs vers cibles, logs
- Points de risque:
  - **Outils offensifs intégrés** — utilisation offensive possible → responsabilité légale & éthique — **CRITICAL**
  - **Intégration dans repo** facilite usage malveillant — **CRITICAL**
- Recommandations:
  - Retirer/mettre en quarantaine tous les outils offensifs dans release safe.
  - Ajouter notices légales et policy d'usage dans README.
  - Bloquer leur présence via CI (workflow déjà en place).

