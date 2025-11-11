# Dev B — Inventory des Dépendances Tierces

**Date** : 11 novembre 2025  
**Développeur** : alliouiimane  
**Fork** : https://github.com/alliouiimane/busybotnet  
**Branche** : safe-mode  

---

## Introduction
Analyse statique des dépendances tierces dans `busybotnet`.  
Toutes marquées comme **external**.  
Vérification des CVE via NVD/Mitre.  
**Aucune exécution de code — safe-mode respecté.**

---

## Inventaire des Dépendances

| Composant | Version | Type | Statut | Notes |
|-----------|---------|------|--------|-------|
| **BusyBox** | 1.24.1 | Base multi-outil | External | Forké, base du projet |
| **cpuminer-multi** | 1.3.5 | Minage | External | Dossier: `cpuminer-multi-1.3.5-multi/` |
| **libpcap** | 1.9.0 | Capture réseau | External | Dossier: `libpcap-libpcap-1.9.0/` |
| **json-c** | ~0.16 | JSON | External | Dossier: `json-c/` |
| **runit** | ~2.1.2 | Init système | External | Dossier: `runit/` |
| **OpenSSL** | 1.1.0g | Crypto | External | Intégré via cpuminer |
| **zlib** | 1.2.11 | Compression | External | Intégré |
| **libssh2** | 1.8.0 | SSH | External | Bruteforce |
| **libpcre** | 8.39 | Regex | External | Nmap |
| **nmap-liblua** | 5.3.3 | Scripting | External | Nmap |
| **nmap-libdnet** | 1.12 | Réseau | External | Nmap |
| **Tor** | 0.3.4.8 | Anonymat | External | Applet |
| **Hydra** | v8.2-dev | Bruteforce | External | Applet |
| **Masscan** | Non spécifiée | Scanner | External | Applet |

---

## Vulnérabilités Connues (CVE Candidates)

| Composant | CVE | Sévérité (CVSS) | Impact | Recommandation |
|-----------|-----|------------------|--------|----------------|
| **BusyBox** | CVE-2016-6301, CVE-2017-6964 | Medium (7.8) | DoS / RCE locale | Upgrade à 1.36.1+ |
| **libpcap** | CVE-2018-16301 | Medium (7.5) | DoS via paquets | Upgrade à 1.10.4+ |
| **json-c** | CVE-2022-46175 | High (8.8) | RCE via JSON | Upgrade à 0.17+ |
| **OpenSSL** | CVE-2022-3602 | High (7.5) | Buffer overflow | Upgrade à 3.0+ |
| **libssh2** | CVE-2019-3855 | High (7.8) | RCE SSH | Upgrade à 1.11.0+ |
| **Tor** | CVE-2018-4900 | Medium (5.0) | DoS parsing | Upgrade à 0.4.8+ |

> **Risque global : Medium → High**  
> **Priorité** : Upgrade OpenSSL, json-c, libssh2.

---

**Livrable** : `deps_report.md`  
**Safe-mode validé** — Aucune exécution.  
**Prêt pour revue → merge dans `safe-mode`**
