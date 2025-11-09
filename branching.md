# Stratégie de branches et release process

## Branches principales
- main : branche stable, prête pour release.
- develop : développement actif.
- safe-mode : branche pour analyses sécurisées / corrections critiques.

## Processus de travail basique
1. Créer une branche feature depuis develop:
   git checkout -b feature/<nom>
2. Pousser la branche et faire la PR vers develop.
3. Revue par au moins 1 reviewer.
4. Merge dans develop.
5. Quand develop est stable, créer une release branch et bump VERSION + CHANGELOG, puis merge dans main.

## Pull Request Template (résumé)
- Titre : feat|fix(scope): courte description
- Description : détails, motivation, tests réalisés
- Impact sécurité : oui/non (si oui détailler)
- Checklist : tests passés, changelog mis à jour

## Bonnes pratiques
- Commits atomiques, messages clairs.
- Mise à jour du CHANGELOG avant merge de release.
- Ne pas inclure de binaires dans les releases (quarantine them).
