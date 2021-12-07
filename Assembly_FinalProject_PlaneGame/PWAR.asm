INCLUDE Irvine32.inc

main	EQU start@0

.stack 4096

DetectShoot proto								;偵測是否射擊，呼叫BulletShoot。
BulletShoot proto,planeX:word,planeY:word		;玩家射擊，呼叫BulletMove。
BulletMove proto								;玩家子彈移動，呼叫DetectMove。
DetectMove proto								;偵測移動 直接使用 呼叫MovRight,MovLeft。
MovRight proto									;右移。
MovLeft proto									;左移。
AllyRevive proto								;玩家復活。
EnemyMove proto, enemyP:coord					;敵方移動。
EnemyAttack proto,enemyX:word,enemyY:word 		;敵方射擊，呼叫AttackMove。
AttackMove proto 								;敵方子彈移動。
EnemyRevive proto								;敵方復活。
WriteHP proto                                   ;顯示血量。
WriteScore proto                                ;顯示分數。
enemyDisappear proto, enemyP:coord              ;消去敵方飛機。
.data
titleStr byte "----- Plane War -----",0         ;主控台視窗標題。

;初始畫面。
startLogo0 byte "###############################################################################"
startLogo1 byte "|============-|        |====|  |====|  |====|        /====\       |===========|"
startLogo2 byte "|   _______   |        |    |  |    |  |    |       / ___  \      |           |"
startLogo3 byte "|   |      |  |        |     \ |    |  /    |      / /   \  \     |  ======|  |"
startLogo4 byte "|   |------|  |         \     \|    |/     /      /  ======  \    |  |_____|  |"
startLogo5 byte "|   __________|          \     =    =     /      /   ______   \   |  _____   _|"
startLogo6 byte "|   |           |-----|   \              /      /   /      \   \  |  |    \  \ "
startLogo7 byte "|___|           |_____|    \_____/\_____/      /___/        \___\ |__|     \__\"
startLogo8 byte "###############################################################################"
startLogo9 byte "                          --press 'g' to start--                               "
startLogo10 byte "                      --press 'h' to introduction--                            "
startColor word lengthof startLogo0 DUP (0Dh)       							;初始畫面顏色。
startPos COORD <20,10>    													    ;初始畫面初期繪製座標。

;遊戲介紹畫面。
introduction1 byte "how to pilot the airplane:"
introduction2 byte "left->press 'i', right->press 'p'."
introduction3 byte "how to fire bullets:"
introduction4 byte "press 's' for firing bullets."
introduction5 byte "If you are hit by an enemy bullet, you will lose 100 HP."
introduction6 byte "please press 'g' to start."
introductionPos COORD <20,7>													;遊戲介紹畫面初期繪製座標。
score word 1              														;用以敵方飛機在移動第幾次時再出現下一台。

;飛機樣式。
allyPlaneUp BYTE (4)DUP(20h),2Fh,2Bh,5Ch,(4)DUP(20h)
allyPlaneMid1 BYTE (2)DUP(20h),2Fh,2Dh,7Ch,20h,7Ch,2Dh,5Ch,(2)DUP(20h)
allyPlaneMid2 BYTE 2Fh,(2)DUP(2Dh),7Ch,(3)DUP(20h),7Ch,(2)DUP(2Dh),5Ch
allyPlaneDown BYTE (2)DUP(20h),2Fh,2Dh,7Ch,3Dh,7Ch,2Dh,5Ch,(2)DUP(20h)
allyAttr WORD 11 DUP(0Bh)														;飛機顏色。
allyDisAttr WORD 11 DUP (00h)													;飛機消失顏色。
allyPosition COORD <40,25>														;飛機初始位置。
allyCondition byte 1															;飛機狀態 1為活著,0為死掉復活中。
allyHP dword 500 		    													;飛機血量。
allyScore Dword 0																;飛機得分。
bullet byte '8'																	;子彈樣式。
bulletPos COORD <?,?>															;子彈位置。
bulletAttr word 0Bh																;子彈顏色。
bulletDisappearAttr word 00h													;子彈消失顏色。

