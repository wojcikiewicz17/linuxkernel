# lowlevel_pureasm

Escopo: núcleo/engine/módulos em assembly puro, sem dependências externas, sem objetos, sem GC, sem abstrações de alto nível.

## Diretrizes aplicadas
- Fluxo plano por blocos de execução (labels), sem camada de abstração.
- Uso explícito de registradores e endereços mapeados.
- Acesso direto a pino por registrador de I/O mapeado em memória.
- Sem variáveis semânticas de alto nível.

## Mapa mínimo de hardware (exemplo)
- Base MMIO: `0x40000000`
- Offset direção GPIO: `0x0004`
- Offset saída GPIO: `0x0008`
- Pino alvo: bit `3`

## Arquivo principal
- `core_engine_modules.S`: blocos `ll_entry`, `ll_core`, `ll_engine`, `ll_mod0`, `ll_mod1`, `ll_halt`.

Observação: este diretório não altera pipelines existentes; é um núcleo isolado para evolução low-level incremental.
