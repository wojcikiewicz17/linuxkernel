/* SPDX-License-Identifier: GPL-2.0 */
/* low-level puro: núcleo + engine + módulos em fluxo plano */

    .section .text
    .global ll_entry

/* mapa explícito: registradores/endereços/pino */
    .equ R0_MMIO_BASE, 0x40000000
    .equ R1_GPIO_DIR,  0x0004
    .equ R2_GPIO_OUT,  0x0008
    .equ R3_PIN_BIT,   3

/* bloco de entrada */
ll_entry:
    jmp ll_core

/* bloco núcleo */
ll_core:
    movl $R0_MMIO_BASE, %eax
    movl $R1_GPIO_DIR, %ebx
    addl %eax, %ebx
    movl (%ebx), %ecx
    btsl $R3_PIN_BIT, %ecx
    movl %ecx, (%ebx)
    jmp ll_engine

/* bloco engine */
ll_engine:
    movl $R0_MMIO_BASE, %eax
    movl $R2_GPIO_OUT, %ebx
    addl %eax, %ebx
    movl (%ebx), %ecx
    btsl $R3_PIN_BIT, %ecx
    movl %ecx, (%ebx)
    jmp ll_mod0

/* bloco módulo 0 */
ll_mod0:
    movl (%ebx), %edx
    btcl $R3_PIN_BIT, %edx
    movl %edx, (%ebx)
    jmp ll_mod1

/* bloco módulo 1 */
ll_mod1:
    movl (%ebx), %esi
    btrl $R3_PIN_BIT, %esi
    movl %esi, (%ebx)
    jmp ll_halt

/* bloco de parada sem runtime */
ll_halt:
    hlt
    jmp ll_halt
