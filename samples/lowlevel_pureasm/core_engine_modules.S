/* SPDX-License-Identifier: GPL-2.0 */
/* low-level puro, fluxo plano por blocos, sem runtime */

#include "generated/detected.inc"

    .section .text
    .global ll0

    .equ C0, 0x40000000
    .equ C1, 0x0004
    .equ C2, 0x0008
    .equ C3, 3

ll0:
    jmp ll1

ll1:
    movl $C0, %eax
    movl $C1, %ebx
    addl %eax, %ebx
    movl (%ebx), %ecx
    btsl $C3, %ecx
    movl %ecx, (%ebx)
    jmp ll2

ll2:
    movl $C0, %eax
    movl $C2, %ebx
    addl %eax, %ebx
    movl (%ebx), %ecx
    btsl $C3, %ecx
    movl %ecx, (%ebx)
    jmp ll3

ll3:
    movl (%ebx), %edx
    btcl $C3, %edx
    movl %edx, (%ebx)
    jmp ll4

ll4:
    movl (%ebx), %esi
    btrl $C3, %esi
    movl %esi, (%ebx)

    /* autoidentificação fixa em registradores antes do halt */
    movl $D0, %edi
    movl $D1, %ebp
    movl $D2, %eax

    jmp ll5

ll5:
    hlt
    jmp ll5
