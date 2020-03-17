; PSX 'Bare Metal' CPU Signed Word Division Test Demo by krom (Peter Lemon):
.psx
.create "CPUDIV.bin", 0x80010000

.include "LIB/PSX.INC" ; Include PSX Definitions
.include "LIB/PSX_GPU.INC" ; Include PSX GPU Definitions & Macros

.macro PrintString,X,Y,WIDTH,HEIGHT,FONT,STRING,LENGTH ; Print Text String To VRAM Using Width,Height Font At X,Y Position
  la a1,FONT   ; A1 = Font Address
  la a2,STRING ; A2 = Text Address
  li t0,LENGTH ; T0 = Number of Text Characters to Print
  li t1,X ; T1 = X Position
  li t2,Y ; T2 = Y Position

  DrawChars:
    ; Copy Rectangle (CPU To VRAM): X,Y, Width,Height

    ; Write GP0 Command Word (Command)
    li t3,0xA0<<24 ; T3 = DATA Word
    sw t3,GP0(a0) ; I/O Port Register Word = T3

    ; Write GP0  Packet Word (Destination Coord: X Counted In Halfwords)
    sll t3,t2,16 ; T3 = Y<<16
    addu t3,t1 ; T3 = DATA Word (Y<<16)+X
    sw t3,GP0(a0) ; I/O Port Register Word = T3

    ; Write GP0  Packet Word (Width+Height:  Width Counted In Halfwords)
    li t3,(HEIGHT<<16)+WIDTH ; T3 = DATA Word
    sw t3,GP0(a0) ; I/O Port Register Word = T3

    ; Write GP0  Packet Word (Data)
    lbu a3,0(a2) ; A3 = Next Text Character
    li t3,(WIDTH*HEIGHT/2)-1 ; T3 = Data Copy Word Count
    sll a3,7 ; A3 *= 128
    addu a3,a1 ; A3 = Texture RAM Font Offset
    CopyTexture:
      lw t4,0(a3) ; T4 = DATA Word
      addiu a3,4  ; A3 += 4 (Delay Slot)
      sw t4,GP0(a0) ; Write GP0 Packet Word
      bnez t3,CopyTexture ; IF (T3 != 0) Copy Texture
      subiu t3,1 ; T3-- (Delay Slot)

    addiu a2,1 ; Increment Text Offset
    addiu t1,WIDTH ; Add Width To X Position
    bnez t0,DrawChars ; Continue to Print Characters
    subiu t0,1 ; Subtract Number of Text Characters to Print (Delay Slot)
.endmacro

