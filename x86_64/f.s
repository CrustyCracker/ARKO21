# -------------------------------------------------------------------------------
# Name: Mateusz Łukasz Krakowski
# Index number: 310772
# Bazier Curve Drawer BCD

# -------------------------------------------------------------------------------
# The Program only supports 24bit .bmp files
# -------------------------------------------------------------------------------

    ; ------------- Register Legend ---------------
    ; mxx0..8 - registers for points
    ; the x and y coords will be in mxx0, mxx1

    ; xmm12- current t value
    ; xmm13- value that will be added to t
    ; xmm14- current (1-t) value
    ; xmm15- constant 1.0

    ; rdx - x_cord int value
    ; rcx - y_cord int value
    ; r10 - for calculating y_cord
    ; r11  - double list of points
    ; r12  - colour
    ; r15, rsi  - register for holding image pointer
    ; rbx  - row size


    bits    64
    section    .text

    global f
# -------------------------------------------------------------------------------
# Preperations
# -------------------------------------------------------------------------------

f:
    push    rbp              ;prologue
    mov     rbp, rsp

    mov     r11, rdi        ; r11 = *points
    mov     r15, rsi        ; r14 = *image_buff

    mov     rbx, [r15+18]   ; rbx = width of image
    imul    rbx, 3          ; rbx = rbx * 3
    add     rbx, 3
    and     ebx, 0xFFFFFFFC ; padding, rbx now has the row size

    mov     r8d, [r15+22]
    cvtsi2sd xmm10, r8d
    xorpd  xmm12, xmm12       ;set t = 0

    mov     r9, 1
    mov     r10, 10000
    cvtsi2sd xmm15, r9      ;constant 1.0

    ;caluclating value to add to t (xmm12)
    cvtsi2sd xmm13, r9      ;const 1.0
    cvtsi2sd xmm14, r10     ;constant 10000.0
    divsd   xmm13, xmm14
    cvtsi2sd xmm14, r9     ;constant 1-t

    mov     r12, 0xFFFFFF   ;r12 colour

# -------------------------------------------------------------------------------
# Main Function
# -------------------------------------------------------------------------------
main_loop:
    comisd xmm12, xmm15      ; compare current t (xmm12) to 1
    ja end                  ; if t > 1 jump to end


;----------------- get points
    movsd xmm0, [r11]
    movsd xmm1, [r11+8]
    movsd xmm2, [r11+16]
    movsd xmm3, [r11+24]
    movsd xmm4, [r11+32]
;----------------- Calculate x_pos first wave of points
    mulsd xmm0, xmm12
    mulsd xmm1, xmm14
    addsd xmm0, xmm1

    movsd xmm1, [r11+8]
    mulsd xmm1, xmm12
    mulsd xmm2, xmm14
    addsd xmm1, xmm2

    movsd xmm2, [r11+16]
    mulsd xmm2, xmm12
    mulsd xmm3, xmm14
    addsd xmm2, xmm3

    movsd xmm3, [r11+24]
    mulsd xmm3, xmm12
    mulsd xmm4, xmm14
    addsd xmm3, xmm4


;----------------- Calculate x_pos 2nd wave

    movsd xmm4, xmm0
    movsd xmm5, xmm1

    mulsd xmm4, xmm12
    mulsd xmm5, xmm14
    addsd xmm4, xmm5
    movsd xmm0, xmm4

    movsd xmm4, xmm1
    movsd xmm5, xmm2

    mulsd xmm4, xmm12
    mulsd xmm5, xmm14
    addsd xmm4, xmm5
    movsd xmm1, xmm4

    movsd xmm4, xmm2
    movsd xmm5, xmm3

    mulsd xmm4, xmm12
    mulsd xmm5, xmm14
    addsd xmm4, xmm5
    movsd xmm2, xmm4

