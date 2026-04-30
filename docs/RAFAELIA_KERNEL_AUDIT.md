# RAFAELIA Kernel Audit

## Classificação atual
- **Classificação:** fork de pesquisa com componentes não-core de kernel e automação Android.
- **Status de claims privilegiadas:** **não suportado** declarar controle direto de registradores privilegiados, ciclos de CPU, KVM global ou scheduler global sem patch explícito nesses subsistemas.

## Base upstream aproximada
- Repositório apresenta histórico Linux kernel com alterações recentes concentradas em `drivers/iio` e em infraestrutura Android/CI fora do core scheduler/mm.
- A aproximação de upstream deve ser derivada por comparação de merge-base contra árvore Linux oficial antes de qualquer claim de baseline exato.

## Branch atual
- Branch de trabalho: `work`.

## Commits próprios (amostragem recente)
- Mudanças recentes incluem:
  - `ci: harden android native workflow for signed release gating`
  - `ci: harden android native workflow release signing`
  - `ci(android): split native workflow into debug/unsigned/signed release jobs`
  - `Add isolated android-native Gradle/NDK build and CI workflow`
  - `iio: max30100` série de commits em driver específico.

## Subsistemas alterados
- Evidências recentes de alteração em:
  - `drivers/iio/*` (driver MAX30100)
  - `.github/workflows/*` (CI Android)
  - árvore `android-native/*` (Gradle/NDK/JNI)
- Não há evidência, nesta auditoria, de alteração funcional ampla em:
  - `kernel/sched/*` (scheduler core)
  - `mm/*` (memory management core)
  - `arch/*/kvm/*` (KVM)

## Relação com scheduler, memory, KVM, ARM, tracing, security
- **Scheduler:** sem patch core confirmado nesta auditoria.
- **Memory management (mm):** sem patch core confirmado nesta auditoria.
- **KVM:** sem patch core confirmado nesta auditoria.
- **ARM:** há contexto Android/NDK e possíveis ajustes de driver/ABI, mas isso não implica controle de registradores privilegiados.
- **Tracing/Security:** sem alterações core de tracing/security confirmadas nesta auditoria.

## Conclusão objetiva
- O fork deve ser tratado como **base de pesquisa/referência** até prova de patches reais em subsistemas core (scheduler/mm/kvm/security/tracing).
- Claims de “controle de baixo nível privilegiado” exigem patchset verificável no kernel core e validação reprodutível.
