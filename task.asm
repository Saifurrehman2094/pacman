INCLUDE Irvine32.inc
include macros.inc
;INCLUDELIB  winmm.lib

.386
;.model flat,stdcall
.stack 4096
BUFFER_SIZE = 5000
.data
buffer BYTE BUFFER_SIZE DUP(?)
filename   BYTE  "Instructions.txt",0
fileHandle  HANDLE ?
ground BYTE "------------------------------------------------------------------------------------------------------------------------",0
ground1 BYTE "|",0ah,0
ground2 BYTE "|",0
pac0 db  "                                  _ __   ____  ___   __ ___   __   ____",0
pac1 db  "                                 | '_ \ / _` |/ __| '_ ` _ \ / _` | '_ \",0 
pac2 db  "                                 | |_) | (_| | (__  | | | | | (_| | | | |",0
pac3 db  "                                 | .__/ \__,_|\___|_| |_| |_|\__,_|_| |_|",0
pac4 db  "                                 |_|",0      
menu1 db "___________________",0
menu2 db "|      Menu       |",0
menu3 db "-------------------",0
menu4 db "| 1. Start Game   |",0
menu5 db "| 2. Instructions |",0
menu6 db "| 3. Exit         |",0
menu7 db "|-----------------|",0
menu8 db "Enter Option: ",0

prompt2 db "Level: ",0

xGhost1 dw 1
yGhost1 dw 10

temp byte ?

strScore BYTE "Your score is: ",0
score dd 0

xPos BYTE 20
yPos BYTE 11

checkGhost db 0

dwall db "\",0

xc dd 0
yc dd 0

levelno db 1

liv db  "__" 
db     "/ o\"      
db    "|   <"      
db     "\__/",0

xaddress dd ?
yaddress dd ?
 
gameover1 db " ****      *     *       * *****     ****** *         * ***** ******",0ah                   
gameover2 db " *        * *    * *   * * *         *    *  *       *  *     *    *  ",0ah 
gameover3 db " *  **   *   *   *  * *  * *         *    *   *     *   ***** ******       ",0ah 
gameover4 db " *   *  *     *  *   *   * *****     *    *    *   *    *     *     *      ",0ah
gameover5 db " *   * ********* *       * *         *    *     * *     *     *      *  ",0ah
gameover6 db "  ***  *       * *       * *****     ******      *      ***** *       *    ",0 

lives db 3
livestr db "Lives: ",0

tempx dd ?
tempy dd ?

wallx byte 800 dup(?)
wally byte 800 dup(?)

xCoinPos BYTE 2400 dup(?)
yCoinPos BYTE 2400 dup(?)

inputChar2 db ?

prompt db "Enter your name: "

names db 10 dup(?)

inputChar BYTE ?
;INCLUDELIB  winmm.lib
;beginSound BYTE ".\sounds\pacman_beginning.wav",0
;PlaySoundA Proto,
;pszSound:PTR BYTE,
;hmod:DWORD, 
;fdwSound:DWORD,
;SND_ASY   equ 00000001h
;SND_NOWAIT  equ 00002000h


.code
main PROC
;Invoke PlaySoundA,ADDR beginSound,NULL,SND_ASY or SND_NOWAIT
;mwrite offset gameover1
    call pacprint
    call crlf
    mwriteString offset prompt
    mov edx,offset names
    mov ecx,10
    call readString
    call clrscr
    call MenuDisplay ; MenuDisplay
    call Readint
    call Clrscr
    cmp eax,3
    je exitgame
    cmp eax,1
    je l1
    jmp inst
l1:
call level1
cmp lives,0
je ok3
call level2
cmp lives,0
je ok3
call level3
cmp lives,0
jne exitGam 
ok3:
mov edx,offset gameover1
call WriteString
exit
exitGam:
exit
inst:
mov edx,OFFSET filename
call OpenInputFile
mov fileHandle,eax
; Check for errors.
cmp eax,INVALID_HANDLE_VALUE ; error opening file?
jne file_ok
; no: skip
mWrite <"Cannot open file",0dh,0ah>
jmp quit
; and quit
file_ok:
; Read the file into a buffer.
mov edx,OFFSET buffer
mov ecx,BUFFER_SIZE
call ReadFromFile
jnc check_buffer_size
; error reading?
mWrite "Error reading file. "
; yes: show error message
call WriteWindowsMsg
jmp close_file
check_buffer_size:
cmp eax,BUFFER_SIZE
; buffer large enough?
jb buf_size_ok
; yes
mWrite <"Error: Buffer too small for the file",0dh,0ah>
jmp quit
; and quit
buf_size_ok:
mov buffer[eax],0
; insert null terminator
mWrite "File size: "
call WriteDec
; display file size
call Crlf
; Display the buffer.
mWrite <"Buffer:",0dh,0ah,0dh,0ah>
mov edx,OFFSET buffer
; display the buffer
call WriteString
call Crlf
close_file:
mov eax,fileHandle
call CloseFile
quit:
exit

