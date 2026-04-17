# Low-level PureASM Roadmap

## Objetivo
Consolidar uma trilha low-level reproduzível (build local + CI) com autodetecção de plataforma e documentação orientada a humanos e agentes.

## Estado atual
- [x] Script central de detecção: `scripts/detect_platform_ids.sh`
- [x] Sample assembly com include gerado: `samples/lowlevel_pureasm/core_engine_modules.S`
- [x] CI para geração + montagem: `.github/workflows/lowlevel-pureasm.yml`
- [x] Documento de mapeamento: `Documentation/lowlevel/platform_ids.rst`

## Próximas entregas
1. [ ] Adicionar teste de regressão do mapeamento em shell (entrada mock -> saída esperada).
2. [ ] Publicar tabela de compatibilidade por arquitetura (x86_64, arm64, riscv64).
3. [ ] Adicionar validação de estilo para docs low-level no workflow.
4. [ ] Incluir versão do contrato de IDs (ex: `PLATFORM_ID_SCHEMA=1`).

## Critério de pronto
- Include `generated/detected.inc` reproduzível em CI.
- Binário objeto montado para o sample.
- Contrato de IDs documentado e versionável.
