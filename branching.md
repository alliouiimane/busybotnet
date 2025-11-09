# Branching Strategy

## Branches
- main : stable release
- develop : développement principal
- safe-mode : test release avant merge sur main

## Release Process
1. Bump VERSION
2. Update CHANGELOG.md
3. Commit & push safe-mode
4. Open PR vers develop/main
5. Merge après validation

## PR Templates
- Title
- Description
- Checklist