exitgame:
exit
main ENDP


DrawPlayer PROC
    ; draw player at (xPos,yPos):
    mov eax,yellow ;(blue*16)
    call SetTextColor
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
    mov al,"X"
    call WriteChar
    ret
DrawPlayer ENDP

;wallDesign

WallDesign Proc

;Wall1
mov dl,20
mov dh,15
mov temp,dl

lea edi,wally
lea esi,wallx
mov [edi],dh
mov ecx,sizeof menu3
dec ecx
;Filling X and y array
X1:
mov [esi],dl
mov [edi],dh
inc esi
inc edi
inc dl
loop X1

;Creating wall
mov dh,15
mov dl,temp
call Gotoxy
mov eax,green(green*16)
call SettextColor
mov edx,offset menu3
call Writestring

mov ecx,5
mov dh,16
mov dl,28
mov temp,dh
l1:
; Code for wally
mov dl,28
mov dh,temp
mov al,temp
mov [edi],al
mov [esi],dl
inc edi
inc esi
;Code of creating wally
call Gotoxy
mov edx,offset ground2
call writestring
inc temp
loop l1

; wall2
mov dl,60
mov dh,15
mov temp,dl

mov [edi],dh
mov ecx,sizeof menu3
dec ecx
;Filling X and y array
X2:
mov [esi],dl
mov [edi],dh
inc esi
inc edi
inc dl
loop X2

;Creating wall
mov dh,15
mov dl,temp
call Gotoxy
mov eax,Green(Green*16)
call SettextColor
mov edx,offset menu3
call Writestring

mov ecx,5
mov dh,16
mov dl,68
mov temp,dh
l2:
; Code for wally
mov dl,68
mov dh,temp
mov al,temp
mov [edi],al
mov [esi],dl
inc edi
inc esi
;Code of creating wally
call Gotoxy
mov edx,offset ground2
call writestring
inc temp
loop l2

;wall3
mov dl,40
mov dh,23
mov temp,dl

mov [edi],dh
mov ecx,sizeof menu3
dec ecx
;Filling X and y array
X3:
mov [esi],dl
mov [edi],dh
inc esi
inc edi
inc dl
loop X3

;Creating wall
mov dh,23
mov dl,temp
call Gotoxy
mov eax,Green(Green*16)
call SettextColor
mov edx,offset menu3
call Writestring

;wall4

mov dl,90
mov dh,18
mov temp,dl

mov [edi],dh
mov ecx,sizeof menu3
dec ecx
;Filling X and y array
X4:
mov [esi],dl
mov [edi],dh
inc esi
inc edi
inc dl
loop X4

;Creating wall
mov dh,18
mov dl,temp
call Gotoxy
mov eax,green(green*16)
call SettextColor
mov edx,offset menu3
call Writestring

;wall5

mov dl,90
mov dh,12
mov temp,dl

mov [edi],dh
mov ecx,sizeof menu3
dec ecx
;Filling X and y array
X5:
mov [esi],dl
mov [edi],dh
inc esi
inc edi
inc dl
loop X5

;Creating wall
mov dh,12
mov dl,temp
call Gotoxy
mov eax,Green(Green*16)
call SettextColor
mov edx,offset menu3
call Writestring

;wall 6

mov dl,90
mov dh,27
mov temp,dl

mov [edi],dh
mov ecx,sizeof menu3
dec ecx
;Filling X and y array
X6:
mov [esi],dl
mov [edi],dh
inc esi
inc edi
inc dl
loop X6

;Creating wall
mov dh,27
mov dl,temp
call Gotoxy
mov eax,green(green*16)
call SettextColor
mov edx,offset menu3
call Writestring

;wall 7

mov dl,4
mov dh,12
mov temp,dl

mov [edi],dh
mov ecx,sizeof menu3
dec ecx
;Filling X and y array
X7:
mov [esi],dl
mov [edi],dh
inc esi
inc edi
inc dl
loop X7

;Creating wall
mov dh,12
mov dl,temp
call Gotoxy
mov eax,green(green*16)
call SettextColor
mov edx,offset menu3
call Writestring

;wall 8

mov dl,4
mov dh,26
mov temp,dl

mov [edi],dh
mov ecx,sizeof menu3
dec ecx
;Filling X and y array
X8:
mov [esi],dl
mov [edi],dh
inc esi
inc edi
inc dl
loop X8

;Creating wall
mov dh,26
mov dl,temp
call Gotoxy
mov eax,green(green*16)
call SettextColor
mov edx,offset menu3
call Writestring

;wall 67

mov dl,4
mov dh,18
mov temp,dl