;敵人樣式。
enemyTop BYTE " ___ "
enemyBody BYTE "-\*/-"
enemyBottom BYTE "  *  "
enemyAttr word 5 DUP(0Ch)						;敵人飛機顏色。
enemyDisappearAttr word 5 DUP(00h)				;敵人飛機消失顏色。
enemyPosition COORD <60,0>						;敵人飛機初始位置。
enemy1Position COORD <60,0>
enemy2Position COORD <40,0>
enemy3Position COORD <30,0>
enemy4Position COORD <80,0>
enemy5Position COORD <70,0>
enemy6Position COORD <50,0>
enemyCondition byte 1							;敵人飛機狀態 1為活著,0為被擊落。
Attack byte '.'									;敵人子彈樣式。
AttackPos COORD <?,?>							;敵人子彈位置。
AttackAttr word 0Ah								;敵人子彈顏色。
AttackDisappearAttr word 0						;敵人子彈消失顏色。

outputHandle DWORD 0 							;CONSOLE 控制ID。
bytesWritten DWORD ?							;回傳值。
count DWORD 0									;回傳值。
cellsWritten DWORD ?							;奇怪的回傳值。

input byte ?									;變數偵測是否按S。
inputMov byte ?									;變數偵測是否按i或p。
inputQuit byte ?								;變數偵測是否按ESC。

hp BYTE 'HP:'
hpPosition COORD <1,1>                          ;HP位置。
allyhpPosition COORD <4,1>                      ;血量值位置。
hpAttr word 3 DUP(0Ah)                          ;血量顯示顏色。

Scorew BYTE "SCORE:"
ScorePosition COORD <1,2>                       ;SCORE位置。
allyScorePosition COORD <7,2>                   ;分數值位置。
ScoreAttr word 6 DUP(0Ah)                       ;分數顯示顏色。

;結束畫面。
endLogo0 byte "###############################################################################"
endLogo1 byte "||==|        |=========|  |========|  |========|  |========|     |=========|  |"
endLogo2 byte "||  |        |  _____  |  |  ______|  |  ______|  |   __   |     |______   |  |"
endLogo3 byte "||  |        |  |   |  |  |  |_____   |  |_____   |  |  |  |         ___|  |  |"
endLogo4 byte "||  |        |  |   |  |  |_____   |  |   _____|  |  |__|  |        |   ___|  |"
endLogo5 byte "||  |______  |  |___|  |   _____|  |  |  |______  |  ____  |        |__|      |"
endLogo6 byte "||        |  |         |  |        |  |        |  |  |   \ \         __       |"
endLogo7 byte "||========|  |=========|  |========|  |========|  |==|    \=\       |__|      |"
endLogo8 byte "###############################################################################"
endLogo9 byte "                          --press 'anychar' to end--                           "
endColor word lengthof endLogo0 DUP (0Dh)
endPos COORD <20,10>

.code
main proc

	INVOKE SetConsoleTitle, offset titleStr        ;設定主控台視窗標題。
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE         
    mov outputHandle, eax
	
	;繪製Startlogo(初始畫面)。
    INVOKE WriteConsoleOutputAttribute,            
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo0,
		lengthof startLogo0,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo1,
		lengthof startLogo1,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo2,
		lengthof startLogo2,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo3,
		lengthof startLogo3,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo4,
		lengthof startLogo4,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo5,
		lengthof startLogo5,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo6,
		lengthof startLogo6,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo7,
		lengthof startLogo7,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo8,
		lengthof startLogo8,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo9,
		lengthof startLogo9,
		startPos,
		offset bytesWritten
    inc startPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		startPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset startLogo10,
		lengthof startLogo10,
		startPos,
		offset bytesWritten
q:
    call ReadChar                			 ;偵測要開始遊戲還是看介紹。
    .if al=='g'
		call Clrscr
    jmp start
    .elseif al=='h'
        jmp introduction
    .else
        jmp q
    .endif
	
	;繪製Introduction。
    introduction:
        call Clrscr
        INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction1,
		lengthof introduction1,
		introductionPos,
		offset bytesWritten
    inc introductionPos.Y
    INVOKE sleep,500
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction2,
		lengthof introduction2,
		introductionPos,
		offset bytesWritten
    add introductionPos.Y, 2
    INVOKE sleep,500
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction3,
		lengthof introduction3,
		introductionPos,
		offset bytesWritten
    inc introductionPos.Y
    INVOKE sleep,500
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction4,
		lengthof introduction4,
		introductionPos,
		offset bytesWritten
    add introductionPos.Y, 2
    INVOKE sleep,500
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction5,
		lengthof introduction5,
		introductionPos,
		offset bytesWritten
    add introductionPos.Y, 3
    INVOKE sleep,500
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset startColor,
		lengthof startColor,
		introductionPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset introduction6,
		lengthof introduction6,
		introductionPos,
		offset bytesWritten
