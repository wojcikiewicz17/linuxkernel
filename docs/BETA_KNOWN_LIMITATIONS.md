# Beta Known Limitations — Android Native / Termux Rafacodephi

## Limitações conhecidas da beta

- Esta beta é uma oficina mínima: abre UI, carrega JNI, executa comando shell básico e encerra processo com cleanup explícito.
- Não é uma implementação completa do Termux upstream.
- A beta mínima usa `minSdk = 26` para manter APIs Java de processo (`isAlive`, `destroyForcibly`, `waitFor(timeout)`) coerentes no runtime Android.
- Não instala pacotes, não gerencia repositórios APT e não substitui o runtime completo do Termux.
- O comando validado é simples (`echo BETA_TERMINAL_OK`); comandos interativos e PTY real ainda não estão implementados.
- Ausência de processo zumbi precisa ser validada em dispositivo/emulador Android real.
- Hashes de APK dependem do build executado localmente/CI e não são fixos no repositório.

## Release e assinatura

- APK debug é unsigned/debug para desenvolvimento.
- APK release unsigned é apenas trilha interna de validação.
- Release oficial deve ser signed e falhar quando credenciais não forem fornecidas.
- Keystore real não deve ser versionado no repositório.

## RAFAELIA experimental

Os itens abaixo permanecem como `EXPERIMENTAL_NOT_BLOCKING`:

- √3/2;
- Fibonacci;
- Mandelbrot;
- Poincaré;
- 42K atratores;
- matriz 10x10x10;
- BitOmega avançado;
- ZipRAF avançado;
- ZipRAF/BitRAF com claims de compressão ou performance extrema;
- qualquer claim matemático sem prova, benchmark e teste reprodutível.

## Benchmarks ainda não executados

- Não há benchmark de CPU, memória, I/O, latência, bateria ou throughput.
- Não há comparação contra Termux upstream.
- Não há validação quantitativa para performance extrema.

## Critério para sair de BETA_BLOCKED para BETA_READY

- APK debug gera para `armeabi-v7a` e `arm64-v8a`.
- APK release unsigned interno gera para `armeabi-v7a` e `arm64-v8a`.
- APK release signed oficial gera com keystore real em tag/CI.
- App abre em dispositivo/emulador.
- `BETA_TERMINAL_OK` aparece na UI e em logs.
- Fechar app não deixa processo órfão/zumbi crítico.
