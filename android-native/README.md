# Android Native Module (isolado)

Este diretório é isolado (`android-native/`) para não interferir no Kbuild do kernel. A beta atual é uma versão pequena, honesta e funcional: abrir app, carregar JNI, executar um comando shell básico, registrar logs e limpar processo no ciclo de vida Android.

## Requisitos locais

- JDK 17+
- Android SDK + NDK `26.3.11579264`
- CMake `3.22.1` no Android SDK
- Gradle `8.14.3` instalado localmente ou provisionado pelo workflow com `gradle/actions/setup-gradle`

## Matriz ABI

- `armeabi-v7a` (arm32)
- `arm64-v8a` (arm64)

## Selftest beta sem dispositivo

No diretório raiz do repositório:

```bash
scripts/android-native-beta-selftest.sh
```

Ou diretamente em `android-native/`:

```bash
gradle --no-daemon :app:betaSourceSelfTest
```

## Build local

No diretório raiz do repositório:

```bash
scripts/android-native-build.sh debug
scripts/android-native-build.sh release-unsigned
```

Ou diretamente em `android-native/`:

```bash
gradle --no-daemon clean :app:assembleDebug -PciAbi=armeabi-v7a
gradle --no-daemon clean :app:assembleDebug -PciAbi=arm64-v8a
gradle --no-daemon clean :app:assembleRelease -PciAbi=armeabi-v7a
gradle --no-daemon clean :app:assembleRelease -PciAbi=arm64-v8a
```

## Release assinado oficial

Release oficial não deve ser transformado em unsigned por conveniência. Para assinar via variáveis de ambiente:

```bash
export ANDROID_KEYSTORE_PATH=/caminho/keystore.jks
export ANDROID_KEYSTORE_PASSWORD='***'
export ANDROID_KEY_ALIAS='***'
export ANDROID_KEY_PASSWORD='***'
scripts/android-native-build.sh release-signed
```

A trilha signed também aceita propriedades injetadas do Android Gradle Plugin e falha quando `-PrequireReleaseSigning=true` é usado sem credenciais completas.

## Artefatos gerados

Gradle gera:

- Debug:
  - `app/build/outputs/apk/debug/app-debug.apk`
- Release unsigned interno:
  - `app/build/outputs/apk/release/app-release-unsigned.apk`
- Release assinado oficial:
  - `app/build/outputs/apk/release/app-release.apk`

O helper `scripts/android-native-build.sh` copia APKs e hashes SHA-256 para:

- `artifacts/android-native/debug/<abi>/`
- `artifacts/android-native/release-unsigned/<abi>/`
- `artifacts/android-native/release-signed/universal/`

## CI / GitHub Actions

O workflow em `.github/workflows/android-native.yml` executa em jobs separados:

1. `build-debug` (matriz ABI: `armeabi-v7a` e `arm64-v8a`)
2. `build-release-unsigned` (trilha interna de validação, matriz ABI)
3. `build-release-signed` (somente em tag e com assinatura obrigatória)
4. Upload explícito de APKs versionados por commit/tag via `actions/upload-artifact`

Secrets esperados para assinatura no CI:

- `KEYSTORE_BASE64`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `STORE_PASSWORD`

Se a assinatura falhar, o job `build-release-signed` falha e bloqueia a promoção da release oficial.

## Limite de escopo

Claims RAFAELIA amplos, √3/2, Fibonacci, Mandelbrot, Poincaré, 42K, matriz 10x10x10, BitOmega/ZipRAF avançados e performance extrema são `EXPERIMENTAL_NOT_BLOCKING` nesta beta.

## Política de binários no repositório

Arquivos binários de toolchain, como `gradle-wrapper.jar`, APKs e keystores, não são versionados nesta árvore. O workflow instala Gradle/SDK/NDK no runner e publica APKs exclusivamente como artifacts do GitHub Actions.
