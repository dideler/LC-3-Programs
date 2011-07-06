; Copyright (c) 2008-2011  Dennis Ideler  www.dennisideler.com
; Originally written for a second year course as part of an assignment.
;
; Counts the frequency of lowercase characters entered by the user.
; The program prompts the user to enter a line of lower case characters (a-z).
; It then reads the line. End of line (EOL) is determined by return/enter key.
; No character should occur more than 9 times in the line.
;
; Registers used: R0, R1, R2, R3, R4, R5, R6 (not R7, because TRAPS modify R7)
; Code is heavily commented since I consider assembly language to be cryptic.

.orig x3000  ; Starting address.

lea r0, msg0  ; Load address of msg0 into r0.
puts          ; Print contents of r0 (msg0).
lea r0, msg1	; Load address of msg1 into r0.
puts          ; Print contents of r0 (msg1 string).

lea r2, neg97   ; Load address of neg97 into r2.
ldr r2, r2, #0  ; Load contents of address in r2, into r2 (r2 now holds -97).

input:              ; Read input.
  in                ; Read one character into r0[7:0]
  add r5, r0, #-10  ; Subtract 10, because enter key has value 10.
  BRz output        ; If zero (enter pressed), we're done so branch to output.

  lea r4, array     ; Load starting address of array into r4.
  add r0, r0, r2    ; Subtract 97 to find ASCII index.
  BRz ltrcnt        ; If 0 (i.e. 'a'), branch to letter counter.

inputloop:        ; Else start reading input.
  add r4, r4, #1  ; Go to next index in array.
  add r0, r0, #-1 ; Decrement counter by 1.
  BRp inputloop   ; Loop if not zero.

ltrcnt:           ; Count frequency of character.
  ldr r0, r4, #0	; Load contents of array at index into r0.
  add r0, r0, #1	; Increment value of letter counter at index in array.
  str r0, r4, #0	; Store the new incremented value back into the array.
  BR input        ; Unconditional branch to input,

output:           ; Print character frequencies. Start by initializing values.
  lea r3, pos26   ; Load address of pos26 into r3.
  ldr r3, r3, #0  ; Load contents of address in r3, into r3 (r3 now holds 26).
  and r0, r0, #0  ; Reset r0 to zero.
  lea r6, pos97   ; Load address of pos97 into r6.
  ldr r6, r6, #0  ; Load contents (pos97) into r6.
  add r0, r6, #0  ; Add to r0 (to print letter 'a' later).

  lea r4, array   ; Point to start of array.
  lea r2, pos48   ; Load address of pos48 into r2.
  ldr r2, r2, #0  ; Load contents into r2 (r2 now holds 48).

outputloop:       ; Now we can start printing results.
  out             ; Print char stored in r0.

  lea r0, colon   ; Load address of colon into r0.
  ldr r0, r0, #0  ; Load contents of colon into r0.
  out             ; Print colon (i.e. ':').

  ldr r0, r4, #0  ; Load contents of address in array into r0.
  add r4, r4, #1  ; Increment array index.
  add r0, r0, r2  ; Convert from ASCII chart (0 starts at 48).
  out             ; Print character frequency.

  lea r0, newln   ; Load address of newln into r0.
  ldr r0, r0, #0  ; Load contents into r0.
  out             ; Print r0 (i.e. a newline).

  add r6, r6, #1  ; Go to next char in ASCII table.
  add r0, r6, #0  ; Add to r0, to print char at beginning of loop.
  add r3, r3, #-1 ; Decrease loop counter.
  BRp outputloop  ; Loop if positive.

halt              ; Else halt execution.

msg0:   .stringz "Character Counter - Copyleft (c) Dennis Ideler.\n"
msg1:   .stringz "Please enter a line of lower case text.\n"
array:  .blkw 26      ; Array of size 26.
neg97:  .fill #-97    ; Constant for converting from ASCII (97 is 'a').
pos26:  .fill #26     ; Constant used for counter (26 letters in alphabet).
colon:  .fill x003A   ; Hex value for colon (i.e. ':') in ASCII.
newln:  .stringz "\n"	; New line.
pos97:  .fill #97     ; Constant for converting to ASCII letters (a-z).
pos48:  .fill #48     ; Constant for converting to ASCII numbers (0-9)

.end
