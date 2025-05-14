global utf16_utf8_cmp
global utf8_utf8_cmp


section .text

utf8_utf8_cmp:
.next_char_8:
    mov   al, byte [rcx]
    test al, al
    jz .check_final_zero_8
    cmp al, [rdx]
    jnz .mismatch_8
    inc rcx
    inc rdx
    jmp .next_char_8
.mismatch_8:
    mov al, 1
    ret
.check_final_zero_8:
    mov al, [rdx]
    test al, al
    jnz .mismatch_8
    xor eax, eax
    ret


utf16_utf8_cmp:
.next_char:
    movzx   eax, word [rcx]
    test    eax, eax
    jz      .check_final_zero
    cmp     byte [rdx], al
    jnz     .mismatch
    add     rcx, 2
    inc     rdx
    jmp     .next_char
.check_final_zero:
    cmp     byte [rdx], 0
    jne     .mismatch
    xor     eax, eax
    ret
.mismatch:
    mov     eax, 1 
    ret
