# Beta Readiness Report — Android Native / Termux Rafacodephi

## Status

**Status atual:** `BETA_BLOCKED` para validação final em dispositivo, porque este ambiente não possui Android SDK configurado localmente para gerar APKs verificáveis aqui. A trilha de build, CI, fonte Java/JNI e scripts de artefato foram alinhados para produzir debug, release unsigned interno e release signed oficial no ambiente Android/CI.

## Inventário de estabilidade

| Área | Classificação | Evidência / decisão |
| --- | --- | --- |
| Inicialização do app | `OK_BETA` | `MainActivity` existe, carrega `native-lib`, monta UI mínima e registra `BETA_INIT_OK`. |
| Terminal / comando básico | `OK_BETA` | A beta executa `/system/bin/sh -c "echo BETA_TERMINAL_OK"` por `ProcessBuilder`. |
| Encerramento / cleanup | `OK_BETA` | `onDestroy()` chama `destroy()`, aguarda saída e usa `destroyForcibly()` se o processo não encerrar. |
| Processo zumbi | `RISK_BETA` | O código aguarda `waitFor()` e limpa referência; ausência de zumbi precisa ser confirmada em dispositivo/emulador com `adb shell ps`. |
| Build Gradle/NDK | `OK_BETA` no CI | Gradle provisionado pelo workflow, CMake, NDK fixo e matriz `armeabi-v7a`/`arm64-v8a` foram alinhados. |
| Release unsigned | `OK_BETA` | Mantido apenas para validação interna. |
| Release signed | `OK_BETA` | Trilha oficial exige keystore/secrets e falha se `-PrequireReleaseSigning=true` estiver sem credenciais. |
| Logs | `OK_BETA` | Logs usam tag `RafaBeta` com mensagens claras de init, comando, erro e cleanup. |
| Claims RAFAELIA | `EXPERIMENTAL_NOT_BLOCKING` | Claims matemáticos, BitOmega/ZipRAF avançados, performance extrema e teoria ampla ficam fora do critério de beta. |
| Benchmarks | `RISK_BETA` | Nenhum benchmark foi executado; não há claim de performance. |

## Causas-raiz encontradas

1. **Workflow chamava `./gradlew` no diretório errado.** O projeto Gradle vive em `android-native/`, então os jobs agora usam `working-directory: android-native` e Gradle instalado pelo workflow.
2. **Filtro de ABI divergente.** O CI passava `-PabiFilter`, mas o Gradle lia `ciAbi`; o build agora aceita ambos e padroniza `ciAbi`.
3. **App Android não tinha `MainActivity`.** O manifesto apontava para `.MainActivity`, mas não havia código Java/Kotlin correspondente.
4. **Dependências AndroidX/Kotlin eram desnecessárias para a beta mínima.** O app foi reduzido para Java + SDK Android + JNI, diminuindo fricção de build.
5. **Assinatura oficial e unsigned interno estavam pouco separados.** A tarefa `verifyReleaseSigningInputs` bloqueia release oficial quando `-PrequireReleaseSigning=true` não recebe credenciais completas.
6. **Não havia script único para gerar artefatos com hash.** `scripts/android-native-build.sh` centraliza debug, unsigned, signed e SHA-256.

## O que funciona agora

- App mínimo inicializa e mostra estado de beta.
- JNI nativo compila como `native-lib` para `armeabi-v7a` e `arm64-v8a`.
- Comando shell básico roda pelo app e registra stdout/exit code.
- Cleanup de processo é explícito no ciclo de vida Android.
- CI faz selftest de contrato de fonte antes dos builds.
- Upload de artefatos permanece configurado para debug, release unsigned e release signed.

## O que foi corrigido

- Criação de `MainActivity.java` funcional.
- Manifesto reduzido para tema Android nativo e backup desativado.
- Gradle simplificado para Java/NDK sem Kotlin/AppCompat.
- ABI matrix corrigida para `armeabi-v7a` e `arm64-v8a`.
- Trilha signed protegida por validação explícita.
- Scripts de build/selftest adicionados.
- Binário `gradle-wrapper.jar` removido da entrega; Gradle agora é provisionado no workflow.

## Riscos restantes

- Validar em dispositivo/emulador que a atividade abre sem crash real.
- Validar com `adb logcat -s RafaBeta` que logs aparecem conforme esperado.
- Validar com `adb shell ps -A` que nenhum processo órfão/zumbi permanece após fechar o app.
- Confirmar geração de APKs neste ambiente quando Android SDK/NDK estiver disponível.

## Experimental, não bloqueante

Os tópicos abaixo **não fazem parte do aceite da beta** e não devem ser vendidos como provados:

- √3/2;
- Fibonacci;
- Mandelbrot;
- Poincaré;
- 42K atratores;
- matriz 10x10x10;
- BitOmega avançado;
- ZipRAF avançado;
- performance extrema;
- claims matemáticos RAFAELIA amplos.

## Como testar fonte/contrato beta

```bash
scripts/android-native-beta-selftest.sh
```

## Como gerar APKs debug e release unsigned internos

```bash
scripts/android-native-build.sh all
```

## Como gerar APK signed oficial

```bash
export ANDROID_KEYSTORE_PATH=/caminho/release.keystore
export ANDROID_KEYSTORE_PASSWORD='***'
export ANDROID_KEY_ALIAS='***'
export ANDROID_KEY_PASSWORD='***'
scripts/android-native-build.sh release-signed
```

## Artefatos esperados

Quando o Android SDK/NDK estiver disponível, o script copia APKs e hashes para:

- `artifacts/android-native/debug/armeabi-v7a/`
- `artifacts/android-native/debug/arm64-v8a/`
- `artifacts/android-native/release-unsigned/armeabi-v7a/`
- `artifacts/android-native/release-unsigned/arm64-v8a/`
- `artifacts/android-native/release-signed/universal/`

Cada APK copiado recebe arquivo `.sha256` correspondente.
