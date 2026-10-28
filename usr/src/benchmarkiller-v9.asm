; =====================================================================
; BENCHMARKILLER V9 - APOTEOSIS SSE3: CERO DEPENDENCIAS (10/10)
; =====================================================================
; Compilación: nasm -f elf64 benchmarkiller.asm -o benchmarkiller.o
; Enlace:      ld benchmarkiller.o -o benchmarkiller
; =====================================================================

section .data
    newline db 0xA
    prefix  db "Hash BBP SSE3 Final XMM0 (Low | High): 0x"
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
    ; 1. INICIALIZACIÓN DE ACUMULADORES Y REGISTROS DE RUIDO PROPIOS
    ; -----------------------------------------------------------------
    movdqa xmm0, [const_ruido_A]   ; Acumulador T0
    movdqa xmm4, [const_ruido_B]   ; Acumulador T1
    movdqa xmm5, [const_ruido_C]   ; Acumulador T2
    movdqa xmm6, [const_ruido_D]   ; Acumulador T3
    
    ; Inicialización de 4 registros de ruido independientes
    movdqa xmm3, [const_mutacion]  ; Ruido para T0
    movdqa xmm8, [const_mutacion]  ; Ruido para T1
    movdqa xmm9, [const_mutacion]  ; Ruido para T2
    movdqa xmm10, [const_mutacion] ; Ruido para T3
    
    movdqa xmm7, [const_asimetria] ; Paso/Máscara constante

    ; 500 Millones de iteraciones x 4 flujos = 2 Billones de operaciones
    mov rcx, 500000000     

    ; -----------------------------------------------------------------
    ; 2. EL BUCLE PERFECTO: ANARQUÍA EN LOS PUERTOS DE EJECUCIÓN
    ; -----------------------------------------------------------------
align 16
.bucle_cero_dependencias:
    
    ; --- FLUJO 0 (xmm0 + xmm3) ---
    paddq xmm0, xmm3
    movdqa xmm1, xmm0
    psllq xmm1, 13          
    psrlq xmm0, 51          
    por xmm0, xmm1          
    pand xmm0, xmm7
    paddq xmm3, xmm7                ; Mutar ruido 0 de forma local

    ; --- FLUJO 1 (xmm4 + xmm8) ---
    paddq xmm4, xmm8
    movdqa xmm1, xmm4
    psllq xmm1, 19          
    psrlq xmm4, 45          
    por xmm4, xmm1          
    pand xmm4, xmm7
    paddq xmm8, xmm7                ; Mutar ruido 1 de forma local

    ; --- FLUJO 2 (xmm5 + xmm9) ---
    paddq xmm5, xmm9
    movdqa xmm1, xmm5
    psllq xmm1, 7           
    psrlq xmm5, 57          
    por xmm5, xmm1          
    pand xmm5, xmm7
    paddq xmm9, xmm7                ; Mutar ruido 2 de forma local

    ; --- FLUJO 3 (xmm6 + xmm10) ---
    paddq xmm6, xmm10
    movdqa xmm1, xmm6
    psllq xmm1, 29          
    psrlq xmm6, 35          
    por xmm6, xmm1          
    pand xmm6, xmm7
    paddq xmm10, xmm7               ; Mutar ruido 3 de forma local

    dec rcx
    jnz .bucle_cero_dependencias

    ; -----------------------------------------------------------------
    ; 3. MEZCLA ASIMÉTRICA Y FUSIÓN DE ENTROPÍA OUT-OF-LOOP
    ; -----------------------------------------------------------------
    movdqa xmm1, xmm0
    palignr xmm1, xmm4, 8           
    paddq xmm0, xmm1

    movdqa xmm2, xmm5
    palignr xmm2, xmm6, 8           
    paddq xmm5, xmm2

    pxor xmm0, xmm5                 

    ; -----------------------------------------------------------------
    ; 4. EXTRACCIÓN Y SALIDA
    ; -----------------------------------------------------------------
    movq r8, xmm0           
    pextrq r9, xmm0, 1      

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
