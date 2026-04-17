# lowlevel_pureasm

Refatoração para execução em assembly puro, sem dependências externas, sem objetos, sem GC e sem camada de abstração de runtime.

## Estrutura de fluxo
- Fluxo plano por blocos: `ll0` -> `ll1` -> `ll2` -> `ll3` -> `ll4` -> `ll5`.
- Sem função de alto nível; apenas labels e saltos diretos.

## Contrato low-level
- Registradores explícitos: `%eax`, `%ebx`, `%ecx`, `%edx`, `%esi`, `%edi`, `%ebp`.
- Endereços explícitos por constantes: `C0`, `C1`, `C2`, `C3`.
- Autoidentificação por constantes geradas: `D0` (arquitetura), `D1` (SO), `D2` (hardware).
- Escrita/leitura direta em MMIO para direção e saída GPIO.

## Mapeamento usado
- `C0 = 0x40000000` (base MMIO)
- `C1 = 0x0004` (offset direção)
- `C2 = 0x0008` (offset saída)
- `C3 = 3` (bit do pino)

## Autoidentificação de ambiente
- Script local: `detect_env.sh`
- Fonte de verdade: `scripts/detect_platform_ids.sh`
- Saída: `generated/detected.inc`
- IDs numéricos sem strings em runtime:
  - `D0`: arquitetura (`x86_64`, `x86`, `arm64`, `arm`, `riscv64`, `unknown`)
  - `D1`: SO (`Linux`, `Darwin`, `FreeBSD`, `unknown`)
  - `D2`: hardware (`raspberry`, `jetson`, `generic-dt`, `virtual`, `generic-dmi`, `unknown`)

## Build local isolado
- `make -C samples/lowlevel_pureasm generated/detected.inc`
- `gcc -c -x assembler-with-cpp samples/lowlevel_pureasm/core_engine_modules.S -o /tmp/core_engine_modules.o`
