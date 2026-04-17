# lowlevel_pureasm

Refatoração para execução em assembly puro, sem dependências externas, sem objetos, sem GC e sem camada de abstração de runtime.

## Estrutura de fluxo
- Fluxo plano por blocos: `ll0` -> `ll1` -> `ll2` -> `ll3` -> `ll4` -> `ll5`.
- Sem função de alto nível; apenas labels e saltos diretos.

## Contrato low-level
- Registradores explícitos: `%eax`, `%ebx`, `%ecx`, `%edx`, `%esi`.
- Endereços explícitos por constantes: `C0`, `C1`, `C2`, `C3`.
- Escrita/leitura direta em MMIO para direção e saída GPIO.

## Mapeamento usado
- `C0 = 0x40000000` (base MMIO)
- `C1 = 0x0004` (offset direção)
- `C2 = 0x0008` (offset saída)
- `C3 = 3` (bit do pino)

## Build local isolado
- `Makefile` local adicionado para montar objeto com `$(CC)` sem alterar pipeline global.
