# Threat Model – busybotnet (extraction depuis suspicious_hits.csv)
_Remarque : analyse statique, aucune exécution._

---

## File: runit/runsv.c
- Type: C
- Entrée:
  - Paramètres de supervise (nom du service, fichiers supervise/*)
  - Signaux du système (arrêt/restart)
- Transformation / traitement:
  - Ouvre/écrit des fichiers de statut (`supervise/pid.new`, `supervise/stat.new`, `supervise/status.new`)
  - Utilise `vfork()` pour fork/respawn et `sprintf`/`strcpy` pour construire chaînes
  - Supprime (`unlink`) des fichiers temporaires et gère états de supervise
- Sortie:
  - Fichiers de supervision mis à jour (pid, status)
  - Lancement/respawn des services
- Points de risque:
  - **Opérations sur fichiers (open_trunc_or_warn, unlink)** : risque de TOCTOU (Time-of-check-to-time-of-use) si des chemins sont contrôlables — **MED/HIGH**
  - **Usage de `strcpy` / `sprintf`** sans vérification : débordement mémoire — **HIGH**
  - **Usage de `vfork()`** : exécution de nouveaux processus — risque si arguments non validés — **HIGH**
  - **Manipulation des signaux** : mauvaise gestion -> zombies ou comportement non stable — **MED**
- Recommandations:
  - Remplacer `strcpy`/`sprintf` par `strncpy`/`snprintf` et vérifier tailles.
  - Canoniser et vérifier owner/perms des chemins avant écriture.
  - Utiliser écriture atomique (tempfile + rename) au lieu de open_trunc/unlink.
  - Intégrer checks SAST ciblés (cppcheck / clang-tidy).

---

## File: runit/runsvdir.c
- Type: C
- Entrée:
  - Paramètres de démarrage du daemon (nom des services, options)
  - Variables d'environnement héritées
- Transformation / traitement:
  - Boucle de création/respawn de services
  - Gestion des signaux
  - Appel de `vfork()` puis `execlp()` pour lancer l’applet `runsv`
- Sortie:
  - Lancement des sous-processus `runsv`
  - Logs, états de supervise
- Points de risque:
  - **vfork + execlp** : exécution de binaire externe — **HIGH**
  - **Injection d’arguments** si valeurs non-sanitized — **HIGH**
  - **Respawn non contrôlé** -> potential DoS local / forks zombies — **MED**
- Recommandations:
  - Valider strictement chemins/arguments (no user-provided raw strings).
  - Réduire privilèges avant exec si possible.
  - Ajouter audit (hash/ provenance) des binaires lancés.

---

## File: runit/chpst.c
- Type: C
- Entrée:
  - Options CLI et variables d'environnement (utilisées pour chpst, setuidgid)
- Transformation / traitement:
  - Change UID/GID (`xsetuid`/`xsetgid`), applique limites systèmes (`getrlimit`)
  - Log via `bb_error_msg`
- Sortie:
  - Processus démarré sous un autre UID/GID
  - Codes de retour / logs
- Points de risque:
  - **Élévation de privilèges si validation insuffisante** — **HIGH**
  - **Mauvaise validation d’arguments** (comptes, chemins) — **MED/HIGH**
  - **Mauvaises limites RLIMIT** -> DoS ou crash — **MED**
- Recommandations:
  - Restreindre invocation (ACL / RBAC).
  - Vérifier existence/propriété des comptes avant setuid/setgid.
  - Ajouter tests statiques + revue stricte sur modifications.

---

## File: scripts/sshscanner.sh
- Type: Shell
- Entrée:
  - Cible(s) IP / plage / ports / fichiers de liste
- Transformation / traitement:
  - Construit commandes (nmap, nc, masscan), boucle sur cibles, parse résultats
- Sortie:
  - Logs / fichiers de rapport / potentiellement exfiltration
- Points de risque:
  - **Network scanning** — usage non autorisé / légal → **HIGH**
  - **Construction dynamique de commandes** -> injection commande — **HIGH**
  - **Envoi de résultats à distance** non chiffré — **MED**
- Recommandations:
  - Valider IP/port (regex + limites).
  - Éviter `eval` et pipes non filtrés.
  - Bloquer envoi externe en mode analysis VM.

---

## File: src/nc.c (applet nc)
- Type: C (client TCP/UDP)
- Entrée:
  - host, port, flags
- Transformation / traitement:
  - socket(), connect(), send/recv, possible listen mode
- Sortie:
  - Connexions TCP/UDP et transfert de données
- Points de risque:
  - **Reverse/forward shell potentiel** — **HIGH**
  - **Transfert non chiffré** — **MED**
  - **Arg parsing non validé** — **MED**
- Recommandations:
  - Documenter et restreindre exposition (ne pas lancer automatiquement).
  - Désactiver options dangereuses dans release safe.

---

## File: binaries/cpuminer-* (miner)
- Type: Third-party binary (miner)
- Entrée:
  - pool config / credentials
- Transformation / traitement:
  - Processus de minage intensif, connexion pool
- Sortie:
  - Charge CPU, trafic vers pool
- Points de risque:
  - **Usage malveillant (cryptomining)** — **HIGH**
  - **Hardcoded creds / pool** — **HIGH**
  - **Persistant / auto-start** — **HIGH**
- Recommandations:
  - Conserver en `quarantine/`, ne pas inclure dans release safe.
  - Documenter provenance et licence.
  - Si utilisé en build VM, exécuter seulement en environnement isolé.

---

## File: scripts/install.sh / fjME / add.sh
- Type: Shell (installers/build helpers)
- Entrée:
  - Aucun / options
- Transformation / traitement:
  - Téléchargement (curl/wget), compilation, installation, chmod
- Sortie:
  - Binaires et artefacts installés
- Points de risque:
  - **Pipes to shell (curl | sh)** — **HIGH**
  - **chmod 777 / scripts auto-exécutants** — **HIGH**
  - **Téléchargement sans vérif d'intégrité** — **MED/HIGH**
- Recommandations:
  - Remplacer `curl | sh` par téléchargement + vérification signature/hash.
  - Éviter chmod 777 ; appliquer principe de moindre privilège.
  - Documenter étapes manuelles d’exécution après revue.

---

## File: applets/* (hydra, masscan, netscan, ssyn2, sudp)
- Type: C / outils offensifs
- Entrée:
  - CLI args, target lists
- Transformation / traitement:
  - Brute-force (hydra), scans (masscan), DDoS primitives (ssyn2/sudp)
- Sortie:
  - Trafics agressifs vers cibles, logs
- Points de risque:
  - **Outils offensifs intégrés** — usage malveillant & responsabilité légale — **CRITICAL**
  - **Facilite abus** (packaged tools) — **CRITICAL**
- Recommandations:
  - Retirer ou mettre en quarantine ces applets dans release safe.
  - Ajouter notice légale et politique d’usage dans README.
  - Bloquer via CI (workflow) la présence de ces binaires dans artefacts.

---

## Priorisation & next steps (synthèse)
- CRITICAL: applets offensifs (hydra, masscan, ssyn2, sudp) → **quarantine/remove**
- HIGH: exec/vfork usage, setuid/setgid, command-building, miners → **fix / restrict / quarantine**
- MED: file ops (open_trunc/unlink) sans checks, RLIMIT misuse → **code hardening**
- LOW: docs / cosmetic

**Livrables produits**  
- `threat_model.md` (this file) — audit statique synthétique.  
- `prioritized_todos.csv` — à générer automatiquement à partir de `suspicious_hits.csv` (commande fournie ci‑dessous).

---

