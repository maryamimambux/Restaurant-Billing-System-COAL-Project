INCLUDE Irvine32.inc
INCLUDE Macros.inc

.DATA

; Menu items arrays 
BreakfastArr DWORD OFFSET Paratha, OFFSET Tea, OFFSET Omelette, OFFSET Pancake, OFFSET Coffee
LunchArr     DWORD OFFSET Biryani, OFFSET Karahi, OFFSET Roti, OFFSET Salad, OFFSET Soup
DinnerArr    DWORD OFFSET ChickenHandi, OFFSET Naan, OFFSET ColdDrink, OFFSET FishCurry, OFFSET IceCream

BreakfastCosts DWORD 50, 30, 70, 60, 40
LunchCosts     DWORD 250, 400, 20, 100, 80
DinnerCosts    DWORD 450, 30, 100, 300, 90

orderCode DWORD 50 DUP(0)
quantity DWORD 50 DUP(0)
subTotal DWORD 0
totalNoOfOrders DWORD 0
selectedMenu DWORD 0

; Item names
Paratha      BYTE "(1) Paratha",0
Tea          BYTE "(2) Tea",0
Omelette     BYTE "(3) Omelette",0
Pancake      BYTE "(4) Pancake",0
Coffee       BYTE "(5) Coffee",0

Biryani      BYTE "(1) Biryani",0
Karahi       BYTE "(2) Karahi",0
Roti         BYTE "(3) Roti",0
Salad        BYTE "(4) Salad",0
Soup         BYTE "(5) Soup",0

ChickenHandi BYTE "(1) Chicken Handi",0
Naan         BYTE "(2) Naan (per piece)",0
ColdDrink    BYTE "(3) Cold Drink",0
FishCurry    BYTE "(4) Fish Curry",0
IceCream     BYTE "(5) Ice Cream",0

; messages
enterQuantity byte "Enter Quantity: ", 0
addMore byte "Add more(yes-1 / no-0): ", 0
enterChoise byte "Enter your choise: ", 0
 

.CODE

;----------------------------------------------------------------------------------------------------------------------------------
;||||||||||||||||||||||||||||||||||||||||||||||||| ==== Main PROCEDURE Start ==== |||||||||||||||||||||||||||||||||||||||||||||||||
;----------------------------------------------------------------------------------------------------------------------------------
 
main PROC

    call DisplayMenu
    call calcTotal
   
    exit
    main endp
    ; ==== Main PROCEDURE End ====

;----------------------------------------------------------------------------------------------------------------------------------
;||||||||||||||||||||||||||||||||||||||||||| ==== DisplayMenu PROCEDURE Start ==== ||||||||||||||||||||||||||||||||||||||||||||||||
;----------------------------------------------------------------------------------------------------------------------------------
 
DisplayMenu Proc

askMenuChoice:

    call crlf
    mWrite "--------------------------- CHOOSE MENU ---------------------------"
    call crlf
    mwrite"                          1 - BREAKFAST"
    call crlf
    mwrite"                          2 - LUNCH"
    call crlf
    mwrite"                          3 - DINNER "    

    call crlf
    mWrite"Enter Choice: "
    call ReadDec

    cmp eax, 1
    je breakfast
    cmp eax, 2
    je lunch
    cmp eax, 3
    je dinner
     
    mWrite "Invalid Input! Please Try Again."  
    call crlf
    jmp askMenuChoice

breakfast:
    mov selectedMenu, 1
    call crlf
    call crlf
    mWrite "------------------------- BREAKFAST MENU -------------------------"
    call crlf
    call crlf
    mWrite "ITEMS                COST                  CODE"
    call crlf 
    

    mWrite "Paratha             Rs.50                   1"
    call crlf
    mWrite "Tea                 Rs.30                   2"
    call crlf
    mWrite "Omelette            Rs.70                   3"
    call crlf
    mWrite "Pancake             Rs.60                   4"
    call crlf
    mWrite "Coffee              Rs.40                   5"

    jmp Taking_Order

lunch:
    mov selectedMenu, 2
    call crlf
    call crlf
    mWrite "--------------------------- LUNCH MENU ---------------------------"
    call crlf
    call crlf
    mWrite "ITEMS                COST                  CODE"
    call crlf 
    call crlf

    mWrite "Biryani             Rs.250                  1"
    call crlf
    mWrite "Karahi              Rs.400                  2"
    call crlf
    mWrite "Roti                Rs.20                   3"
    call crlf
    mWrite "Salad               Rs.100                  4"
    call crlf
    mWrite "Soup                Rs.80                   5"

    jmp Taking_Order

dinner:
    mov selectedMenu, 3
    call crlf
    call crlf
    mWrite "--------------------------- DINNER MENU ---------------------------"
    call crlf
    call crlf
    mWrite "ITEMS                COST                  CODE"
    call crlf 
    call crlf

    mWrite "Chicken Handi       Rs.450                  1"
    call crlf
    mWrite "Naan                Rs.30                   2"
    call crlf
    mWrite "Cold Drink          Rs.100                  3"
    call crlf
    mWrite "Fish Curry          Rs.300                  4"
    call crlf
    mWrite "Ice Cream           Rs.90                   5"

    jmp Taking_Order

    call crlf 
   

    Taking_Order: 
       call TakingOrder
   
   ret
