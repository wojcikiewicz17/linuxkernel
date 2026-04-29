# Android Native Module (isolado)

Este diretório é isolado (`android-native/`) para não interferir no Kbuild do kernel.

## Requisitos locais

- JDK 17+
- Android SDK + NDK `26.3.11579264`
- CMake `3.22.1` no Android SDK
- Gradle wrapper (gerar com `gradle wrapper` dentro de `android-native/`)

## Matriz ABI

- `armeabi-v7a`
- `arm64-v8a`

## Build local

No diretório `android-native/`:

```bash
./gradlew :app:assembleDebug
./gradlew :app:assembleRelease
```

Para release assinado via variáveis de ambiente (mesmo fluxo do CI):

```bash
export ANDROID_KEYSTORE_PATH=/caminho/keystore.jks
export ANDROID_KEYSTORE_PASSWORD='***'
export ANDROID_KEY_ALIAS='***'
export ANDROID_KEY_PASSWORD='***'
./gradlew :app:assembleRelease
```

Sem essas variáveis, `release` é gerado unsigned (para validação interna).

## Artefatos gerados

- Debug unsigned:
  - `app/build/outputs/apk/debug/app-debug.apk`
- Release unsigned:
  - `app/build/outputs/apk/release/app-release-unsigned.apk`
- Release assinado (quando secrets/keystore configurados):
  - `app/build/outputs/apk/release/app-release.apk`

## CI / GitHub Actions

O workflow em `.github/workflows/android-native.yml` executa:

1. `assembleDebug`
2. `assembleRelease` unsigned
3. `assembleRelease` assinado (se secrets presentes)
4. Upload dos APKs como artifacts

Secrets esperados para assinatura no CI:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