;----------------- Calculate x_pos 3rd wave



    movsd xmm4, xmm0
    movsd xmm5, xmm1

    mulsd xmm4, xmm12
    mulsd xmm5, xmm14
    addsd xmm4, xmm5
    movsd xmm0, xmm4

    movsd xmm4, xmm1
    movsd xmm5, xmm2

    mulsd xmm4, xmm12
    mulsd xmm5, xmm14
    addsd xmm4, xmm5
    movsd xmm1, xmm4


;----------------- Calculate x_pos last wave

    movsd xmm4, xmm0
    movsd xmm5, xmm1

    mulsd xmm4, xmm12
    mulsd xmm5, xmm14
    addsd xmm4, xmm5
    movsd xmm0, xmm4


;get values for y_pos
    movsd xmm1, [r11+40]
    movsd xmm2, [r11+48]
    movsd xmm3, [r11+56]
    movsd xmm4, [r11+64]
    movsd xmm5, [r11+72]
;----------------- Calculate y_pos first wave
    mulsd xmm1, xmm12
    mulsd xmm2, xmm14
    addsd xmm1, xmm2

    movsd xmm2, [r11+48]
    mulsd xmm2, xmm12
    mulsd xmm3, xmm14
    addsd xmm2, xmm3

    movsd xmm3, [r11+56]
    mulsd xmm3, xmm12
    mulsd xmm4, xmm14
    addsd xmm3, xmm4

    movsd xmm4, [r11+64]
    mulsd xmm4, xmm12
    mulsd xmm5, xmm14
    addsd xmm4, xmm5

;----------------- Calculate y_pos 2nd wave
    movsd xmm7, xmm1
    movsd xmm8, xmm2

    mulsd xmm7, xmm12
    mulsd xmm8, xmm14
    addsd xmm7, xmm8
    movsd xmm1, xmm7


    movsd xmm7, xmm2
    movsd xmm8, xmm3

    mulsd xmm7, xmm12
    mulsd xmm8, xmm14
    addsd xmm7, xmm8
    movsd xmm2, xmm7


    movsd xmm7, xmm3
    movsd xmm8, xmm4

    mulsd xmm7, xmm12
    mulsd xmm8, xmm14
    addsd xmm7, xmm8
    movsd xmm3, xmm7

;----------------- Calculate y_pos 3nd wave


    movsd xmm7, xmm1
    movsd xmm8, xmm2

    mulsd xmm7, xmm12
    mulsd xmm8, xmm14
    addsd xmm7, xmm8
    movsd xmm1, xmm7


    movsd xmm7, xmm2
    movsd xmm8, xmm3

    mulsd xmm7, xmm12
    mulsd xmm8, xmm14
    addsd xmm7, xmm8
    movsd xmm2, xmm7

;----------------- Calculate y_pos last wave wave

    movsd xmm7, xmm1
    movsd xmm8, xmm2

    mulsd xmm7, xmm12
    mulsd xmm8, xmm14
    addsd xmm7, xmm8
    movsd xmm1, xmm7

    cvtsi2sd xmm10, r8d
    subsd xmm10, xmm1
    movsd xmm1, xmm10


    cvtsd2si rcx, xmm1
    cvtsd2si rdx, xmm0

    addsd xmm12, xmm13       ; t += const 0.0001
    subsd xmm14, xmm13

;----------- Drawing pixels ---------------
put_pixel:  ; [rcx - y, rdx - x, r12 - colour]
    imul    rcx, rbx        ;rcx = y * row_size
    imul    rdx, 3          ;rdx = x*3
    add     rcx, rdx        ;rcx = pixel address
    add     rcx, r15        ;rcx = pixel address + image buffer address
    add     rcx, 54         ;rcx = pixel absolute address

    mov     rdx, r12        ;rdx = 0x00RRGGBB
    mov     [rcx], dx       ;store GG, BB
    shr     rdx, 16         ;edx now has RR
    mov     [rcx+2], dl     ;store RR

    jmp main_loop

;----------- End --------------------------
end:
    mov     rsp, rbp        ;epilogue
    pop     rbp
    ret
