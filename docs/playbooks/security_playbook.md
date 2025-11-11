# Security Playbook — BusyBotnet (safe-mode)

**Version** : 1.0  
**Date** : 11 novembre 2025  
**Auteur** : Dev D (alliouiimane)  
**Branche** : `safe-mode`  

---

## 1. Traitement d’un binaire tiers

1. `file bin` → type  
2. `strings bin | grep version` → version  
3. `sha256sum bin` → hash  
4. Recherche CVE → [NVD](https://nvd.nist.gov)  
5. Ajouter à `deps_report.md` → `external`

---

## 2. Mise à jour d’un composant

```bash
git checkout -b fix/<nom>-cve
rm -rf old/
wget <nouvelle_version>
sha256sum -c *.sha256
mv ... new-dir/
git commit -m "fix: upgrade <nom> to vX.Y (CVE-XXXX)"