p:
    call ReadChar                			   ;偵測要不要開始遊戲。
    .if al=='g'
		call Clrscr
    .else
        jmp p
    .endif
	
start:

	;繪製初始友軍。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y, 3                	  ;y軸調回初始位置。

	;繪製初始血量。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset hpAttr,
		sizeof hp,
		hpPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset hp,
		sizeof hp,
		hpPosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyhpPosition
	mov eax, allyHP
	call WriteDec

	;繪製初始分數。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset ScoreAttr,
		lengthof SCOREW,
		ScorePosition,
		offset bytesWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset SCOREW,
		lengthof SCOREW,
		ScorePosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyScorePosition
	mov eax, allyScore
	call WriteDec

control:

    .if score>0
		;若敵軍到最下方，敵軍消失並從任意最上方位置重新出現。
		.if enemy1Position.Y>22                       
			INVOKE enemyDisappear, enemy1Position     ;下方敵軍消失。
            sub allyScore,1000                        ;分數變回正確分數(enemyDisappear裡會扣1000分)。
            call WriteScore
			mov ax,100
			call RandomRange
            add ax,12                                 ;防止敵軍從分數、HP的位置出現。
            mov enemy1Position.X,ax                   ;敵軍X座標設隨機位置。
            mov enemy1Position.Y,0                    ;敵軍移到最上方。
        .endif
		INVOKE EnemyMove,enemy1Position               ;敵軍移動。
        inc enemy1Position.Y
    .endif
    .if score>4
        .if enemy2Position.Y>22
			INVOKE enemyDisappear, enemy2Position
            sub allyScore,1000
            call WriteScore
            mov ax, 100
            call RandomRange
            add ax,12
            mov enemy2Position.X,ax
            mov enemy2Position.Y,0
        .endif
		INVOKE EnemyMove,enemy2Position
        inc enemy2Position.Y
    .endif
    .if score>9
        .if enemy3Position.Y>22
            INVOKE enemyDisappear, enemy3Position
            sub allyScore,1000
            call WriteScore
			mov ax, 100
            call RandomRange
            add ax,12
            mov enemy3Position.X,ax
            mov enemy3Position.Y,0
        .endif
		INVOKE EnemyMove,enemy3Position
		inc enemy3Position.Y
    .endif
    .if score>14
        .if enemy4Position.Y>22
            INVOKE enemyDisappear, enemy4Position
            sub allyScore,1000
            call WriteScore
			mov ax, 100
            call RandomRange
            add ax,12
            mov enemy4Position.X,ax
            mov enemy4Position.Y, 0
		.endif
		INVOKE EnemyMove,enemy4Position
        inc enemy4Position.Y
    .endif
    .if score>19
        .if enemy5Position.Y>22
            INVOKE enemyDisappear, enemy5Position
            sub allyScore,1000
            call WriteScore
			mov ax, 100
			call RandomRange
            add ax,12
            mov enemy5Position.X,ax
            mov enemy5Position.Y,0
        .endif
		INVOKE EnemyMove,enemy5Position
        inc enemy5Position.Y
    .endif
    .if score>24
        .if enemy6Position.Y>22
            INVOKE enemyDisappear, enemy6Position
            sub allyScore,1000
            call WriteScore
			mov ax, 100
            call RandomRange
            add ax,12
            mov enemy6Position.X,ax
            mov enemy6Position.Y,0
        .endif
		INVOKE EnemyMove,enemy6Position
        inc enemy6Position.Y
    .endif
	invoke DetectShoot	             				   ;偵測射擊。
	invoke DetectMove								   ;偵測移動。
	jmp control								    	   ;迴圈讓敵人下移。

main endp

;顯示血量。
WriteHP proc
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset hpAttr,
		sizeof hp,
		hpPosition,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset hp,
		sizeof hp,
		hpPosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyhpPosition
	mov eax, allyHP
	call WriteDec

	ret
WriteHP endp

WriteScore proc
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset ScoreAttr,
		lengthof SCOREW,
		ScorePosition,
		offset bytesWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset SCOREW,
		lengthof SCOREW,
		ScorePosition,
		offset count
	INVOKE SetConsoleCursorPosition,
        outputHandle,
		allyScorePosition
	mov eax, allyScore
	call WriteDec

	ret
