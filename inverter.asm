.include "tn85def.inc"

rjmp init

.org 0x000A ; TIMER0_COMPA

  cp ZL, r21
  cpc r20, r22
  brcs slow

fast:
  sbiw Y, 5
  rjmp endint

slow:
  adiw Y,5


endint:
  clr r20
  cpi ZL, 30
  brcc far1
  clr ZL
far1:
  cpi ZL, 256-30
  brcs far2
  clr ZL
far2:
  mov r21, ZL
  reti


init:

  ; Timer1 - Differential PWM output on PB0 and PB1
  ldi r16, 0b00000011
  out DDRB,r16

  ldi r16,(1<<PLLE|1<<PCKE)
  out PLLCSR,r16

  ldi r16, (1<<PWM1A|1<<COM1A0|1<<CS12)
  out TCCR1,r16
  ldi r16,128
  out OCR1A,r16
  ldi r16,255
  out OCR1C,r16

  ; Timer0 - Count waveform cycles on PB2
  ldi r16, 1<<WGM01
  out TCCR0A, r16
  ldi r16,(1<<CS02|1<<CS01|1<<CS00) ; Clock source = T0 rising edge
  out TCCR0B,r16
  ldi r16, 4
  out OCR0A,r16
  ldi r16, (1<<OCIE0A)
  out TIMSK, r16


  ldi ZH, high(sineTable*2) ;const
  clr r0 ; const
  ldi r22, 6 ; const
  clr r20 

  ; YH:YL is used as fractional phase increase
  ; Main loop takes 10 cycles, lookup table is 256 bytes, target frequency 60Hz, CPU is approx 1MHz
  ; Starting value = (2**16) * 10 / (1e6/60/256) = 10066
  ldi YL, low( 10066 )
  ldi YH, high( 10066 )

sei


main:
  add r18, YL
  adc r19, YH
  adc ZL, r0
  adc r20, r0

  lpm r16, Z     ; 3 cycles
  out OCR1A,r16

rjmp main        ; 2 cycles



.org 0x80
sineTable:
.db 128,131,134,137,140,144,147,150,153,156,159,162,165,168,171,174
.db 177,179,182,185,188,191,193,196,199,201,204,206,209,211,213,216
.db 218,220,222,224,226,228,230,232,234,235,237,239,240,241,243,244
.db 245,246,248,249,250,250,251,252,253,253,254,254,254,255,255,255
.db 255,255,255,255,254,254,254,253,253,252,251,250,250,249,248,246
.db 245,244,243,241,240,239,237,235,234,232,230,228,226,224,222,220
.db 218,216,213,211,209,206,204,201,199,196,193,191,188,185,182,179
.db 177,174,171,168,165,162,159,156,153,150,147,144,140,137,134,131
.db 128,125,122,119,116,112,109,106,103,100,97,94,91,88,85,82
.db 79,77,74,71,68,65,63,60,57,55,52,50,47,45,43,40
.db 38,36,34,32,30,28,26,24,22,21,19,17,16,15,13,12
.db 11,10,8,7,6,6,5,4,3,3,2,2,2,1,1,1
.db 1,1,1,1,2,2,2,3,3,4,5,6,6,7,8,10
.db 11,12,13,15,16,17,19,21,22,24,26,28,30,32,34,36
.db 38,40,43,45,47,50,52,55,57,60,63,65,68,71,74,77
.db 79,82,85,88,91,94,97,100,103,106,109,112,116,119,122,125