mov [edi],dh
mov ecx,sizeof menu3
dec ecx
;Filling X and y array
X10:
mov [esi],dl
mov [edi],dh
inc esi
inc edi
inc dl
loop X10

;Creating wall
mov dh,18
mov dl,temp
call Gotoxy
mov eax,green(green*16)
call SettextColor
mov edx,offset menu3
call Writestring

; wall 68

mov ecx,5
mov dh,23
mov dl,68
mov temp,dh
l13:
; Code for wally
mov dl,68
mov dh,temp
mov al,temp
mov [edi],al
mov [esi],dl
inc edi
inc esi
;Code of creating wally
call Gotoxy
mov edx,offset ground2
call writestring
inc temp
loop l13

;wall 69

mov ecx,5
mov dh,23
mov dl,28
mov temp,dh
l12:
; Code for wally
mov dl,28
mov dh,temp
mov al,temp
mov [edi],al
mov [esi],dl
inc edi
inc esi
;Code of creating wally
call Gotoxy
mov edx,offset ground2
call writestring
inc temp
loop l12


mov eax,white+(black*16)
call SettextColor
ret
WallDesign endp

MenuDisplay proc
mov dl,45
mov dh,0
call Gotoxy
mov edx,offset menu1
call writestring
mov dl,45
mov dh,1
call Gotoxy
mov edx,offset menu2
call writestring
mov dl,45
mov dh,2
call Gotoxy
mov edx,offset menu3
call writestring
mov dl,45
mov dh,3
call Gotoxy
mov edx,offset menu4
call writestring
mov dl,45
mov dh,4
call Gotoxy
mov edx,offset menu5
call writestring
mov dl,45
mov dh,5
call Gotoxy
mov edx,offset menu6
call writestring
mov dl,45
mov dh,6
call Gotoxy
mov edx,offset menu7
call writestring
mov dl,45
mov dh,7
call Gotoxy
mov edx,offset menu8
call writestring
ret
MenuDisplay endp

Pacprint proc
    mov edx,OFFSET pac0
    call WriteString
    call crlf
    call SettextColor
    mov edx,OFFSET pac1
    call WriteString
    call crlf
    mov eax,green
    call SettextColor
    mov edx,OFFSET pac2
    call WriteString
    call crlf
    mov eax,red
    call SettextColor
    mov edx,OFFSET pac3
    call WriteString
    call crlf
    mov eax,Yellow
    call SettextColor
    mov edx,OFFSET pac4
    call WriteString
    call crlf
mov eax,1000
call Delay
ret
Pacprint endp

Wallcheck proc
;Compare input
call inputCheck
lea edi,wally
lea esi,wallx
mov ecx,lengthof wally
check:
cmp cx,0
je Done
cmp al,[edi]
je next
inc edi
inc esi
dec ecx
jmp check
next:
cmp bl,[esi]
je no
inc edi
inc esi
loop check
Done:
ret
no:
mov al,-1
ret
Wallcheck endp

inputCheck proc
mov al,inputChar
cmp al,"w"
je up
cmp al,"s"
je down
cmp al,"a"
je left
cmp al,"d"
je right
up:
mov al,yPos
dec al
mov bl,xPos
ret
down:
mov al,yPos
inc al
mov bl,xPos
ret
left:
mov bl,xPos
dec bl
mov al,yPos
ret
right:
mov bl,xPos
inc bl
mov al,yPos
ret
inputCheck endp


CheckAnamoly Proc
push ebp
mov ebp,esp
mov ebx,[ebp+8]
cmp bx,29
jge ok
cmp bx,9
jle ok
cmp bx,0
jle ok
pop ebp
ret 2

ok:
pop ebp
mov ax,1
ret 2
CheckAnamoly endp

CheckAnamolyx Proc
push ebp
mov ebp,esp
mov ebx,[ebp+8]
cmp bx,0
jz ok
cmp bx,119
je ok
pop ebp
ret 2
ok:
pop ebp
mov ax,-1
ret 2
CheckAnamolyx endp



UpdatePlayer PROC
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
    mov al," "
    call WriteChar
    ret
UpdatePlayer ENDP

DrawCoin PROC
    mov eax,red ;(red * 16)
    call SetTextColor
    mov ecx,2400
    lea edi,xCoinPos
    lea esi,yCoinPos
    l1:
    mov al,[esi]
    mov bl,[esi]
    cmp bl,0
    je Done
    cmp al,28
    je ok
    ok1:
    mov dl,[edi]
    mov dh,[esi]
    call Gotoxy
    mov al,"."
    call WriteChar
    inc edi
    inc esi
    loop l1
    jmp Done
    ok:
    mov bl,[esi+1]
    cmp bl,28
    je ok1
    Done:
    ret
DrawCoin ENDP

CreateRandomCoin PROC
    mov eax,55
    inc eax
    call RandomRange
    mov xCoinPos,al
    mov yCoinPos,12
    ret
CreateRandomCoin ENDP

Coins Proc
mov xaddress,offset xCoinPos
mov yaddress,offset yCoinPos
;start of boundary
mov bl,10

start:

mov ecx,lengthof wally
lea edi,wally
lea esi,wallx
l1:
cmp bl,29
je Done
cmp bl,[edi]
je next
inc edi
loop l1

mov cx,118
mov al,1

l2:
mov tempx,esi
mov tempy,edi
mov esi,xaddress
mov edi,yaddress
mov [esi],al
mov [edi],bl
inc xaddress
inc yaddress
mov esi,tempx
mov edi,tempy
inc al
loop l2

inc bl
mov esi,tempx
mov edi,tempy
jmp start

next:
mov ecx,118
mov al,1

first:
cmp cx,0
je Done1
mov temp,cl
mov ecx,lengthof wallx
lea esi,wallx
lea edi,wally
l3:
cmp ecx,0
je go
mov dl,[esi]
cmp al,[esi]
je ok
inc esi
inc edi
loop l3
jmp go
;inc al
;jmp ok2
ok:
cmp [edi],bl
je stop
dec ecx
inc esi
inc edi
jmp l3
go:
cmp al,119
jge Done1
mov edi,yaddress
mov esi,xaddress
mov [esi],al
mov [edi],bl
inc xaddress
inc yaddress
inc al
mov cl,temp
dec cl
jmp first
stop:
inc al
inc esi
inc edi
dec cx
jmp l3
;mov cl,temp
;loop first
Done1:
inc bl
jmp start
Done:
ret

Coins endp

Updateghost PROC
    mov eax,red ;(blue*16)
    call SetTextColor
    mov ecx,2400
    lea edi,xCoinPos
    lea esi,yCoinPos
    mov al,-1
    mov bl,byte ptr xGhost1
l1:
cmp ecx,0
je ok2
cmp [edi],bl
je ok
inc edi
inc esi
loop l1
jmp l2
ok2:
    mov dl,byte ptr xGhost1
    mov dh,byte ptr yGhost1
    call Gotoxy
    mov al,"."
    call WriteChar
    ret
ok:
     mov bl,byte ptr yGhost1
     cmp [esi],bl
     je ok2
     inc esi
     inc edi
     dec ecx
     mov bl,byte ptr xGhost1
     jmp l1
    dec esi
    dec edi
l2:  
                       ;mov al,-1
                       ;cmp [edi],al
                       ;jne ok2
    mov dl,byte ptr xGhost1
    mov dh,byte ptr yGhost1
    call Gotoxy
    mov al," "
    call WriteChar
    ret
Updateghost ENDP

Drawghost PROC
    ; draw player at (xPos,yPos):
    mov eax,blue ;(blue*16)
    call SetTextColor
    push ebp
    mov ebp,esp
    mov dl,[ebp+10]
    mov dh,[ebp+8]
    call Gotoxy
    mov al,"G"
    call WriteChar
    pop ebp
    ret 4
Drawghost ENDP


ghostMovement proc
mov al,byte ptr XGhost1
cmp al,118
je ok1
cmp al,1
je ok2
jmp move
ok2:
mov checkGhost,0
jmp move
ok1:
mov checkGhost,1
move:
mov al, checkGhost
cmp al,0
je ok
dec xGhost1
ret
ok:
inc xGhost1
ret

ghostMovement endp

loselive proc
mov al,byte ptr xGhost1
mov bl,byte ptr yGhost1
lea edi,offset xPos
lea esi,offset yPos

cmp [edi],al
je next
ret
next:
cmp [esi],bl
je lose
ret
lose:
dec lives
ret
loselive endp

Boundary Proc
mov eax,blue+(blue*16)
    ; Boundaries design
    call SetTextColor
    mov dl,0
    mov dh,29
    call Gotoxy

    mov edx,OFFSET ground
    call WriteString
    mov dl,0
    mov dh,9
    call Gotoxy
    mov edx,OFFSET ground
    call WriteString

    mov ecx,19
    mov dh,10
    mov temp,dh
    l1:
    mov dh,temp
    mov dl,0
    call Gotoxy
    mov edx,OFFSET ground1
    call WriteString
    inc temp
    loop l1


    mov ecx,19
    mov dh,10
    mov temp,dh
    l2:
    mov dh,temp
    mov dl,119
    call Gotoxy
    mov edx,OFFSET ground2
    call WriteString
    inc temp
    loop l2
    ret
Boundary endp

level1 proc
; Calling Functions
    mov xPos,20
    mov yPos,20
    mov xGhost1,1
    mov yGhost1,10
    mov eax,blue ;(black * 16)  
    mov eax,White+(black*16)
    call settextColor 
    call Clrscr
    call pacprint
    mov dl,55
    mov dh,8
    call Gotoxy
    mov edx,offset prompt2
    call WriteString
    mWrite "1" 
    call Boundary
    call WallDesign
    call Coins
    call DrawCoin
    call DrawPlayer
    push xGhost1
    push yGhost1
    call Drawghost
    call Game
ret
level1 endp


level2 proc
    ;mov lives,3
    ;mov score,0
    mov levelno,2
    mov xPos,50
    mov yPos,15
    mov xGhost1,2
    mov yGhost1,11
    mov eax,blue ;(black * 16)  
    mov eax,White+(black*16)
    call settextColor 
    call Clrscr
    call pacprint
    mov dl,55
    mov dh,8
    call Gotoxy
    mov edx,offset prompt2
    call WriteString
    mWrite "2" 
    call Boundary
    call WallDesign2
    call Coins
    call DrawCoin
    call DrawPlayer
    push xGhost1
    push yGhost1
    call Drawghost
    call Game
    ret
level2 endp

level3 proc
    ;mov lives,3
    ;mov score,0
    mov levelno,3
    mov xPos,50
    mov yPos,15
    mov xGhost1,2
    mov yGhost1,11
    mov eax,blue ;(black * 16)  
    mov eax,White+(black*16)
    call settextColor 
    call Clrscr
    call pacprint
    mov dl,55
    mov dh,8
    call Gotoxy
    mov edx,offset prompt2
    call WriteString
    mWrite "3" 

    call Boundary2
    call WallDesign3
    call Coins
    call DrawCoin
    call DrawPlayer
    push xGhost1
    push yGhost1
    call Drawghost
    call Game
    ret
level3 endp

Boundary2 Proc
mov eax,blue;(blue*16)
    ; Boundaries design
    call SetTextColor
    mov dl,0
    mov dh,29
    call Gotoxy

    mov edx,OFFSET ground
    call WriteString
    mov dl,0
    mov dh,9
    call Gotoxy
    mov edx,OFFSET ground
    call WriteString

    mov ecx,19
    mov dh,10
    mov temp,dh
    l1:
    mov al,temp
    cmp al,17
    je ok
    cmp al,18
    je ok
    cmp al,19
    je ok
    mov dh,temp
    mov dl,0
    call Gotoxy
    mov edx,OFFSET ground1
    call WriteString
    inc temp
    loop l1
    jmp moveon
    ok:
    inc temp
    dec ecx
    jmp l1
moveon:

    mov ecx,19
    mov dh,10
    mov temp,dh
    l2:
    mov al,temp
    cmp al,17
    je ok1
    cmp al,18
    je ok1
    cmp al,19
    je ok1
    mov dh,temp
    mov dl,119
    call Gotoxy
    mov edx,OFFSET ground1
    call WriteString
    inc temp
    loop l2
    jmp moveon1
    ok1:
    inc temp
    dec ecx
    jmp l2
moveon1:

ret
Boundary2 endp



WallDesign2 proc
call Emptyarray
mov eax,brown
Call SetTextColor
;wall1
mov ecx,118
lea edi,wallx
lea esi,wally
mov al,1
mov bl,10
;storing in array
l1:
mov [edi],al
mov [esi],bl
inc al
inc esi
inc edi
loop l1
;creating wall
mov temp,1
mov ecx,118
l2:
mov dl,temp
mov dh,10
call Gotoxy
mwritestring offset dwall
inc temp
loop l2

;wall2
mov ecx,118
mov al,1
mov bl,28
;storing in array
l3:
mov [edi],al
mov [esi],bl
inc al
inc esi
inc edi
loop l3
;Writing wall
mov temp,1
mov ecx,118
l4:
mov dl,temp
mov dh,28
call Gotoxy
mwritestring offset dwall
inc temp
loop l4

;wall 3
mov ecx,19
mov al,10
mov bl,1
;storing in array
l5:
mov [edi],bl
mov [esi],al
inc al
inc esi
inc edi
loop l5
;creating wall
mov temp,10
mov ecx,19
l6:
mov dl,1
mov dh,temp
call Gotoxy
mwritestring offset dwall
inc temp
loop l6
;wall4
mov ecx,19
mov al,10
mov bl,118
;storing in array
l7:
mov [edi],bl
mov [esi],al
inc al
inc esi
inc edi
loop l7
;creating wall
mov temp,10
mov ecx,19
l8:
mov dl,118
mov dh,temp
call Gotoxy
mwritestring offset dwall
inc temp
loop l8