WriteScore endp

;友方偵測射擊。
DetectShoot proc
    INVOKE Sleep,15
    call ReadKey
    mov input,al
.IF input=='s'
    INVOKE BulletShoot,allyPosition.X,allyPosition.Y
.endif
	ret
DetectShoot endp

;友方子彈射擊。
BulletShoot proc USES eax edx ecx ebx,
	planeX:word,
	planeY:word                							;要傳planeX,planeY。

    mov ax,planeX
    mov dx,planeY
	add ax,5                 							;座標橋回子彈該出現的位置。
	sub dx,4                  							;同上。
    mov bulletPos.X,ax
    mov bulletPos.Y,dx

bulletup:
	.if bulletPos.Y!=0
		INVOKE BulletMove      							;子彈向上移動。
		jmp checkX
	.else
		jmp endshoot
	.endif
	
;確認敵方有沒有被我方子彈射中。
checkX:
	mov cx, enemy1Position.X
	mov bx, enemy1Position.Y        					;enemy1Position存入暫存器。
	inc bx
        sub cx, bulletPos.X         					;cx用於判斷子彈擊中敵方。
	.if cx==0
		jmp check1Y
	.elseif cx==-1
		jmp check1Y
	.elseif cx==-2
		jmp check1Y
	.elseif cx==-3
		jmp check1Y
	.elseif cx==-4
		jmp check1Y
	.endif
    mov cx, enemy2Position.X
	mov bx, enemy2Position.Y    						;enemy2Position存入暫存器。
	inc bx
    sub cx, bulletPos.X          						;cx用於判斷子彈擊中敵方。
	.if cx==0
		jmp check2Y
	.elseif cx==-1
		jmp check2Y
	.elseif cx==-2
		jmp check2Y
	.elseif cx==-3
		jmp check2Y
	.elseif cx==-4
		jmp check2Y
	.endif
    mov cx, enemy3Position.X
	mov bx, enemy3Position.Y     						;enemy3Position存入暫存器。
	inc bx
    sub cx, bulletPos.X          						;cx用於判斷子彈擊中敵方。
	.if cx==0
		jmp check3Y
	.elseif cx==-1
		jmp check3Y
	.elseif cx==-2
		jmp check3Y
	.elseif cx==-3
		jmp check3Y
	.elseif cx==-4
		jmp check3Y
	.endif
    mov cx, enemy4Position.X
	mov bx, enemy4Position.Y     						;enemy4Position存入暫存器。
	inc bx
    sub cx, bulletPos.X          						;cx用於判斷子彈擊中敵方。
	.if cx==0
		jmp check4Y
	.elseif cx==-1
		jmp check4Y
	.elseif cx==-2
		jmp check4Y
	.elseif cx==-3
		jmp check4Y
	.elseif cx==-4
		jmp check4Y
	.endif
    mov cx, enemy5Position.X
	mov bx, enemy5Position.Y     						;enemy5Position存入暫存器。
	inc bx
    sub cx, bulletPos.X         						;cx用於判斷子彈擊中敵方。
	.if cx==0
		jmp check5Y
	.elseif cx==-1
		jmp check5Y
	.elseif cx==-2
		jmp check5Y
	.elseif cx==-3
		jmp check5Y
	.elseif cx==-4
		jmp check5Y
	.endif
    mov cx, enemy6Position.X
	mov bx, enemy6Position.Y     						;enemy6Position存入暫存器。
	inc bx
    sub cx, bulletPos.X          						;cx用於判斷子彈擊中敵方。
       	.if cx==0
		jmp check6Y
	.elseif cx==-1
		jmp check6Y
	.elseif cx==-2
		jmp check6Y
	.elseif cx==-3
		jmp check6Y
	.elseif cx==-4
		jmp check6Y
    .else
        jmp bulletup
	.endif
	
;進一步確認Y座標是否相同。
check1Y:                        
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy1Position
        mov enemy1Position.Y,31
	    jmp endshoot
    .else
        jmp bulletup
	.endif
check2Y:
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy2Position
        mov enemy2Position.Y,31
		jmp endshoot
    .else
        jmp bulletup
	.endif
check3Y:
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy3Position
        mov enemy3Position.Y,31
		jmp endshoot
    .else
        jmp bulletup
	.endif
check4Y:
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy4Position
        mov enemy4Position.Y,31
		jmp endshoot
    .else
        jmp bulletup
	.endif
check5Y:
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy5Position
        mov enemy5Position.Y,31
		jmp endshoot
    .else
        jmp bulletup
	.endif
check6Y:
	.if bulletPos.Y==bx
		INVOKE enemyDisappear, enemy6Position
        mov enemy6Position.Y,31
		jmp endshoot
    .else
        jmp bulletup
	.endif

endshoot:
    ret
BulletShoot endp

enemyDisappear proc,
        enemyP:coord
    add allyScore,1000
    call WriteScore
	
	;若被射中，enemy消失。
	dec enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyTop,
		enemyP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyP,
		offset count

	inc enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBody,
		enemyP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyP,
		offset count

	inc enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBottom,
		enemyP,
		offset cellsWritten

	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyP,
		offset count
        mov enemyP.Y,23
	INVOKE Sleep,8
	ret
enemyDisappear endp

;友方子彈移動。
BulletMove proc USES eax ebx ecx edx

	;子彈繪製。
	INVOKE WriteConsoleOutputAttribute,
       outputHandle,
       offset bulletAttr,
       lengthof bulletAttr,
       bulletPos,
	   offset count
	INVOKE WriteConsoleOutputCharacter,
       outputHandle,
       offset bullet,
       lengthof bullet,
       bulletPos,
	   offset bytesWritten

	INVOKE Sleep,15
	INVOKE DetectMove					;子彈在飛的同時，偵測移動。

	;子彈消失。
    INVOKE WriteConsoleOutputAttribute,
      outputHandle,
      offset bulletDisappearAttr,
      lengthof bulletDisappearAttr,
      bulletPos,
	  offset count
    INVOKE WriteConsoleOutputCharacter,
       outputHandle,
       offset bullet,
       lengthof bullet,
       bulletPos,
	   offset bytesWritten

    dec bulletPos.Y						;子彈座標上移一格。
    ret
BulletMove endp

;角色復活閃爍，無法射擊移動。
AllyRevive proc uses ecx
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    ;call Clrscr

    mov allyCondition,0;				;飛機是否為無敵狀態。
	mov ecx,3

blink:
	push ecx
	
    ;飛機繪製。
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3				;y軸調回初始位置。
	invoke Sleep,300					;延遲閃爍。

	;飛機結束擦除。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3				;y軸調回初始位置。

	invoke DetectShoot
	invoke DetectMove

    invoke Sleep,300
       pop ecx
       dec ecx
    .IF ecx!=0
        jmp blink						;閃爍迴圈三次。
    .ENDIF

	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3				;y軸調回初始位置。

;判斷HP是否為0，若是則繪製結束畫面。
.if allyHP==0
theend:

	call Clrscr

	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo0,
		lengthof endLogo0,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo1,
		lengthof endLogo1,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo2,
		lengthof endLogo2,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo3,
		lengthof endLogo3,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo4,
		lengthof endLogo4,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo5,
		lengthof endLogo5,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo6,
		lengthof endLogo6,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo7,
		lengthof endLogo7,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo8,
		lengthof endLogo8,
		endPos,
		offset bytesWritten
    inc endPos.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset endColor,
		lengthof endColor,
		endPos,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset endLogo9,
		lengthof endLogo9,
		endPos,
		offset bytesWritten

call WaitMsg
exit
.else
keepgo:
    mov allyCondition,1					;設定飛機無敵狀態。
.endif					
    ret

AllyRevive endp

;偵測玩家移動。
DetectMove proc
    INVOKE Sleep,15
    call ReadKey
    mov inputMov,al

	.if inputMov=='i'
		INVOKE MovLeft
	.elseif inputMov=='p'
		INVOKE MovRight
	.endif
    ret
DetectMove endp

;向右移動。
MovRight proc

	;擦掉原處。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3
	INC allyPosition.X

	;重新繪製。
L5:	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3

    ret
MovRight endp

;向左移動。
MovLeft proc

	;擦掉原處。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyDisAttr,
		lengthof allyDisAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

	sub allyPosition.Y,3
	DEC allyPosition.X

	;重新繪製。
