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

O workflow em `.github/workflows/android-native.yml` executa em jobs separados:

1. `build-debug` (matriz ABI: `armeabi-v7a` e `arm64-v8a`)
2. `build-release-unsigned` (trilha interna de validação, matriz ABI)
3. `build-release-signed` (somente trilha oficial e com assinatura obrigatória)
4. Upload explícito de APKs versionados por commit/tag via `actions/upload-artifact`

Secrets esperados para assinatura no CI:

- `KEYSTORE_BASE64`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `STORE_PASSWORD`

Se a assinatura falhar, o job `build-release-signed` falha e bloqueia a promoção da release oficial.
