global get_ntdll_base 
global get_stdout

extern utf16_utf8_cmp

section .text

get_stdout:
    mov     rax, gs:0x60
    mov     rax, [rax+0x20]
    mov     rax, [rax+0x28]
    ret


get_ntdll_base:
    push    rbx
    push    rsi

    ; — get PEB →
    mov     rax, gs:0x60
    mov     rax, [rax + 0x18]
    mov     rax, [rax + 0x20]    ; LIST_ENTRY head
    mov     rbx, rax             ; save head in RBX

.next_module:
    mov     rax, [rax]           ; InMemoryOrderLinks of next module
    cmp     rax, rbx
    je      .not_found           ; wrapped back to head

    lea     rsi, [rax - 0x10]    ; RSI = ptr to LDR_DATA_TABLE_ENTRY

    mov     rcx, [rsi + 0x60]    ; unicode (wchar*) BaseDllName
    lea     rdx, [rel ascii_ntdll]
    call    utf16_utf8_cmp

    test    rax, rax
    jne     .next_module

    mov     rax, [rsi + 0x30]    ; DllBase
    jmp     .done

.not_found:
    xor     rax, rax             ; not found -> return 0

.done:
    pop     rsi
    pop     rbx
    ret


section .data
ascii_ntdll:    db 'ntdll.dll', 0


