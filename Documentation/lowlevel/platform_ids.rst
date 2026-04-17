.. SPDX-License-Identifier: GPL-2.0

Low-level platform IDs (assembly include)
=========================================

A geração de IDs de arquitetura, sistema operacional e hardware foi normalizada
em script único:

- ``scripts/detect_platform_ids.sh``

Saída
-----

O script gera um include assembler com constantes numéricas:

- ``D0``: arquitetura
- ``D1``: sistema operacional
- ``D2``: hardware

Uso no sample low-level
-----------------------

- ``samples/lowlevel_pureasm/detect_env.sh`` delega para o script central.
- ``samples/lowlevel_pureasm/core_engine_modules.S`` inclui ``generated/detected.inc``.

Mapeamento atual
----------------

Arquitetura (D0):

- ``1`` = x86_64
- ``2`` = x86
- ``3`` = arm64
- ``4`` = arm
- ``5`` = riscv64
- ``0`` = desconhecido

Sistema operacional (D1):

- ``1`` = Linux
- ``2`` = Darwin
- ``3`` = FreeBSD
- ``0`` = desconhecido

Hardware (D2):

- ``1`` = raspberry
- ``2`` = jetson
- ``3`` = generic-dt
- ``10`` = virtual
- ``11`` = generic-dmi
- ``0`` = desconhecido
