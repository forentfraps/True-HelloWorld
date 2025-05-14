global  get_export_directory
global find_function_by_name

extern utf8_utf8_cmp

section .text

get_export_directory:
    push    rbx
    push    rsi

    mov     rbx, rcx            ; RBX = module_base

    ; — locate IMAGE_NT_HEADERS64 —
    mov     eax, [rbx + 0x3C]   ; EAX = e_lfanew
    lea     rsi, [rbx + rax]    ; RSI = &NT_HEADERS

    ; — get Export Directory RVA from OptionalHeader.DataDirectory[0] —
    mov     edx, [rsi + 0x88]   ; EDX = export_table_rva
    test    edx, edx
    je      .no_exports

    ; — compute &IMAGE_EXPORT_DIRECTORY —
    lea     rax, [rbx + rdx]    ; RAX = module_base + export_table_rva
    jmp     .cleanup

.no_exports:
    xor     rax, rax            ; no export directory → return 0

.cleanup:
    pop     rsi
    pop     rbx
    ret



find_function_by_name:
    push    rbx
    push    rsi
    push    rdi
    push    r11
    push    r12
    push    r13
    push    r14
    push    r15
    mov     rbx, rcx        ; RBX = module_base
    mov     rsi, rdx        ; RSI = export_dir_ptr
    mov     r12, r8         ; R12 = target_name_ptr
    mov     ecx, [rsi + 0x18]   ; IMAGE_EXPORT_DIRECTORY.NumberOfNames
    test    ecx, ecx
    je      .not_found
    ;; AddressOfNames → names_array_va in R13
    mov     edx, [rsi + 0x20]   ; names_rva
    lea     r13, [rbx + rdx]
    ;; AddressOfNameOrdinals → ordinals_array_va in R14
    mov     edx, [rsi + 0x24]   ; ordinals_rva
    lea     r14, [rbx + rdx]
    ;; AddressOfFunctions → functions_array_va in R15
    mov     edx, [rsi + 0x1C]   ; functions_rva
    lea     r15, [rbx + rdx]

    ;; loop index = 0
    xor     rdi, rdi
    mov r11, rcx

.loop:
    cmp     edi, r11d
    jge     .not_found
    mov     edx, [r13 + rdi*4]  ; DWORD name RVA
    lea     rcx, [rbx + rdx]    ; exported_name (ASCII)
    mov     rdx, r12
    call    utf8_utf8_cmp
    test    rax, rax
    jnz     .next_index
    ;; ── found! ──
    ;; get ordinal (WORD) and then function RVA
    movzx   r11d, word [r14 + rdi*2]
    mov     edx, [r15 + r11*4]
    lea     rax, [rbx + rdx]    ; VA of the function
    jmp     .cleanup2

.next_index:
    inc     rdi
    jmp     .loop

.not_found:
    xor     rax, rax            ; not found → return 0

.cleanup2:
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     r11
    pop     rdi
    pop     rsi
    pop     rbx
    ret
