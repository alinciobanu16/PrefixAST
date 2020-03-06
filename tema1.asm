; Ciobanu Alin-Matei 325 CB
;%include "includes/io.inc"
%include "io.inc"
extern getAST
extern freeAST

section .data
    vect:   times 1000 dw 0; vector in care pun elementele din arbore
    size dw 0; nr elemente din vector
section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1

section .text
global main

atoi: 
    ; convertire string la intreg
    push ebp
    mov ebp, esp
    mov ebx, [ebp+8]; iau stringul
    xor edx, edx
    xor ecx, ecx
    xor esi, esi
    
test:
    movzx  ecx, byte[ebx]; iau caracter cu caracter
    test ecx,ecx; testez daca am ajuns la sfarsitul sirului
    je iesi
    cmp ecx, '-'; verific daca e nr negativ
    je seteaza; tin minte ca e negativ si trec la urmatorul caracter
    sub ecx, '0'
    imul edx, 10
    add edx, ecx; rezultatul in edx
    
jump:
    inc ebx
    jmp test

iesi:
    ; daca e negativ scad 1 si il neg
    cmp esi, 1
    jne pozitiv 
    sub edx, 1
    not edx

pozitiv:
    jmp out2  
    
seteaza:
    mov esi, 1; esi = 1 inseamna ca e nr negativ
    jmp jump

out2: 
    leave
    ret
    

RSD:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]
    mov ebx, [eax]
    mov dl, byte[ebx]; primul caracter din string
    
    ; adaug in vector semnele
    cmp dword[ebx], '-'
    je baga_minus
    cmp dword[ebx], '+'
    je baga_plus
    cmp dword[ebx], '/'
    je baga_impartire
    cmp dword[ebx], '*'
    je baga_inmultire

sari:
    ; daca nu e numar continua parcurgerea
    ; compar primul caracter din string stocat in dl cu -,0,9
    cmp dl, '-' ; daca e nr negativ
    je convert
    cmp dl, '0'
    jb go 
    cmp dl, '9'
    ja go 
    
convert:
    push ebx
    call atoi; transform stringul in numar intreg
    pop ebx
    mov edi, dword[size]
    mov dword[vect + 4 * edi], edx; adaug numarul in vector
    inc dword[size]
    jmp out
    
baga_minus:
    mov edi, dword[size]
    mov edx, 0 ; 0 = minus
    mov dword[vect + 4 * edi], edx; adaug semnul '-' mapat prin 0
    inc dword[size]
    jmp go
    
baga_plus:
    mov edi, dword[size]
    mov edx, 1; 1 = plus
    mov dword[vect + 4 * edi], edx
    inc dword[size]
    jmp go

baga_impartire:
    mov edi, dword[size]
    mov edx, 2; 2 = /
    mov dword[vect + 4 * edi], edx
    inc dword[size]
    jmp go
    
baga_inmultire:
    mov edi, dword[size]
    mov edx, 3; 3 = *
    mov dword[vect + 4 * edi], edx
    inc dword[size]
    jmp go

go:
    mov ecx, [eax+4]; adresa elemntului din stanga
    mov edx, [eax+8]; adresa elementului din dreapta
    push edx
    push ecx
    call RSD  
    add esp, 4
    call RSD
    add esp, 4
    
    mov esi, dword[size]
    mov eax, [vect + esi * 4 - 4]; operandul din dreapta in eax care reprezinta un numar
    dec esi
    mov ebx, [vect + esi * 4 - 4]; operandul din stanga in ebx care reprezinta un numar
    dec esi
    mov ecx, [vect + esi * 4 - 4]; operatia reprezentata de 0, 1, 2, 3
    dec esi
   
    cmp ecx, 0
    je scade
    cmp ecx, 1
    je aduna
    cmp ecx, 2
    je imparte
    cmp ecx, 3
    je inmulteste

scade:
    sub ebx, eax
    inc esi; esi este pozitia pe care se afla pe locul unde se afla operandul
    mov [vect + esi * 4 - 4], ebx; suprascriu semnul cu rezultatul operatiei
    mov dword[size], esi; size-ul vectorului se modifica
    jmp out
    
aduna:  
    add eax, ebx
    inc esi
    mov [vect + esi * 4 - 4], eax
    mov dword[size], esi
    jmp out
    
imparte:
    xor edx, edx
    xchg eax, ebx ;rezultaul este scris in eax, iar eu am nevoie sa impart la eax, de aceea le schimb
    cdq
    idiv ebx
    inc esi
    mov [vect + esi * 4 - 4], eax
    mov dword[size], esi
    jmp out
    
inmulteste:
    imul ebx
    inc esi
    mov [vect + esi * 4 - 4], eax
    mov dword[size], esi
    jmp out
    
out:
    leave
    ret


main:
    mov ebp, esp; for correct debugging
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
    
    ; Implementati rezolvarea aici:
    push dword[root]
    call RSD
    mov esp, ebp
    
    mov eax, [vect]; in vector mai am un singur element care reprezinta rezultatul final
    PRINT_DEC 4, eax
    
    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret