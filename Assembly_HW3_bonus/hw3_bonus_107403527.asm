TITLE hw3_bonus

INCLUDE Irvine32.inc
 
main EQU start@0

Match PROTO,
	source:sdword,   			; source string address
    target:sdword,   			; target string address
    maxChars:DWORD   			; maximum number of characters to copy

.data
	Array1 sdword 2,4,-3,-9,7,1,8    ;陣列初始值
	Array2 sdword 2,-3,6,0,7,8,5     ;陣列初始值
	String BYTE " matches",0

.code
main PROC

	mov eax,0				;將eax設定初始值0

    INVOKE Match,			;呼叫函式並傳入參數 
      OFFSET Array1,
      OFFSET Array2,
      Lengthof Array1
	
    call Writeint			;列印eax儲存的目標數量
	mov edx,offset String	;列印字串
    call WriteString

    call Crlf				;空行
    call WaitMsg			;使用者輸入任意鍵結束程式
    exit
main ENDP
 

Match PROC uses ebx ecx edx esi edi,
    source:sdword,        
    target:sdword,        
    maxChars:DWORD          

    mov ecx,maxChars   		;設定外迴圈次數
    mov edi,target			;traget陣列傳入edi

LABEL1:						;外迴圈
    mov esi,source				;source陣列傳入esi
	mov edx,[edi]				;取edi裡的值移動至edx站存器準備進行比較
	push ecx					;將外迴圈ecx值傳入stack
	
	mov ecx,maxChars			;設定內迴圈的次數
L:								;內迴圈
	mov ebx,[esi]					;取esi裡的值移動至ebx站存器準備進行比較
	cmp ebx,edx						;比較
	je L1							;等於移至標籤L1
	jne L2							;不等於移至標籤L2
L1:
	inc eax							;找到相同值eax加一
L2:
	add esi,4						;esi移動至下一dword值
	LOOP L						;內迴圈

	pop ecx						;將外迴圈ecx值pop回來
	add edi,4					;edi移動至下一dword值
	LOOP LABEL1				;外迴圈
	
    ret						;結束函式
Match ENDP
END main