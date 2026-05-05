# Inventário Beta — Android Native / Termux Rafacodephi

## Fonte de verdade operacional

| Item | Caminho | Papel |
| --- | --- | --- |
| Projeto Gradle isolado | `android-native/` | Módulo Android fora do Kbuild do kernel. |
| App Android | `android-native/app/src/main/java/com/example/androidnative/MainActivity.java` | UI beta, shell command, logs e cleanup. |
| JNI C | `android-native/app/src/main/cpp/native-lib.c` | Biblioteca nativa mínima carregada pelo app. |
| CMake | `android-native/app/src/main/cpp/CMakeLists.txt` | Build NDK da `native-lib`. |
| Gradle app | `android-native/app/build.gradle.kts` | ABI matrix, assinatura, CMake, selftest. |
| Workflow CI | `.github/workflows/android-native.yml` | Provisiona Gradle/SDK/NDK, gera debug/release unsigned/release signed e faz upload. |
| Build helper | `scripts/android-native-build.sh` | Gera APKs e `.sha256`. |
| Selftest helper | `scripts/android-native-beta-selftest.sh` | Valida contrato beta sem dispositivo. |
| Readiness | `docs/BETA_READINESS_REPORT.md` | Estado, achados, riscos e comandos. |
| Limitações | `docs/BETA_KNOWN_LIMITATIONS.md` | O que não está provado ou implementado. |

## Contrato mínimo da beta

- `BETA_INIT_OK`: app inicializou.
- `BETA_TERMINAL_OK`: shell básico executou e retornou stdout.
- `exit: 0`: comando terminou com sucesso.
- `BETA_CLEANUP_OK`: fluxo limpou processo finalizado.
- Tag de log: `RafaBeta`.

## ABIs oficiais desta beta

- `armeabi-v7a` (arm32)
- `arm64-v8a` (arm64)

## Comandos principais

```bash
scripts/android-native-beta-selftest.sh
scripts/android-native-build.sh debug
scripts/android-native-build.sh release-unsigned
scripts/android-native-build.sh release-signed
```

## Política de claims

Documentação é mapa; código é verdade operacional; teste valida função; benchmark valida quantidade. Tudo que não passou por código, teste e benchmark fica marcado como experimental e não bloqueia a beta mínima.

## Política de artefatos binários

- `gradle-wrapper.jar`, APKs e keystores não são versionados.
- APKs debug, unsigned e signed devem sair do GitHub Actions via `actions/upload-artifact`.
- Hashes `.sha256` são gerados junto com os artifacts no build, não fixados no código-fonte.
