; Copyright 2008-2011 (c)  Dennis Ideler  www.dennisideler.com
; Originallly written for a second year course as part of an assignment.
;
; This program can encrypt or decrypt messages using a simple caesar cipher.
;
; This code is heavily commented since I consider assembly language to be
; cryptic on its own. All 8 registers of the LC-3 are used in this program.

.orig x3000 ; Starting point of the program.

BR start  ; Branch to the start routine.

newln:  .stringz "\n"
msg1:   .stringz "If you want to encrypt your message, type: E\nIf you want to decrypt your message, type: D\n"
msg2:   .stringz "Enter the key you wish to use (single digit from 1 to 9).\n"
msg3:   .stringz "You may now enter a message of no more than 20 lower case characters; when done press Enter.\n"

; Prints out the instructions to the user and reads some user input.
start:
  lea r0, msg1  ; Load address of message1 into R0.
  puts          ; Print message1.

  in              ; Read user input into r0.
  add r3, r0, #0  ; Copy R0 to R3 (stored for later use).

  lea r0, newln ; Load address of newline into R0.
  puts          ; Print newline.

  lea r0, msg2  ; Load address of message2 into R0.
  puts          ; Print message2.

  in              ; Read user input into R0.
  lea r0, newln ; Load address of newline into R0.
  lea r1, neg48   ; Load address of neg48 into R1.
  ldr r1, r1, #0  ; Load contents of neg48 into R1 (R1 now holds -48).
  add r2, r0, r1  ; Subtract 48 from the ASCII value and store in R2.

  puts          ; Print new line.

  lea r0, msg3  ; Load address of message3 into R0.
  puts          ; Print message3.

  lea r4, array   ; Load starting point address of array.
  and r1, r1, #0  ; Initialize R1 to zero.


; Reads in the message that the user whishes to encrypt/decrypt.
; This routine is a loop because only one character can be read at a time.
; The enter key acts as a terminator to the loop.
; A counter keeps track of how many characters are read.
input:
  in                ; Read in a single character to R0.
  add r5, r0, #-10  ; Subtract 10 because enter key is 10.
  BRz checkChar     ; If zero, branch to checkChar routine.
                    ; Else continue the loop.
  str r0, r4, #0  ; Store char in array.
  add r4, r4, #1  ; Increment index of array.
  add r1, r1, #1  ; Increment input counter.
  BR input        ; Unconditional branch to input.


; Figures out if the user wanted to encrypt or decrypt a message.
; If 'E' then encrypt. If 'D' then decrypt.
; Another option (not implemented) was to branch to decrypt if not encrypt.
checkChar:
  lea r6, neg69   ; Load address of neg69 into R6.
  ldr r6, r6, #0  ; Load contents of neg69 into R6 (R6 now holds -69).
  add r0, r3, r6  ; Add -69 to the value in R3, to check if it's 'E'.
  BRz encrypt     ; If zero, branch to encrypt.
                  ; Else check if it's 'D'.
  lea r6, neg68   ; Load address of neg68 into R6.
  ldr r6, r6, #0  ; Load contents of neg68 into R6 (R6 now holds -68).
  add r0, r3, r6  ; Add -68 to the value in R3, to check if it's 'D'.
  BRz decrypt     ; If zero, branch to decrypt.


; Encryption is divided into two routines:
; 1. Set up memory array and counter.
; 2. Loop over every character to encrypt it.
;    Each iteration the rightmost bit is flipped and the key is added.
encrypt:
  lea r4, array   ; Load (starting) address of array into R4.
  add r5, r1, #0  ; Copy # of characters in message to R5, to use as counter.
;  lea r5, pos20   ; Load address of pos20 into R5.
;  ldr r5, r5, #0  ; Load contents of pos20 into R5 (used as counter).

; TODO: skip character if it's whitespace
encryptLoop:
  ldr r0, r4, #0  ; Load contents at array index into R0.
  jsr flipBit     ; Jump to flip bit routine and jump back when done.
  add r0, r6, r2  ; Add the key to the char and store encrypted char in R0.
  str r0, r4, #0  ; Store the encrypted char in the array (overwrite) FIXME: Why not store it here in the above instruction?
  add r4, r4, #1  ; Increment array index.
  add r5, r5, #-1 ; Decrement counter.
  BRp encryptLoop ; If positive, loop.
  BR output       ; Else done. Branch to output.


; Decryption is divided into two routines:
; 1. Set up memory array and counter.
; 2. Loop over every character to decrypt it.
;    Each iteration the rightmost bit is flipped and the key is subtracted.
;    => All numbers are in two's complement representation,
;       so we flip the bits of the key and add 1 to get the negative value.
decrypt:
  lea r4, array   ; Load (starting) address of array into R4.
  add r5, r1, #0  ; Copy # of characters in message to R5, to use as counter.
;  lea r5, pos20   ; Load address of pos20 into R5.
;  ldr r5, r5, #0  ; Load contents of pos20 into R5 (used as counter)

; TODO: skip character if it's whitespace
decryptLoop:
  ldr r0, r4, #0  ; Load contents at array index into R0.
  not r2, r2      ; Invert key.
  add r2, r2, #1  ; Add 1, key is now negative.
  add r0, r0, r2  ; Subtract key from char and store in R0.
  jsr flipBit     ; Jump to flip bit routine and jump back when done.
  str r6, r4, #0  ; Store the decrypted char in the array (overwrite).
  add r4, r4, #1  ; Increment array index.
  add r5, r5, #-1 ; Decrement counter.
  BRp decryptLoop ; If positive, loop.
  BR output       ; Else done. Branch to output.


; Toggles the rightmost bit [0:0] of the current character.
; It does this by simulating XOR with 1. Example: 111 XOR 001 = 110.
; Steps:
; 1. NOTs the character to get the inverse.
; 2. ANDs 1 with the inverse, this shows what the rightmost bit should be.
; 3. ANDs original character with -2 to remove the rightmost bit if present.
; 4. ADDs value of what rightmost bit should be (calculated in step 2) with the
;    value that had its rightmost bit removed (calculated in step 3).
; Example:
; 1. 101 (R0) NOT = 010 (R3)
; 2. 010 (R3) AND 001 = 000 (R3)
; 3. 101 (R0) AND 110 = 100 (R0)
; 4. 000 (R3) ADD 100 (R0) = 100 (R6)
flipBit:
  not r3, r0
  and r3, r3, #1  ; Note: 1 = 000 0001
  and r0, r0, #-2 ; Note: -2 = 111 1110 (two's complement, signed representation)
  add r6, r0, r3
  ret             ; Return to the instruction whos address is stored in R7.


; Prints the encrypted or decrypted message.
output:
  lea r4, array ; Load (starting) address of array.

outputLoop:
  ldr r0, r4, #0  ; Load contents of address at array index into R0.
  out;            ; Print character.
  add r4, r4, #1  ; Increment array index.
  add r1, r1, #-1 ; Decrease counter.
  BRp outputLoop  ; If positive, loop.

halt  ; Halt execution.

array:  .blkw	20    ; Array of size 20.
neg48:  .fill	#-48  ; Constant for converting numbers from ASCII to decimal.
neg69:  .fill	#-69  ; Constant for the inverse of 'E'.
neg68:  .fill	#-68  ; Constant for the inverse of' D'.
pos20:  .fill	#20   ; Constant used as loop counter.

.end
