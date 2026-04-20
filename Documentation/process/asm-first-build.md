# ASM-first build profile (no external deps, sem quebrar)

Este perfil **não converte o kernel inteiro para ASM** (inviável sem quebrar ABI, drivers e subsistemas),
mas aplica o limite seguro possível para:

- priorizar caminhos nativos/baixo nível;
- reduzir fricção de toolchain;
- manter build reprodutível;
- não enfraquecer a trilha oficial de release.

## O que o helper faz

O helper `scripts/asm-first-build.sh`:

1. seleciona uma `defconfig` explícita da arquitetura alvo;
2. gera um fragmento Kconfig ASM-first mínimo;
3. aplica o fragmento com `merge_config.sh` preservando pipeline oficial;
4. roda `olddefconfig` para coerência final;
5. em `MODE=build`, gera `vmlinux`;
6. gera `build.log` e `artifacts.txt` para integração de CI/upload.

Fragmento aplicado:

- `CONFIG_MODULES=n`
- `CONFIG_BPF_JIT=n`
- `CONFIG_FTRACE=n`
- `CONFIG_UPROBES=n`

## Entradas e saídas

Variáveis suportadas:

- `ARCH` (default: `x86_64`)
- `JOBS` (default: `nproc`)
- `OUT_DIR` (default: `out/asm-first`)
- `DRY_RUN` (`0|1`)
- `MODE` (`build|prepare`)
- `KEEP_FRAGMENT` (`0|1`)

Artefatos produzidos em `OUT_DIR`:

- `.config`
- `build.log`
- `artifacts.txt`
- `vmlinux` e `System.map` (quando `MODE=build`)

## Uso

### Build completa x86_64

```bash
scripts/asm-first-build.sh
```

### Somente preparação de config

```bash
MODE=prepare scripts/asm-first-build.sh
```

### Dry-run

```bash
DRY_RUN=1 scripts/asm-first-build.sh
```

### arm64

```bash
ARCH=arm64 scripts/asm-first-build.sh
```

## CI recomendado

Use `.github/workflows/asm-first-kernel.yml` para:

- instalar dependências de build (`flex`, `bison`, `bc`, `libelf-dev`, `libssl-dev`);
- executar build ASM-first em pipeline limpa;
- publicar `build.log`, `.config`, `vmlinux` e `System.map` como artifact.

## Escopo e limite

- Este perfil é incremental e reversível.
- A fonte de verdade continua sendo Kconfig/Makefile oficial.
- Objetivo: **empurrar o sistema para o limite ASM/baixo nível possível sem quebrar**,
  em vez de forçar reescrita total insegura.