mov eax,green(green*16)
Call SetTextColor
;wall5
mov al,20
mov bl,18
mov ecx,20
l9:
cmp al,28
je ok
cmp al,29
je ok
cmp al,30
je ok
mov [edi],al
mov [esi],bl
inc al
inc edi
inc esi
Loop l9
ok:
inc al
dec ecx
cmp ecx,0
jg l9
;writing wall
mov al,20
mov bl,18
mov ecx,20
l10:
cmp al,28
je ok1
cmp al,29
je ok1
cmp al,30
je ok1
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc al
Loop l10
ok1:
inc al
dec ecx
cmp ecx,0
jg l10
;wall 6
mov al,70
mov bl,18
mov ecx,20
l11:
cmp al,78
je ok2
cmp al,79
je ok2
cmp al,80
je ok2
mov [edi],al
mov [esi],bl
inc al
inc edi
inc esi
Loop l11
ok2:
inc al
dec ecx
cmp ecx,0
jg l11
;writing wall
mov al,70
mov bl,18
mov ecx,20
l12:
cmp al,78
je ok3
cmp al,79
je ok3
cmp al,80
je ok3
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc al
Loop l12
ok3:
inc al
dec ecx
cmp ecx,0
jg l12

;wall7

mov al,70
mov bl,19
mov ecx,4
l13:
mov [edi],al
mov [esi],bl
inc bl
inc edi
inc esi
Loop l13
;Writing Wall
mov al,70
mov bl,19
mov ecx,4
l14:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc bl
Loop l14

;wall8
mov al,20
mov bl,19
mov ecx,4
l15:
mov [edi],al
mov [esi],bl
inc bl
inc edi
inc esi
Loop l15
;Writing Wall
mov al,20
mov bl,19
mov ecx,4
l16:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc bl
Loop l16

;wall9
mov al,70
mov bl,23
mov ecx,20
l17:
mov [edi],al
mov [esi],bl
inc al
inc edi
inc esi
Loop l17

;writing wall
mov al,70
mov bl,23
mov ecx,20
l18:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc al
Loop l18

;wall 10
mov al,20
mov bl,23
mov ecx,20
l19:
mov [edi],al
mov [esi],bl
inc al
inc edi
inc esi
Loop l19

;writing wall
mov al,20
mov bl,23
mov ecx,20
l20:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc al
Loop l20

;wall 11
mov al,39
mov bl,19
mov ecx,4
l21:
mov [edi],al
mov [esi],bl
inc bl
inc edi
inc esi
Loop l21
;Writing Wall
mov al,39
mov bl,19
mov ecx,4
l22:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc bl
Loop l22

;wall12
mov al,89
mov bl,19
mov ecx,4
l23:
mov [edi],al
mov [esi],bl
inc bl
inc edi
inc esi
Loop l23
;Writing Wall
mov al,89
mov bl,19
mov ecx,4
l24:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc bl
Loop l24

;wall13
mov ecx,116
mov al,2
mov bl,13
;storing in array
l25:
cmp al,54
je leav
cmp al,55
je leav
cmp al,56
je leav
mov [edi],al
mov [esi],bl
inc al
inc esi
inc edi
loop l25
jmp forward
leav:
inc al
dec ecx 
jmp l25
forward:
;creating wall
mov temp,2
mov ecx,116
l26:
mov al,temp
cmp al,54
je leav1
cmp al,55
je leav1
cmp al,56
je leav1
mov dl,temp
mov dh,13
call Gotoxy
mwritestring offset dwall
inc temp
loop l26
jmp forward2
leav1:
inc temp
dec ecx 
jmp l26
forward2:

;wall14

mov ecx,12
mov al,15
mov bl,4
;storing in array
l27:
mov [edi],bl
mov [esi],al
inc al
inc esi
inc edi
loop l27
;creating wall
mov temp,15
mov ecx,12
l28:
mov dl,4
mov dh,temp
call Gotoxy
mwritestring offset dwall
inc temp
loop l28

;wall 15
mov ecx,12
mov al,15
mov bl,115
;storing in array
l29:
mov [edi],bl
mov [esi],al
inc al
inc esi
inc edi
loop l29
;creating wall
mov temp,15
mov ecx,12
l30:
mov dl,115
mov dh,temp
call Gotoxy
mwritestring offset dwall
inc temp
loop l30


ret
WallDesign2 endp

WallDesign3 proc
call Emptyarray
mov eax,brown
Call SetTextColor
lea edi,wallx
lea esi,wally


mov eax,green(green*16)
Call SetTextColor
;wall5
mov al,20
mov bl,18
mov ecx,20
l9:
cmp al,28
je ok
cmp al,29
je ok
cmp al,30
je ok
mov [edi],al
mov [esi],bl
inc al
inc edi
inc esi
Loop l9
ok:
inc al
dec ecx
cmp ecx,0
jg l9
;writing wall
mov al,20
mov bl,18
mov ecx,20
l10:
cmp al,28
je ok1
cmp al,29
je ok1
cmp al,30
je ok1
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc al
Loop l10
ok1:
inc al
dec ecx
cmp ecx,0
jg l10
;wall 6
mov al,70
mov bl,18
mov ecx,20
l11:
cmp al,78
je ok2
cmp al,79
je ok2
cmp al,80
je ok2
mov [edi],al
mov [esi],bl
inc al
inc edi
inc esi
Loop l11
ok2:
inc al
dec ecx
cmp ecx,0
jg l11
;writing wall
mov al,70
mov bl,18
mov ecx,20
l12:
cmp al,78
je ok3
cmp al,79
je ok3
cmp al,80
je ok3
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc al
Loop l12
ok3:
inc al
dec ecx
cmp ecx,0
jg l12