L5:	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneUp,
		lengthof allyPlaneUp,
		allyPosition,
		offset bytesWritten
    inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid1,
		lengthof allyPlaneMid1,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneMid2,
		lengthof allyPlaneMid2,
		allyPosition,
		offset bytesWritten
	inc allyPosition.Y
    INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset allyAttr,
		lengthof allyAttr,
		allyPosition,
		offset count
    INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset allyPlaneDown,
		lengthof allyPlaneDown,
		allyPosition,
		offset bytesWritten

    sub allyPosition.Y,3

	ret
MovLeft endp

;敵方移動。
EnemyMove proc USES eax ebx ecx edx,
    enemyP:coord
    add score,1

	INVOKE Sleep,15
    
	;擦掉敵軍。
	dec enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyTop,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyP,
		offset count
	inc enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBody,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyP,
		offset count
	inc enemyP.Y    
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyDisappearAttr,
		sizeof enemyBottom,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyP,
		offset count

    dec enemyP.Y               			;敵軍Y座標橋回正確位置。
	
	;繪製敵軍。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyTop,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyTop,
		sizeof enemyTop,
		enemyP,
		offset count
	inc enemyP.Y
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyBody,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBody,
		sizeof enemyBody,
		enemyP,
		offset count
	inc enemyP.Y   
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset enemyAttr,
		sizeof enemyBottom,
		enemyP,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset enemyBottom,
		sizeof enemyBottom,
		enemyP,
		offset count

	sub enemyP.Y, 2                      ;敵軍Y座標橋回正確位置。
	INVOKE EnemyAttack,enemyP.X,enemyP.Y ;呼叫敵人射擊。
    ret
EnemyMove endp

;敵方射擊。
EnemyAttack proc USES eax edx ecx ebx ,enemyX:word,enemyY:word

    mov ax,enemyX
    mov dx,enemyY						 ;傳入enemyPosition。
	add ax,2							 ;座標移動到子彈該出現的位置。
	add dx,3
    mov AttackPos.X,ax
    mov AttackPos.Y,dx					 ;子彈位置存入AttackPos。

keep:
	.if AttackPos.Y==22
		mov bx,allyPosition.Y
		mov cx,allyPosition.X			 ;allyPosition存入暫存器。
		sub cx,AttackPos.X				 ;cx用於判斷子彈擊中飛機。
	.endif
	.IF AttackPos.Y!=30				
		INVOKE AttackMove				 ;若子彈沒到最終位置，持續呼叫子彈移動。
		jmp LOO
	.ELSE
		jmp endAttack
	.ENDIF
LOO:									 ;判斷子彈是否擊中飛機X軸。
	.if cx == -1
		jmp enddd
	.elseif cx == -2
		jmp enddd
	.elseif cx == -3
		jmp enddd
	.elseif cx == -4
		jmp enddd
	.elseif cx == -5
		jmp enddd
	.elseif cx == -6
		jmp enddd
	.elseif cx == -7
		jmp enddd
	.elseif cx == -8
		jmp enddd
	.elseif cx == -9
		jmp enddd
	.elseif cx == -10
		jmp enddd
	.elseif cx == -11
		jmp enddd
	.elseif cx == 0
		jmp enddd
	.else
		jmp keep
	.endif
enddd:
	.if AttackPos.Y==bx					;進一步判斷子彈是否擊中飛機Y軸。
		sub allyHP,100         			;擊中，減少血量。
		INVOKE WriteHP          		;顯示血量。
		jmp endddd
	.else
		jmp keep
	.endif
endddd:
	.if allyCondition==1				;進一步判斷飛機是否處於無敵狀態。
		invoke AllyRevive				;呼叫被擊中閃爍。
		jmp endAttack
	.endif
endAttack:
    ret
EnemyAttack endp

;敵人子彈移動。
AttackMove proc USES eax ebx ecx edx

	;繪製子彈。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset AttackAttr,
		1,
		AttackPos,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset Attack,
		1,
		AttackPos,
		offset count
	INVOKE DetectShoot
	INVOKE DetectMove
	INVOKE Sleep,10
	
	;擦除子彈。
	INVOKE WriteConsoleOutputAttribute,
		outputHandle,
		offset AttackDisappearAttr,
		1,
		AttackPos,
		offset cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,
		offset Attack,
		1,
		AttackPos,
		offset count

    inc AttackPos.Y				;增加子彈Y軸，往下飛。

    ret
AttackMove endp
end main