.macro PrintValue,X,Y,WIDTH,HEIGHT,FONT,STRING,LENGTH ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
  la a1,FONT   ; A1 = Font Address
  la a2,STRING+LENGTH ; A2 = Text Address
  li t0,LENGTH ; T0 = Number of Text Characters to Print
  li t1,X ; T1 = X Position
  li t2,Y ; T2 = Y Position

  DrawHEXChars:
    lbu t3,0(a2) ; T3 = Next 2 HEX Chars
    subiu a2,1 ; Decrement Text Offset

    srl t4,t3,4 ; T4 = 2nd Nibble
    andi t4,0xF
    subiu t5,t4,9
    bgtz t5,HEXLetters
    addiu t4,0x30 ; Delay Slot
    j HEXEnd
    nop ; Delay Slot

    HEXLetters:
    addiu t4,7
    HEXEnd:

    sll a3,t4,7 ; Add Shift to Correct Position in Font (*128: WIDTH*HEIGHT*BYTES_PER_PIXEL)
    addu a3,a1 ; A3 = Texture RAM Font Offset

    ; Copy Rectangle (CPU To VRAM): X,Y, Width,Height

    ; Write GP0 Command Word (Command)
    li t4,0xA0<<24 ; T4 = DATA Word
    sw t4,GP0(a0) ; I/O Port Register Word = T4

    ; Write GP0  Packet Word (Destination Coord: X Counted In Halfwords)
    sll t4,t2,16 ; T4 = Y<<16
    addu t4,t1 ; T4 = DATA Word (Y<<16)+X
    sw t4,GP0(a0) ; I/O Port Register Word = T4

    ; Write GP0  Packet Word (Width+Height:  Width Counted In Halfwords)
    li t4,(HEIGHT<<16)+WIDTH ; T4 = DATA Word
    sw t4,GP0(a0) ; I/O Port Register Word = T4

    ; Write GP0  Packet Word (Data)
    li t4,(WIDTH*HEIGHT/2)-1 ; T4 = Data Copy Word Count
    CopyTextureA:
      lw t5,0(a3) ; T5 = DATA Word
      addiu a3,4  ; A3 += 4 (Delay Slot)
      sw t5,GP0(a0) ; Write GP0 Packet Word
      bnez t4,CopyTextureA ; IF (T4 != 0) Copy Texture A
      subiu t4,1 ; T4-- (Delay Slot)

    addiu t1,WIDTH ; Add Width To X Position

    andi t4,t3,0xF ; T4 = 1st Nibble
    subiu t5,t4,9
    bgtz t5,HEXLettersB
    addiu t4,0x30 ; Delay Slot
    j HEXEndB
    nop ; Delay Slot

    HEXLettersB:
    addiu t4,7
    HEXEndB:

    sll a3,t4,7 ; Add Shift to Correct Position in Font (*128: WIDTH*HEIGHT*BYTES_PER_PIXEL)
    addu a3,a1 ; A3 = Texture RAM Font Offset

    ; Copy Rectangle (CPU To VRAM): X,Y, Width,Height

    ; Write GP0 Command Word (Command)
    li t4,0xA0<<24 ; T4 = DATA Word
    sw t4,GP0(a0) ; I/O Port Register Word = T4

    ; Write GP0  Packet Word (Destination Coord: X Counted In Halfwords)
    sll t4,t2,16 ; T4 = Y<<16
    addu t4,t1 ; T4 = DATA Word (Y<<16)+X
    sw t4,GP0(a0) ; I/O Port Register Word = T4

    ; Write GP0  Packet Word (Width+Height:  Width Counted In Halfwords)
    li t4,(HEIGHT<<16)+WIDTH ; T4 = DATA Word
    sw t4,GP0(a0) ; I/O Port Register Word = T4

    ; Write GP0  Packet Word (Data)
    li t4,(WIDTH*HEIGHT/2)-1 ; T4 = Data Copy Word Count
    CopyTextureB:
      lw t5,0(a3) ; T5 = DATA Word
      addiu a3,4  ; A3 += 4 (Delay Slot)
      sw t5,GP0(a0) ; Write GP0 Packet Word
      bnez t4,CopyTextureB ; IF (T4 != 0) Copy Texture B
      subiu t4,1 ; T4-- (Delay Slot)

    addiu t1,WIDTH ; Add Width To X Position
    bnez t0,DrawHEXChars ; Continue to Print Characters
    subiu t0,1 ; Subtract Number of Text Characters to Print (Delay Slot)
.endmacro

.org 0x80010000 ; Entry Point Of Code

la a0,IO_BASE ; A0 = I/O Port Base Address ($1F80XXXX)

; Setup Screen Mode
WRGP1 GPURESET,0  ; Write GP1 Command Word (Reset GPU)
WRGP1 GPUDISPEN,0 ; Write GP1 Command Word (Enable Display)
WRGP1 GPUDISPM,HRES320+VRES240+BPP15+VNTSC ; Write GP1 Command Word (Set Display Mode: 320x240, 15BPP, NTSC)
WRGP1 GPUDISPH,0xC60260 ; Write GP1 Command Word (Horizontal Display Range 608..3168)
WRGP1 GPUDISPV,0x042018 ; Write GP1 Command Word (Vertical Display Range 24..264)

; Setup Drawing Area
WRGP0 GPUDRAWM,0x000400   ; Write GP0 Command Word (Drawing To Display Area Allowed Bit 10)
WRGP0 GPUDRAWATL,0x000000 ; Write GP0 Command Word (Set Drawing Area Top Left X1=0, Y1=0)
WRGP0 GPUDRAWABR,0x03BD3F ; Write GP0 Command Word (Set Drawing Area Bottom Right X2=319, Y2=239)
WRGP0 GPUDRAWOFS,0x000000 ; Write GP0 Command Word (Set Drawing Offset X=0, Y=0)

; Clear Screen
FillRectVRAM 0x000000, 0,0, 319,239 ; Fill Rectangle In VRAM: Color, X,Y, Width,Height

; Print Header Text
PrintString  40,8, 8,8, FontRed,RSRTHEX,8 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 120,8, 8,8, FontRed,RSRTDEC,8 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,8, 8,8, FontRed,LOHIHEX,8 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 280,8, 8,8, FontRed,TEST,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position