;wall7

mov al,70
mov bl,19
mov ecx,4
l13:
mov [edi],al
mov [esi],bl
inc bl
inc edi
inc esi
Loop l13
;Writing Wall
mov al,70
mov bl,19
mov ecx,4
l14:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc bl
Loop l14

;wall8
mov al,20
mov bl,19
mov ecx,4
l15:
mov [edi],al
mov [esi],bl
inc bl
inc edi
inc esi
Loop l15
;Writing Wall
mov al,20
mov bl,19
mov ecx,4
l16:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc bl
Loop l16

;wall9
mov al,70
mov bl,23
mov ecx,20
l17:
mov [edi],al
mov [esi],bl
inc al
inc edi
inc esi
Loop l17

;writing wall
mov al,70
mov bl,23
mov ecx,20
l18:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc al
Loop l18

;wall 10
mov al,20
mov bl,23
mov ecx,20
l19:
mov [edi],al
mov [esi],bl
inc al
inc edi
inc esi
Loop l19

;writing wall
mov al,20
mov bl,23
mov ecx,20
l20:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc al
Loop l20

;wall 11
mov al,39
mov bl,19
mov ecx,4
l21:
mov [edi],al
mov [esi],bl
inc bl
inc edi
inc esi
Loop l21
;Writing Wall
mov al,39
mov bl,19
mov ecx,4
l22:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc bl
Loop l22

;wall12
mov al,89
mov bl,19
mov ecx,4
l23:
mov [edi],al
mov [esi],bl
inc bl
inc edi
inc esi
Loop l23
;Writing Wall
mov al,89
mov bl,19
mov ecx,4
l24:
mov dl,al
mov dh,bl
Call Gotoxy
mWriteString offset dwall
inc bl
Loop l24

;wall13
mov ecx,116
mov al,2
mov bl,13
;storing in array
l25:
cmp al,54
je leav
cmp al,55
je leav
cmp al,56
je leav
mov [edi],al
mov [esi],bl
inc al
inc esi
inc edi
loop l25
jmp forward
leav:
inc al
dec ecx 
jmp l25
forward:
;creating wall
mov temp,2
mov ecx,116
l26:
mov al,temp
cmp al,54
je leav1
cmp al,55
je leav1
cmp al,56
je leav1
mov dl,temp
mov dh,13
call Gotoxy
mwritestring offset dwall
inc temp
loop l26
jmp forward2
leav1:
inc temp
dec ecx 
jmp l26
forward2:

;wall14

mov ecx,12
mov al,15
mov bl,4
;storing in array
l27:
mov [edi],bl
mov [esi],al
inc al
inc esi
inc edi
loop l27
;creating wall
mov temp,15
mov ecx,12
l28:
mov dl,4
mov dh,temp
call Gotoxy
mwritestring offset dwall
inc temp
loop l28

;wall 15
mov ecx,12
mov al,15
mov bl,115
;storing in array
l29:
mov [edi],bl
mov [esi],al
inc al
inc esi
inc edi
loop l29
;creating wall
mov temp,15
mov ecx,12
l30:
mov dl,115
mov dh,temp
call Gotoxy
mwritestring offset dwall
inc temp
loop l30


ret
WallDesign3 endp


Emptyarray proc
lea edi,wallx
lea esi,wally
mov ecx,500
mov al,0
l1:
mov [esi],al
mov [edi],al
inc esi 
inc edi
loop l1
lea edi,xCoinPos
lea esi,yCoinPos
mov ecx,2400
l2:
mov [esi],al
mov [edi],al
inc esi
inc edi
loop l2
ret
Emptyarray endp

Game Proc
gameLoop:
            call loselive
            call UpdateGhost
            call GhostMovement
            call loselive
            push xGhost1
            push yGhost1
            call Drawghost
               
            mgotoxy 108,7
            mWritestring offset livestr
            mov eax,0
            mov al,lives
            call Writedec
            mov al,lives
            cmp al,0
            jne yes
            jmp exitGame

