# Política de Migração C → ASM (ARM32/ARM64)

## Objetivo
Estabelecer critérios objetivos, contrato técnico e fluxo de validação para migração de rotinas críticas de C para Assembly, preservando segurança, portabilidade e regressão zero.

## 1) Critérios objetivos para migrar de C para ASM
A migração só é permitida quando **todos** os critérios abaixo estiverem documentados no PR:

### 1.1 Custo por ciclo (cycles per call)
- Medir baseline em C com benchmark dedicado e reprodutível.
- Medir versão ASM nas mesmas condições (CPU governor fixo quando possível, afinidade de CPU, warmup e amostragem).
- Exigir ganho mínimo de performance:
  - **≥ 12% de redução de ciclos/call** em média, ou
  - **≥ 8% em p95** quando a média for sensível a outliers.
- Reportar também variação (desvio padrão / intervalo de confiança).

### 1.2 Frequência de chamada
- Função candidata deve ter frequência relevante no perfil real:
  - **≥ 1% do tempo total de CPU** do processo **ou**
  - **≥ 100k chamadas/s** em cenário alvo.
- A origem da medição deve ser profiling de carga representativa (produção controlada, staging ou replay confiável).

### 1.3 Impacto de latência (p95/p99)
- A migração deve demonstrar impacto mensurável no caminho de negócio:
  - Redução de latência **p95 ≥ 3%** ou **p99 ≥ 2%**, quando a função participa da trilha crítica.
- Se não houver impacto em p95/p99, a mudança deve ser tratada como opcional e não bloqueia manutenção em C.

### 1.4 Estabilidade de ABI
- Não pode haver quebra de ABI pública/estável.
- Assinatura C (tipos, alinhamento, tamanho de structs expostas) deve permanecer idêntica.
- Qualquer dependência de layout deve ser explicitamente validada por testes de tamanho/alinhamento.

## 2) Implementação dupla obrigatória (referência + otimizada)
Toda função migrada deve manter duas implementações:

- `foo.c`: implementação de referência (fonte da verdade funcional).
- `foo_asm.S`: implementação otimizada (arquitetura específica).

A seleção deve ser feita por compilação condicional:

```c
#if defined(__aarch64__) || defined(__arm__)
    // usar versão ASM
#else
    // usar fallback C
#endif
```

Regras:
- Em ARM32/ARM64, versão ASM pode ser habilitada por padrão após critérios de maturidade.
- Em qualquer arquitetura não suportada, fallback C é obrigatório.
- A versão C nunca deve ser removida enquanto não houver maturidade comprovada.

## 3) Contrato de chamada padronizado (AAPCS)
Toda rotina ASM deve aderir estritamente às convenções AAPCS/AAPCS64:

- Preservação de registradores callee-saved conforme ABI.
- Preservação de `LR` quando aplicável.
- Alinhamento de stack:
  - ARM32: alinhamento conforme AAPCS (8-byte no ponto de chamada).
  - AArch64: stack 16-byte alinhada em fronteiras de chamada.
- Retorno de valores e passagem de argumentos conforme ABI da arquitetura.
- Sem uso de estado global implícito ou side effects não declarados.

Checklist mínimo no código ASM:
- Prólogo/epílogo corretos.
- Clobbers explícitos quando houver inline assembly.
- Comentário com mapeamento de registradores de entrada/saída.

## 4) Teste de equivalência funcional obrigatório
Toda migração C→ASM deve incluir suíte determinística comparando C vs ASM.

Cobertura mínima:
- Vetores de entrada determinísticos (seed fixa).
- Casos de borda:
  - overflow/underflow aritmético esperado.
  - alinhamento e desalinhamento de buffers.
  - endianness (onde aplicável).
  - tamanhos mínimos, máximos e zero-length.
- Comparação bit a bit da saída (ou tolerância formalmente definida para ponto flutuante).

Critérios de aprovação:
- 100% de equivalência nos casos válidos.
- Comportamento de erro idêntico (códigos de retorno, sinalização).
- Regressão zero em testes existentes do módulo.

## 5) Proibição de substituição total sem fallback C
É **proibido** substituir totalmente a implementação C por ASM sem:

1. Benchmark longitudinal comprovando ganho estável.
2. Regressão zero por janela mínima de validação contínua.
3. Evidência de maturidade em múltiplos dispositivos/SoCs ARM32 e ARM64.
4. Aprovação explícita de mantenedores de performance + ABI.

Até cumprir todos os itens acima, fallback C deve permanecer no código e no build.

## 6) Maturidade e rollout
Estados recomendados:

1. **Experimental**: ASM desligado por padrão, validado só em CI/lab.
2. **Canary**: habilitado em fração controlada, monitorando erro e latência.
3. **Default ARM**: habilitado por padrão em `__arm__`/`__aarch64__`, com fallback C preservado.
4. **Mature**: documentação de estabilidade + histórico de regressão zero.

Rollback:
- Deve ser possível desabilitar ASM por flag de build sem alteração funcional externa.

## 7) Evidências mínimas por PR
Cada PR que introduz ou altera ASM deve anexar:
- relatório de benchmark (média, p95, p99, variância).
- resultados de equivalência C vs ASM.
- confirmação de conformidade ABI/AAPCS.
- plano de rollback.

Sem estas evidências, PR não deve ser aprovado.
