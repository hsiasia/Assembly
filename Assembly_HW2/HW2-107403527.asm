TITLE Lab of week7

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

ChStrs BYTE "********"    ;宣告數字7
	   BYTE "      **"
	   BYTE "      **"
	   BYTE "      **"
	   BYTE "      **"
	   BYTE "      **"
	   BYTE "      **"
	   BYTE "      **"
.code

change PROC USES ECX		;保留function外的ecx

	MOV ECX,8				;重設一個函式中迴圈計數器
L:
	mov al, [esi]			;將esi中的byte值存入al
	cmp al,40				;比較al與常數40的大小
	jb L1					;al<40 空白跳至標籤L1
	ja L2					;al>40 "*"跳至標籤L2
L1:
	add al,16				;透過al值加16轉換ASCII code成0
	JMP L3					;跳至標籤L3避免多餘轉換
L2:
	add al,7				;透過al值加16轉換ASCII code成1
L3:
	mov [esi],al			;al值放回esi
	
	call WriteChar			;列印
	inc esi					;移動至下一個esi暫存器位置
	LOOP L					;進行迴圈
	RET						;結束函式
change ENDP

main PROC
	mov esi, OFFSET ChStrs	;memory地址存入esi	
	MOV ECX,8				;設定外部迴圈計數器
L1: 
	CALL change				;呼叫轉換函式
	call Crlf				;換行
	LOOP L1					;進行迴圈
	
	call WaitMsg
	exit
	
main ENDP
END main