yes:
        lea edi,xCoinPos
        lea esi,yCoinPos
        mov bl,xPos
        mov ecx,lengthof xCoinPos
        checkl:
        cmp ecx,0
        je notCollecting
        mov al,[edi]
        ;cmp al,0
        ;je notCollecting
        cmp bl,al
        je ch0
        inc edi
        inc esi
        loop checkl
        jmp notCollecting
        ch0:
        mov bl,yPos
        mov al,[esi]
        cmp bl,al
        je ch1
        inc esi 
        inc edi
        dec ecx
        mov bl,xPos
        jmp checkl
        ch1:
        mov al,-1
        mov [edi],al
        mov [esi],al
        ; player is intersecting coin:
        inc score
       ; call CreateRandomCoin
        ;call DrawCoin
        notCollecting:

        mov eax,white (black * 16)
        call SetTextColor

        ; draw score:
        mov dl,0
        mov dh,7
        call Gotoxy
        mov edx,OFFSET strScore
        call WriteString
        mov eax,score
        call WriteDec 
        mov al,0
        call Nextlevel
        cmp al,-1
        je exitGame
        ; get user key input:
        mov al,inputChar
        mov inputChar2,al
        mov eax,100
        call delay
        call Readkey
        jz moveon
        mov inputChar,al
        moveon:
        ; exit game if user types 'x':
        cmp inputChar,"x"
        je exitGame

        cmp inputChar,"w"
        je moveUp

        cmp inputChar,"s"
        je moveDown

        cmp inputChar,"a"
        je moveLeft

        cmp inputChar,"d"
        je moveRight

        cmp inputChar,"p"
        je paus


        moveUp:
            mov ax,0
            mov al,ypos
            dec al
            push ax
            call CheckAnamoly
            cmp ax,1
            je gameLoop
            call Wallcheck
            cmp al,-1
            je gameLoop
            call UpdatePlayer
            dec yPos
            call DrawPlayer
        jmp gameLoop

        moveDown:
        mov ax,0
        mov al,ypos
        inc al
        push ax
        call CheckAnamoly
        cmp ax,1
        je gameLoop
        call Wallcheck
        cmp al,-1
        je gameLoop
        call UpdatePlayer
        inc yPos
        call DrawPlayer
        jmp gameLoop

        moveLeft:
        cmp levelno,3
        jne total
        Call Validate
        cmp al,-1
        je moveon1
        total:
        mov ax,0
        mov bx,0
        mov al,xpos
        mov bl,ypos
        dec al
        cmp levelno,3
        jne total1
        
        push ax
        push bx
        call Checkanmly3
        cmp al,-1
        je moveon1
        total1:
        push ax
        call CheckAnamolyx
        cmp ax,-1
        je gameLoop
        call Wallcheck
        cmp al,-1
        je gameLoop
        moveon1:
        call UpdatePlayer
        dec xPos
        call DrawPlayer
        jmp gameLoop

        moveRight:
        cmp levelno,3
        jne total2
        Call Validate
        cmp al,-1
        je moveon2
        total2:
        mov bx,0
        mov ax,0
        mov al,xpos
        mov bl,yPos
        inc al
        cmp levelno,3
        jne total3
        push ax
        push bx
        call Checkanmly3
        cmp al,-1
        je moveon2
        
        total3:
        push ax
        call CheckAnamolyx
        cmp ax,-1
        je gameLoop
        call Wallcheck
        cmp al,-1
        je gameLoop
        moveon2:
        call UpdatePlayer
        inc xPos
        call DrawPlayer
        jmp gameLoop
   
        paus:   
        dec inputChar
        mov bl,'p'
        saif:
        cmp inputChar,bl
        je acha
        Call readChar
        mov inputChar,al 
        jmp saif
        acha:
        mov al,inputChar2
        mov inputChar,al
        jmp gameLoop

    jmp gameLoop

    exitGame:
        call clrscr
ret
Game endp

Checkanmly3 proc
push ebp
mov ebp,esp
mov ax,[ebp+10]
mov bx,[ebp+8]
cmp ax,0
je ok
cmp ax,119
je ok
pop ebp
ret 4
ok:
cmp bx,17
je ok2
cmp bx,18
je ok2
cmp bx,19
je ok2
pop ebp
ret 4
ok2:
mov al,-1
pop ebp
ret 4
Checkanmly3 endp

Validate proc
mov al,xPos
mov bl,yPos
cmp al,0
je ok
cmp al,119
je ok
ret
ok:
cmp bl,17
je ok1
cmp bl,18
je ok1
cmp bl,19
je ok1
ret
ok1:
cmp al,0
je down
Call updatePlayer
mov xPos,1
mov al,-1
ret

down:
Call updatePlayer
mov xPos,118
mov al,-1
ret
Validate endp

NextLevel Proc
cmp levelno,1
je ok
cmp levelno,2
je ok2
cmp levelno,3
je ok3
ok:
cmp score,500
jne backh
mov al,-1
ret
ok2:
cmp score,600
jne backh
mov al,-1
ret
ok3:
cmp score,900
jne backh
mov al,-1
ret

backh:
ret
NextLevel endp


END main
