# Política de Migração de C para Assembly (ARM32/ARM64)

## Objetivo

Estabelecer critérios objetivos e um fluxo seguro para adoção de implementações em assembly sem perda de corretude, portabilidade e mantenabilidade.

## 1) Critérios objetivos para decidir migração C -> ASM

A migração só é permitida quando **todos** os critérios abaixo forem atendidos e documentados:

1. **Custo por ciclo (cycles/op)**
   - Medir baseline em `foo.c` e candidato em `foo_asm.S`.
   - Exigir ganho mínimo de performance estatisticamente estável (ex.: mediana e intervalo de confiança) no hardware-alvo.
   - Registrar variação por microarquitetura (ex.: Cortex-A53, A55, A76).

2. **Frequência de chamada**
   - O trecho deve estar no caminho quente (hot path), com frequência alta o suficiente para impactar throughput/latência global.
   - Priorizar funções no topo de perfilagem (perf/simpleperf) sob carga real.

3. **Impacto p95/p99**
   - A aprovação depende de melhoria em cauda de latência (p95/p99), não apenas média.
   - Rejeitar mudanças com regressão de p95/p99, mesmo com ganho de média.

4. **Estabilidade de ABI**
   - A assinatura pública e o contrato binário devem permanecer estáveis.
   - Mudanças de layout, alinhamento ou convenção que afetem consumidores binários são proibidas sem plano de versionamento.

## 2) Implementação dupla obrigatória

Toda rotina otimizada deve manter:

- `foo.c`: implementação de referência (fonte de verdade funcional).
- `foo_asm.S`: implementação otimizada.

Seleção por arquitetura deve ser explícita no ponto de despacho:

```c
#if defined(__aarch64__) || defined(__arm__)
  return foo_asm(...);
#else
  return foo_c(...);
#endif
```

Regras:
- Em ARM32/ARM64, a versão assembly pode ser habilitada conforme critérios desta política.
- Em qualquer outra arquitetura, fallback C é obrigatório.
- O fallback C **não pode** ser removido enquanto não houver maturidade comprovada.

## 3) Contrato de chamada padronizado (AAPCS)

Toda rotina assembly deve seguir o ABI oficial da plataforma:

- **AAPCS32** para `__arm__` e **AAPCS64** para `__aarch64__`.
- Preservar registradores callee-saved conforme ABI.
- Manter alinhamento de stack conforme requisito da ABI em qualquer ponto de chamada.
- Não clobber registradores/sinalizadores fora do permitido.
- Declarar claramente pré-condições e pós-condições (incluindo alinhamento de ponteiros e aliasing).

Checklist mínimo por rotina:
- Lista de registradores usados/preservados.
- Garantia de prólogo/epílogo válidos.
- Prova de equivalência funcional com implementação C.
- Cobertura de casos de borda.

## 4) Teste de equivalência funcional (obrigatório)

Cada par `foo.c`/`foo_asm.S` deve possuir suíte de equivalência com:

1. **Vetores determinísticos**
   - Entradas fixas versionadas no repositório.
   - Reprodutibilidade entre execuções e CI.

2. **Casos de borda obrigatórios**
   - Overflow/underflow aritmético.
   - Diferentes alinhamentos de memória (incluindo desalinhado quando permitido).
   - Endianness (validação explícita para little-endian e comportamento esperado para demais cenários suportados).
   - Tamanhos extremos (0, 1, N máximo suportado, limites de bloco).

3. **Oráculo de referência**
   - `foo.c` é o oráculo primário.
   - Resultado de `foo_asm.S` deve ser bit-a-bit equivalente (ou dentro de tolerância documentada para ponto flutuante).

## 5) Proibição de substituição total sem maturidade

É proibido substituir totalmente C por ASM sem:

- Benchmark representativo mostrando ganho consistente em cenários reais.
- Regressão funcional zero na suíte determinística.
- Regressão zero em p95/p99 nas cargas-alvo.
- Janela mínima de estabilidade em CI/release (sem flakes atribuíveis ao caminho ASM).

Até cumprir os critérios acima, o caminho C deve permanecer ativo como fallback e referência.

## 6) Requisitos de CI e release

- Executar testes de equivalência em ARM32 e ARM64 sempre que `*.S`, despacho por `#if`, ou contrato ABI forem alterados.
- Publicar artefatos de benchmark e relatório p95/p99 em cada mudança relevante.
- Bloquear merge se houver:
  - quebra de ABI,
  - regressão de corretude,
  - regressão de p95/p99 acima do orçamento definido.
