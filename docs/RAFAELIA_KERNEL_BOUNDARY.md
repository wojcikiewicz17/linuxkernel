# RAFAELIA Kernel Boundary

## Fronteira técnica (sem hype)
- O kernel neste fork deve ser tratado como camada de **pesquisa/sistema**.
- Aplicativos Android (incluindo Vectras) operam majoritariamente em **userspace** e **não** têm acesso direto a registradores privilegiados por padrão.

## Relação prática com Vectras/QEMU/Termux/RMR
- Integrações práticas e sustentáveis devem passar por:
  - **QEMU** (emulação/virtualização no espaço suportado)
  - **Termux** (orquestração userspace)
  - **Android NDK** (código nativo app-side)
  - **logs observáveis** (`logcat`, traces, métricas)
  - **APIs userspace** (syscalls/interfaces suportadas)
  - **root/Magisk apenas quando explicitamente suportado e documentado**

## Claims proibidas sem patch real
- Não declarar:
  - controle direto de registradores privilegiados;
  - controle de ciclos de CPU em nível kernel global;
  - controle de KVM/scheduler global;
- A menos que exista patch verificável nos diretórios/subsistemas correspondentes.

## Política de decisão
- Se houver patch real em `arch/*/kvm`, `kernel/sched`, `mm`, `security`, `kernel/trace`, classificar como possível base core.
- Se não houver, manter classificação de fork como **estudo/referência/não-core** para integração Android.