PrintString 0,16, 8,8, FontBlack,PAGEBREAK,39 ; Print Text String To VRAM Using Width,Height Font At X,Y Position


PrintString 8,24, 8,8, FontRed,DIV,2 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
la a1,VALUEWORDA ; A1 = Word Data Offset
lw t0,0(a1)      ; T0 = Word Data
la a1,VALUEWORDB ; A1 = Word Data Offset
lw t1,0(a1)      ; T1 = Word Data
la a1,LOWORD ; A1 = LOWORD Offset
div t0,t1 ; HI/LO = Test Word Data
mflo t0 ; T0 = LO
sw t0,0(a1)  ; LOWORD = Word Data
mfhi t0 ; T0 = HI
la a1,HIWORD ; A1 = HIWORD Offset
sw t0,0(a1)  ; HIWORD = Word Data
PrintString 40,24, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,24, 8,8, FontBlack,VALUEWORDA,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 184,24, 8,8, FontBlack,TEXTWORDA,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,24, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,24, 8,8, FontBlack,LOWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 40,32, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,32, 8,8, FontBlack,VALUEWORDB,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 120,32, 8,8, FontBlack,TEXTWORDB,8 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,32, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,32, 8,8, FontBlack,HIWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
la a1,LOWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVLOCHECKA ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVLOPASSA ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,24, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDA
nop ; Delay Slot
DIVLOPASSA:
PrintString 280,24, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
la a1,HIWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVHICHECKA ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVHIPASSA ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,32, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDA
nop ; Delay Slot
DIVHIPASSA:
PrintString 280,32, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
DIVENDA:

la a1,VALUEWORDB ; A1 = Word Data Offset
lw t0,0(a1)      ; T0 = Word Data
la a1,VALUEWORDC ; A1 = Word Data Offset
lw t1,0(a1)      ; T1 = Word Data
la a1,LOWORD ; A1 = LOWORD Offset
div t0,t1 ; HI/LO = Test Word Data
mflo t0 ; T0 = LO
sw t0,0(a1)  ; LOWORD = Word Data
mfhi t0 ; T0 = HI
la a1,HIWORD ; A1 = HIWORD Offset
sw t0,0(a1)  ; HIWORD = Word Data
PrintString 40,48, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,48, 8,8, FontBlack,VALUEWORDB,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 120,48, 8,8, FontBlack,TEXTWORDB,8 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,48, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,48, 8,8, FontBlack,LOWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 40,56, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,56, 8,8, FontBlack,VALUEWORDC,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 144,56, 8,8, FontBlack,TEXTWORDC,5 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,56, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,56, 8,8, FontBlack,HIWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
la a1,LOWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVLOCHECKB ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVLOPASSB ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,48, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDB
nop ; Delay Slot
DIVLOPASSB:
PrintString 280,48, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
la a1,HIWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVHICHECKB ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVHIPASSB ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,56, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDB
nop ; Delay Slot
DIVHIPASSB:
PrintString 280,56, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
DIVENDB:

la a1,VALUEWORDC ; A1 = Word Data Offset
lw t0,0(a1)      ; T0 = Word Data
la a1,VALUEWORDD ; A1 = Word Data Offset
lw t1,0(a1)      ; T1 = Word Data
la a1,LOWORD ; A1 = LOWORD Offset
div t0,t1 ; HI/LO = Test Word Data
mflo t0 ; T0 = LO
sw t0,0(a1)  ; LOWORD = Word Data
mfhi t0 ; T0 = HI
la a1,HIWORD ; A1 = HIWORD Offset
sw t0,0(a1)  ; HIWORD = Word Data
PrintString 40,72, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,72, 8,8, FontBlack,VALUEWORDC,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 144,72, 8,8, FontBlack,TEXTWORDC,5 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,72, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,72, 8,8, FontBlack,LOWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 40,80, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,80, 8,8, FontBlack,VALUEWORDD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 120,80, 8,8, FontBlack,TEXTWORDD,8 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,80, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,80, 8,8, FontBlack,HIWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
la a1,LOWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVLOCHECKC ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVLOPASSC ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,72, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDC
nop ; Delay Slot
DIVLOPASSC:
PrintString 280,72, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
la a1,HIWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVHICHECKC ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVHIPASSC ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,80, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDC
nop ; Delay Slot
DIVHIPASSC:
PrintString 280,80, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
DIVENDC:

la a1,VALUEWORDD ; A1 = Word Data Offset
lw t0,0(a1)      ; T0 = Word Data
la a1,VALUEWORDE ; A1 = Word Data Offset
lw t1,0(a1)      ; T1 = Word Data
la a1,LOWORD ; A1 = LOWORD Offset
div t0,t1 ; HI/LO = Test Word Data
mflo t0 ; T0 = LO
sw t0,0(a1)  ; LOWORD = Word Data
mfhi t0 ; T0 = HI
la a1,HIWORD ; A1 = HIWORD Offset
sw t0,0(a1)  ; HIWORD = Word Data
PrintString 40,96, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,96, 8,8, FontBlack,VALUEWORDD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 120,96, 8,8, FontBlack,TEXTWORDD,8 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,96, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,96, 8,8, FontBlack,LOWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 40,104, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,104, 8,8, FontBlack,VALUEWORDE,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 112,104, 8,8, FontBlack,TEXTWORDE,9 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,104, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,104, 8,8, FontBlack,HIWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
la a1,LOWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVLOCHECKD ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVLOPASSD ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,96, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDD
nop ; Delay Slot
DIVLOPASSD:
PrintString 280,96, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
la a1,HIWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVHICHECKD ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVHIPASSD ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,104, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDD
nop ; Delay Slot
DIVHIPASSD:
PrintString 280,104, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
DIVENDD:

la a1,VALUEWORDE ; A1 = Word Data Offset
lw t0,0(a1)      ; T0 = Word Data
la a1,VALUEWORDF ; A1 = Word Data Offset
lw t1,0(a1)      ; T1 = Word Data
la a1,LOWORD ; A1 = LOWORD Offset
div t0,t1 ; HI/LO = Test Word Data
mflo t0 ; T0 = LO
sw t0,0(a1)  ; LOWORD = Word Data
mfhi t0 ; T0 = HI
la a1,HIWORD ; A1 = HIWORD Offset
sw t0,0(a1)  ; HIWORD = Word Data
PrintString 40,120, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,120, 8,8, FontBlack,VALUEWORDE,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 112,120, 8,8, FontBlack,TEXTWORDE,9 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,120, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,120, 8,8, FontBlack,LOWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 40,128, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,128, 8,8, FontBlack,VALUEWORDF,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 136,128, 8,8, FontBlack,TEXTWORDF,6 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,128, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,128, 8,8, FontBlack,HIWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
la a1,LOWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVLOCHECKE ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVLOPASSE ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,120, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDE
nop ; Delay Slot
DIVLOPASSE:
PrintString 280,120, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
la a1,HIWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVHICHECKE ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVHIPASSE ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,128, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDE
nop ; Delay Slot
DIVHIPASSE:
PrintString 280,128, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
DIVENDE:

la a1,VALUEWORDF ; A1 = Word Data Offset
lw t0,0(a1)      ; T0 = Word Data
la a1,VALUEWORDG ; A1 = Word Data Offset
lw t1,0(a1)      ; T1 = Word Data
la a1,LOWORD ; A1 = LOWORD Offset
div t0,t1 ; HI/LO = Test Word Data
mflo t0 ; T0 = LO
sw t0,0(a1)  ; LOWORD = Word Data
mfhi t0 ; T0 = HI
la a1,HIWORD ; A1 = HIWORD Offset
sw t0,0(a1)  ; HIWORD = Word Data
PrintString 40,144, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,144, 8,8, FontBlack,VALUEWORDF,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 136,144, 8,8, FontBlack,TEXTWORDF,6 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,144, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,144, 8,8, FontBlack,LOWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 40,152, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,152, 8,8, FontBlack,VALUEWORDG,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 112,152, 8,8, FontBlack,TEXTWORDG,9 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,152, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,152, 8,8, FontBlack,HIWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
la a1,LOWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVLOCHECKF ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVLOPASSF ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,144, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDF
nop ; Delay Slot
DIVLOPASSF:
PrintString 280,144, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
la a1,HIWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVHICHECKF ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVHIPASSF ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,152, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDF
nop ; Delay Slot
DIVHIPASSF:
PrintString 280,152, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
DIVENDF:

la a1,VALUEWORDA ; A1 = Word Data Offset
lw t0,0(a1)      ; T0 = Word Data
la a1,VALUEWORDG ; A1 = Word Data Offset
lw t1,0(a1)      ; T1 = Word Data
la a1,LOWORD ; A1 = LOWORD Offset
div t0,t1 ; HI/LO = Test Word Data
mflo t0 ; T0 = LO
sw t0,0(a1)  ; LOWORD = Word Data
mfhi t0 ; T0 = HI
la a1,HIWORD ; A1 = HIWORD Offset
sw t0,0(a1)  ; HIWORD = Word Data
PrintString 40,168, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,168, 8,8, FontBlack,VALUEWORDA,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 184,168, 8,8, FontBlack,TEXTWORDA,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,168, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,168, 8,8, FontBlack,LOWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 40,176, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  48,176, 8,8, FontBlack,VALUEWORDG,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
PrintString 112,176, 8,8, FontBlack,TEXTWORDG,9 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintString 200,176, 8,8, FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
PrintValue  208,176, 8,8, FontBlack,HIWORD,3 ; Print HEX Chars To VRAM Using Width,Height Font At X,Y Position
la a1,LOWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVLOCHECKG ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVLOPASSG ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,168, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDG
nop ; Delay Slot
DIVLOPASSG:
PrintString 280,168, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
la a1,HIWORD      ; A1 = Word Data Offset
lw t0,0(a1)       ; T0 = Word Data
la a1,DIVHICHECKG ; A1 = Word Check Data Offset
lw t1,0(a1)       ; T1 = Word Check Data
nop ; Delay Slot
beq t0,t1,DIVHIPASSG ; Compare Result Equality With Check Data
nop ; Delay Slot
PrintString 280,176, 8,8, FontRed,FAIL,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
j DIVENDG
nop ; Delay Slot
DIVHIPASSG:
PrintString 280,176, 8,8, FontGreen,PASS,3 ; Print Text String To VRAM Using Width,Height Font At X,Y Position
DIVENDG:


PrintString 0,184, 8,8, FontBlack,PAGEBREAK,39 ; Print Text String To VRAM Using Width,Height Font At X,Y Position


Loop:
  b Loop
  nop ; Delay Slot

DIV:
  .db "DIV"

LOHIHEX:
  .db "LO/HI Hex"
RSRTHEX:
  .db "RS/RT Hex"
RSRTDEC:
  .db "RS/RT Dec"
TEST:
  .db "Test"
FAIL:
  .db "FAIL"
PASS:
  .db "PASS"

DOLLAR:
  .db "$"

TEXTWORDA:
  .db "0"
TEXTWORDB:
  .db "123456789"
TEXTWORDC:
  .db "123456"
TEXTWORDD:
  .db "123451234"
TEXTWORDE:
  .db "-123451234"
TEXTWORDF:
  .db "-123456"
TEXTWORDG:
  .db "-123456789"

PAGEBREAK:
  .db "----------------------------------------"

.align 4 ; Align 32-Bit
VALUEWORDA:
  .dw 0
VALUEWORDB:
  .dw 123456789
VALUEWORDC:
  .dw 123456
VALUEWORDD:
  .dw 123451234
VALUEWORDE:
  .dw -123451234
VALUEWORDF:
  .dw -123456
VALUEWORDG:
  .dw -123456789

DIVLOCHECKA:
  .dw 0x00000000
DIVHICHECKA:
  .dw 0x00000000
DIVLOCHECKB:
  .dw 0x000003E8
DIVHICHECKB:
  .dw 0x00000315
DIVLOCHECKC:
  .dw 0x00000000
DIVHICHECKC:
  .dw 0x0001E240
DIVLOCHECKD:
  .dw 0xFFFFFFFF
DIVHICHECKD:
  .dw 0x00000000
DIVLOCHECKE:
  .dw 0x000003E7
DIVHICHECKE:
  .dw 0xFFFE305E
DIVLOCHECKF:
  .dw 0x00000000
DIVHICHECKF:
  .dw 0xFFFE1DC0
DIVLOCHECKG:
  .dw 0x00000000
DIVHICHECKG:
  .dw 0x00000000

LOWORD:
  .dw 0
HIWORD:
  .dw 0

FontBlack:
  .incbin "FontBlack8x8.bin"
FontGreen:
  .incbin "FontGreen8x8.bin"
FontRed:
  .incbin "FontRed8x8.bin"

.close