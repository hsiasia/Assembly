TITLE hw3

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
    INVOKE Match,           ;呼叫函式並傳入參數 
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

Match PROC uses ecx edx esi edi,
    source:sdword,        
    target:sdword,        
    maxChars:DWORD          

    mov ecx,maxChars    	;設定迴圈次數
    mov esi,source    		;source陣列傳入esi
    mov edi,target			;traget陣列傳入edi
	mov eax,0  				;將eax設定初始值0
L:							;迴圈
	cmpsd					;進行比較並移動到下一個dword
	je L1					;相等移至標籤L1
	jne L2					;不相等移至標籤L2
L1:
	inc eax					;找到相同值eax加一
L2:
	LOOP L					;迴圈
	
    mov edi,0      			;set null byte
    dec edi					;append null byte
	
    ret						;結束函式
Match ENDP
END main