DisplayMenu ENDP

   ; ==== DisplayMenu PROCEDURE End ==== 


;----------------------------------------------------------------------------------------------------------------------------------
;||||||||||||||||||||||||||||||||||||||||||| ==== TakingOrder PROCEDURE Start ==== ||||||||||||||||||||||||||||||||||||||||||||||||
;----------------------------------------------------------------------------------------------------------------------------------
 
TakingOrder Proc

    call crlf
	call crlf

    mov esi, 0

continueTakingOrder:

    mWrite"Enter your choice by typing the corresponding code: "
    call ReadDec
    cmp eax, 5
    ja invalidCode
    jmp validCode

invalidCode:
    mWrite "Invalid Item Code! Please Try Again."
    call crlf
    jmp continueTakingOrder

validCode:
    inc totalNoOfOrders
    mov orderCode[esi], eax

    mWrite"Enter the desired quantity: "
    call ReadDec
    mov quantity[esi], eax

    add esi, 4

addMoreItems:
    call crlf
    mWrite"Do you wish to continue ordering? (1 = Yes, 0 = No): "
    call ReadDec

    cmp eax, 1
    je continueTakingOrder

    cmp eax, 0
    je exit_takingOrder

    mWrite"Invalid Input! Please Clarify."
    call crlf
    jmp addMoreItems


   exit_takingOrder:
   ret

TakingOrder ENDP

    ; ==== TakingOrder PROCEDURE End ==== 


;----------------------------------------------------------------------------------------------------------------------------------
;||||||||||||||||||||||||||||||||||||||||||||| ==== calcTotal PROCEDURE Start ==== ||||||||||||||||||||||||||||||||||||||||||||||||
;----------------------------------------------------------------------------------------------------------------------------------

calcTotal PROC

    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    mWrite "                         DETAILED BILL"
    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    mWrite "Item               Qty     Price     Total"
    call Crlf
    call Crlf

    mov ecx, totalNoOfOrders      
    mov esi, 0                    
    mov edi, 0                    
    mov subTotal, 0

nextItem:
    cmp ecx, 0
    je printSubTotal


    mov eax, orderCode[esi]
    mov ebx, eax                  
    dec eax                      
     
    ; Print Item name depending on selectedMenu 
    mov edx, selectedMenu
    cmp edx, 1
    je nameBreakfast
    cmp edx, 2
    je nameLunch

nameDinner:
    cmp ebx, 1
    je nd1
    cmp ebx, 2
    je nd2
    cmp ebx, 3
    je nd3
    cmp ebx, 4
    je nd4
    cmp ebx, 5
    je nd5
    jmp afterName

nd1: mWrite "(1) Chicken Handi"     
     jmp afterName
nd2: mWrite "(2) Naan (per piece)"
     jmp afterName
nd3: mWrite "(3) Cold Drink"
     jmp afterName
nd4: mWrite "(4) Fish Curry"
     jmp afterName
nd5: mWrite "(5) Ice Cream"
     jmp afterName

nameLunch:
    cmp ebx, 1
    je nl1
    cmp ebx, 2
    je nl2
    cmp ebx, 3
    je nl3
    cmp ebx, 4
    je nl4
    cmp ebx, 5
    je nl5
    jmp afterName

nl1: mWrite "(1) Biryani"
     jmp afterName
nl2: mWrite "(2) Karahi"
     jmp afterName
nl3: mWrite "(3) Roti"
     jmp afterName
nl4: mWrite "(4) Salad"
     jmp afterName
nl5: mWrite "(5) Soup"
     jmp afterName

nameBreakfast:
    cmp ebx, 1
    je nb1
    cmp ebx, 2
    je nb2
    cmp ebx, 3
    je nb3
    cmp ebx, 4
    je nb4
    cmp ebx, 5
    je nb5
    jmp afterName

nb1: mWrite "(1) Paratha"
     jmp afterName
nb2: mWrite "(2) Tea"
     jmp afterName
nb3: mWrite "(3) Omelette"
     jmp afterName
nb4: mWrite "(4) Pancake"
     jmp afterName
nb5: mWrite "(5) Coffee"

afterName:
 
    mWrite "    "

    
    mov eax, quantity[edi]
    call WriteDec

    mWrite "     "
     
    mov edx, selectedMenu
    cmp edx, 1
    je priceBreakfast
    cmp edx, 2
    je priceLunch
   
priceDinner:
    mov eax, orderCode[esi]
    dec eax
    mov ebp, DinnerCosts[eax*4]
    jmp priceGot

priceLunch:
    mov eax, orderCode[esi]
    dec eax
    mov ebp, LunchCosts[eax*4]
    jmp priceGot

priceBreakfast:
    mov eax, orderCode[esi]
    dec eax
    mov ebp, BreakfastCosts[eax*4]
    
priceGot: 
    mov eax, ebp
    call WriteDec

    mWrite "     "
     
    mov eax, quantity[edi]
    imul eax, ebp          ; eax = qty * price
    call WriteDec
     
    add subTotal, eax

    call Crlf
     
    add esi, 4
    add edi, 4
    dec ecx
    jmp nextItem

printSubTotal:
    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    mWrite "SUBTOTAL = "
    mov eax, subTotal
    call WriteDec
    call Crlf
    ret

calcTotal ENDP

    ; ==== calcTotal PROCEDURE End ==== 

END main
