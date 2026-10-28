; =====================================================================
; BENCHMARKILLER V8 - SSE3 EXTREMO CON 4 ACUMULADORES AISLADOS (10/10)
; =====================================================================
; Compilación: nasm -f elf64 benchmarkiller.asm -o benchmarkiller.o
; Enlace:      ld benchmarkiller.o -o benchmarkiller
; =====================================================================

section .data
    newline db 0xA
    prefix  db "Hash BBP SSE3 XMM0 (Low | High): 0x"
    len_pref equ $ - prefix
    pipe    db " | 0x"

    align 16
    const_ruido_A   dq 0x5851F42D4C957F2D, 0x14057B7EF767814F
    const_ruido_B   dq 0x2D7F954C2DF45158, 0x4F8167F77E7B0514
    const_ruido_C   dq 0x123456789ABCDEF0, 0xFEDCBA9876543210
    const_ruido_D   dq 0xAA55AA55AA55AA55, 0x55AA55AA55AA55AA
    
    const_mutacion  dq 0x9E3779B97F4A7C15, 0x1309774B53259A1D
    const_asimetria dq 0x7FFFFFFFFFFFFFFF, 0x3FFFFFFFFFFFFFFF

section .bss
    buffer resb 16          

section .text
global _start

_start:
    ; -----------------------------------------------------------------
    ; 1. INICIALIZACIÓN DE 4 ACUMULADORES AISLADOS (128-BIT NATIVO)
    ; -----------------------------------------------------------------
    movdqa xmm0, [const_ruido_A]   ; Flujo T0
    movdqa xmm4, [const_ruido_B]   ; Flujo T1
    movdqa xmm5, [const_ruido_C]   ; Flujo T2
    movdqa xmm6, [const_ruido_D]   ; Flujo T3
    
    movdqa xmm3, [const_mutacion]  ; Paso de ruido
    movdqa xmm7, [const_asimetria] ; Constante asimétrica

    ; 2 Billones de operaciones totales / 4 flujos = 500 Millones de iteraciones
    mov rcx, 500000000     

    ; -----------------------------------------------------------------
    ; 2. EL BUCLE DEFINITIVO: MÁXIMO ILP EN SSE3 (SIN DEPENDENCIAS)
    ; -----------------------------------------------------------------
align 16
.bucle_sse3_opt:
    
    ; --- FLUJO 0 (xmm0) ---
    paddq xmm0, xmm3
    movdqa xmm1, xmm0
    psllq xmm1, 13          
    psrlq xmm0, 51          
    por xmm0, xmm1          
    pand xmm0, xmm7

    ; --- FLUJO 1 (xmm4) ---
    paddq xmm4, xmm3
    movdqa xmm1, xmm4
    psllq xmm1, 19          
    psrlq xmm4, 45          
    por xmm4, xmm1          
    pand xmm4, xmm7

    ; --- FLUJO 2 (xmm5) ---
    paddq xmm5, xmm3
    movdqa xmm1, xmm5
    psllq xmm1, 7           
    psrlq xmm5, 57          
    por xmm5, xmm1          
    pand xmm5, xmm7

    ; --- FLUJO 3 (xmm6) ---
    paddq xmm6, xmm3
    movdqa xmm1, xmm6
    psllq xmm1, 29          
    psrlq xmm6, 35          
    por xmm6, xmm1          
    pand xmm6, xmm7

    ; Mutación del paso de ruido lineal
    paddq xmm3, xmm7

    dec rcx
    jnz .bucle_sse3_opt

    ; -----------------------------------------------------------------
    ; 3. MEZCLA ASIMÉTRICA Y FUSIÓN DE ENTROPÍA (FUERA DEL BUCLE)
    ; -----------------------------------------------------------------
    ; Cruzamos los flujos independientes usando palignr una sola vez al final
    movdqa xmm1, xmm0
    palignr xmm1, xmm4, 8           ; Mezcla T0 y T1
    paddq xmm0, xmm1

    movdqa xmm2, xmm5
    palignr xmm2, xmm6, 8           ; Mezcla T2 y T3
    paddq xmm5, xmm2

    pxor xmm0, xmm5                 ; Fusión destructiva final

    ; -----------------------------------------------------------------
    ; 4. EXTRACCIÓN Y VOLCADO DEL HASH ASIMÉTRICO
    ; -----------------------------------------------------------------
    movq r8, xmm0           ; Extraer carril LOW
    pextrq r9, xmm0, 1      ; Extraer carril HIGH

    ; Imprimir prefijo
    mov rax, 1              
    mov rdi, 1              
    mov rsi, prefix
    mov rdx, len_pref
    syscall

    ; Imprimir carril LOW
    mov rbx, r8
    call _print_hex

    ; Imprimir separador
    mov rax, 1              
    mov rdi, 1              
    mov rsi, pipe
    mov rdx, 5
    syscall

    ; Imprimir carril HIGH
    mov rbx, r9
    call _print_hex

    ; Salto de línea
    mov rax, 1              
    mov rdi, 1              
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 60             
    xor rdi, rdi            
    syscall

    ; -----------------------------------------------------------------
    ; SUBRUTINA: CONVERSIÓN BINARIO A HEXADECIMAL ASCII
    ; -----------------------------------------------------------------
_print_hex:
    mov rcx, 16             
.loop_hex:
    mov rdx, rbx
    shr rdx, 60             
    and dl, 0x0F
    cmp dl, 9
    jbe .es_numero
    add dl, 7               
.es_numero:
    add dl, '0'             
    mov [buffer + rcx - 1], dl 
    shl rbx, 4              
    dec rcx
    jnz .loop_hex

    mov rax, 1              
    mov rdi, 1              
    mov rsi, buffer
    mov rdx, 16
    syscall
    ret
