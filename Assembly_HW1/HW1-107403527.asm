TITLE homework1

; This program locates the cursor and displays the
; system time. It uses two Win32 API structures.
; Last update: 6/30/2005

INCLUDE Irvine32.inc

; Redefine external symbols for convenience
; Redifinition is necessary for using stdcall in .model directive 
; using "start" is because for linking to WinDbg.  added by Huang
 
main          EQU start@0

;Comment @
;Definitions copied from SmallWin.inc:

.data
	MyID	DWORD ?
	Digit0	BYTE 3
	Digit1	BYTE 5
	Digit2	BYTE 2
	Digit3	BYTE 7

.code
main PROC
	movzx eax,Digit0
	shl eax,8
	
	movzx ebx,Digit1
	add eax,ebx
	shl eax,8
	
	movzx ecx,Digit2
	add eax,ecx
	shl eax,8
	
	movzx edx,Digit3
	add eax,edx
	
	mov MyID,eax
	
	exit
	
main ENDP
END main