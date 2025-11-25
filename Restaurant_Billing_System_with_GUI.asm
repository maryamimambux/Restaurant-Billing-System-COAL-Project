
; ============================================================
;   FAST FOOD MANAGEMENT SYSTEM (GUI + Console Hybrid)
;   GUI support using MessageBoxA (Enhanced Popups)
; ============================================================

INCLUDE Irvine32.inc
INCLUDE Macros.inc          ; Needed for mWrite

includelib user32.lib


.DATA

; ---------------- GUI TEXT ----------------
guiWelcomeMsg db 0Dh,0Ah,"=============================",0Dh,0Ah,
               "      WELCOME TO FAST FOOD RESTAURANT!      ",0Dh,0Ah,
               "=============================",0Dh,0Ah,0

titleWelcome db "WELCOME!",0

menuText db 0Dh,0Ah,"============== MENU ==============",0Dh,0Ah,
           "Choose a Menu Option:",13,10,
           "1 - Breakfast",13,10,
           "2 - Lunch",13,10,
           "3 - Dinner",0
titleMenu db "FOOD MENU",0

; (we will use a dynamic popup instead of this static string at the end)
billText db 0Dh,0Ah,"============== BILL ==============",0Dh,0Ah,
         "Your Bill Has Been Generated!",0Dh,0Ah,"===============================",0
titleBill db "YOUR BILL",0

; ---------------- MENU ARRAYS ----------------
BreakfastCosts DWORD 50, 30, 70, 60, 40
LunchCosts     DWORD 250, 400, 20, 100, 80
DinnerCosts    DWORD 450, 30, 100, 300, 90

orderCode DWORD 50 DUP(0)
quantity DWORD 50 DUP(0)
subTotal DWORD 0
totalNoOfOrders DWORD 0
selectedMenu DWORD 0

enterQuantity byte "Enter Quantity: ", 0
addMore byte "Add more(yes-1 / no-0): ", 0
enterChoise byte "Enter your choise: ", 0
NetTotal  dword 0
change dword 0
discount_10 dword 10
discount_5 dword 5
multiply_100 dword 100

; new variables to support detailed popup
origSubTotal dword 0        ; preserve subtotal before discount
discountAmount dword 0      ; computed discount amount
Payment dword 0             ; store payment entered by user

; buffer and format for building the dynamic bill popup
billPopupFmt db "BILL SUMMARY",13,10,
               "-------------------------------",13,10,
               "Subtotal: %lu",13,10,
               "Discount: %lu",13,10,
               "Net Total: %lu",13,10,
               "Payment: %lu",13,10,
               "Change: %lu",13,10, 0

billPopupBuffer db 256 DUP(0)

welcomeMsg db 0Dh,0Ah, "=============================================",0Dh,0Ah,
            "      WELCOME TO FAST FOOD RESTAURANT        ",0Dh,0Ah,
            "=============================================",0Dh,0Ah,0

restaurantInfo db 0Dh,0Ah,
                "    Contact: 0300-1234567        ",0Dh,0Ah,
                "    Location: Karachi             ",0Dh,0Ah,
                "************************************************",0Dh,0Ah,0

.CODE

; ===================================================
;                     MAIN
; ===================================================
main PROC

    ; FIXED HERE → MB_SYSTEMMODAL instead of MB_TOPMOST
    invoke MessageBoxA, 0, OFFSET guiWelcomeMsg, OFFSET titleWelcome, MB_OK+MB_ICONINFORMATION+MB_SYSTEMMODAL

    mov eax, 0Eh
    call SetTextColor

    mov edx, OFFSET welcomeMsg
    call WriteString
    mov edx, OFFSET restaurantInfo
    call WriteString

    mov eax, 0Fh
    call SetTextColor

    invoke MessageBoxA, 0, OFFSET menuText, OFFSET titleMenu, MB_OK+MB_ICONINFORMATION+MB_SYSTEMMODAL

    call DisplayMenu
    call calcTotal
    call CalcDiscount

    ; Build the dynamic bill string into billPopupBuffer
    ; wsprintfA(buffer, format, origSubTotal, discountAmount, NetTotal, Payment, change)
    invoke wsprintfA, OFFSET billPopupBuffer, OFFSET billPopupFmt, origSubTotal, discountAmount, NetTotal, Payment, change

    ; Show final bill popup with detailed values
    invoke MessageBoxA, 0, OFFSET billPopupBuffer, OFFSET titleBill, MB_OK+MB_ICONINFORMATION+MB_SYSTEMMODAL

    exit
main ENDP


; ===================================================
;                   DISPLAY MENU
; ===================================================
DisplayMenu PROC
askMenuChoice:
    call Crlf
    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    mWrite "                      CHOOSE A MENU OPTION                       "
    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    call Crlf
    mWrite "   1 - BREAKFAST"
    call Crlf
    mWrite "   2 - LUNCH"
    call Crlf
    mWrite "   3 - DINNER"
    call Crlf
    call Crlf
    mWrite "Enter Choice (1-3): "
    call ReadDec

    cmp eax, 1
    je breakfast
    cmp eax, 2
    je lunch
    cmp eax, 3
    je dinner

    call Crlf
    mWrite "Invalid Input! Please Try Again."
    call Crlf
    jmp askMenuChoice

breakfast:
    mov selectedMenu, 1
    call Crlf
    mWrite "------------------------- BREAKFAST MENU -------------------------"
    call Crlf
    mWrite "ITEM                   COST (Rs)        CODE"
    call Crlf
    mWrite "1) Paratha             Rs.50              1"
    call Crlf
    mWrite "2) Tea                 Rs.30              2"
    call Crlf
    mWrite "3) Omelette            Rs.70              3"
    call Crlf
    mWrite "4) Pancake             Rs.60              4"
    call Crlf
    mWrite "5) Coffee              Rs.40              5"
    call Crlf
    call Crlf
    jmp Taking_Order

lunch:
    mov selectedMenu, 2
    call Crlf
    mWrite "--------------------------- LUNCH MENU ---------------------------"
    call Crlf
    mWrite "ITEM                   COST (Rs)        CODE"
    call Crlf
    mWrite "1) Biryani             Rs.250             1"
    call Crlf
    mWrite "2) Karahi              Rs.400             2"
    call Crlf
    mWrite "3) Roti                Rs.20              3"
    call Crlf
    mWrite "4) Salad               Rs.100             4"
    call Crlf
    mWrite "5) Soup                Rs.80              5"
    call Crlf
    call Crlf
    jmp Taking_Order

dinner:
    mov selectedMenu, 3
    call Crlf
    mWrite "--------------------------- DINNER MENU ---------------------------"
    call Crlf
    mWrite "ITEM                   COST (Rs)        CODE"
    call Crlf
    mWrite "1) Chicken Handi       Rs.450             1"
    call Crlf
    mWrite "2) Naan (per piece)    Rs.30              2"
    call Crlf
    mWrite "3) Cold Drink          Rs.100             3"
    call Crlf
    mWrite "4) Fish Curry          Rs.300             4"
    call Crlf
    mWrite "5) Ice Cream           Rs.90              5"
    call Crlf
    call Crlf
    jmp Taking_Order

Taking_Order:
    call TakingOrder
    ret
DisplayMenu ENDP


; ===================================================
;                 TAKING ORDER
; ===================================================
TakingOrder PROC
    call Crlf
    call Crlf
    mov esi, 0

continueTakingOrder:
    mWrite "Enter item code (1-5): "
    call ReadDec
    cmp eax, 5
    ja invalidCode
    jmp validCode

invalidCode:
    call Crlf
    mWrite "Invalid Item Code! Please Try Again."
    call Crlf
    jmp continueTakingOrder

validCode:
    inc totalNoOfOrders
    mov orderCode[esi], eax

    mWrite "Enter the desired quantity: "
    call ReadDec
    mov quantity[esi], eax

    add esi, 4

addMoreItems:
    call Crlf
    mWrite "Do you wish to continue ordering? (1=Yes / 0=No): "
    call ReadDec
    cmp eax, 1
    je continueTakingOrder
    cmp eax, 0
    je exit_takingOrder

    call Crlf
    mWrite "Invalid Input! Please Clarify."
    call Crlf
    jmp addMoreItems

exit_takingOrder:
    ret
TakingOrder ENDP


; ===================================================
;                CALCULATE TOTAL
; ===================================================
calcTotal PROC
    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    mWrite "                         DETAILED BILL                             "
    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    mWrite "Item                   Qty       Price (Rs)      Total (Rs)"
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

    ; ----- NAME SELECTION -----
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

nd1: mWrite " (1) Chicken Handi    "    
     jmp afterName
nd2: mWrite " (2) Naan (per piece) "
     jmp afterName
nd3: mWrite " (3) Cold Drink       "
     jmp afterName
nd4: mWrite " (4) Fish Curry       "
     jmp afterName
nd5: mWrite " (5) Ice Cream        "
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

nl1: mWrite " (1) Biryani          "
     jmp afterName
nl2: mWrite " (2) Karahi           "
     jmp afterName
nl3: mWrite " (3) Roti             "
     jmp afterName
nl4: mWrite " (4) Salad            "
     jmp afterName
nl5: mWrite " (5) Soup             "
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

nb1: mWrite " (1) Paratha          "
     jmp afterName
nb2: mWrite " (2) Tea              "
     jmp afterName
nb3: mWrite " (3) Omelette         "
     jmp afterName
nb4: mWrite " (4) Pancake          "
     jmp afterName
nb5: mWrite " (5) Coffee           "

afterName:
    mWrite "    "
    mov eax, quantity[edi]
    call WriteDec
    mWrite "         "

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
    mWrite "         "

    mov eax, quantity[edi]
    imul eax, ebp
    call WriteDec

    add subTotal, eax
    call Crlf

    add esi, 4
    add edi, 4
    dec ecx
    jmp nextItem

printSubTotal:
    call Crlf
    mWrite "---------------------------------------------------------------"
    call Crlf
    mWrite "SUBTOTAL :                                              "
    mov eax, subTotal
    call WriteDec
    call Crlf
    call Crlf
    ret
calcTotal ENDP


; ===================================================
;                CALCULATE DISCOUNT
; ===================================================
CalcDiscount PROC
    ; preserve original subtotal for computing discount amount
    mov eax, subTotal
    mov origSubTotal, eax

    mov eax, subTotal

    cmp eax, 1000
    jge Discount10
    cmp eax, 500
    jge Discount5

    call Crlf
    mWrite "Discount (0%):                                          0"
    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    mov eax, 0
    jmp net_total

Discount10:
    imul discount_10
    idiv multiply_100
    call Crlf
    mWrite "Discount (10%):                                         "
    call WriteDec
    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    jmp net_total

Discount5:
    imul discount_5
    idiv multiply_100
    call Crlf
    mWrite "Discount (5%):                                          "
    call WriteDec
    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    jmp net_total

net_total:
    ; subtract discount (in eax) from subTotal
    sub subTotal, eax

    ; compute discountAmount = origSubTotal - subTotal
    mov eax, origSubTotal
    sub eax, subTotal
    mov discountAmount, eax

    call Crlf
    mWrite "Net Total :                                            "
    mov eax, subTotal
    mov NetTotal, eax
    mov eax, NetTotal
    call WriteDec
    call Crlf
    call Crlf

get_payment:
    mWrite "Enter Payment (Rs):                                    "
    call ReadInt
    ; store payment for the popup
    mov Payment, eax

print_change:
    ; EAX still holds payment; subtract NetTotal to get change
    sub eax, NetTotal
    mov change, eax
    mov eax, change
    call Crlf
    mWrite "Change:                                                "
    call WriteDec
    call Crlf
    mWrite "-----------------------------------------------------------------"
    call Crlf
    mWrite "Thank you! Visit Again."
    call Crlf
    call Crlf
    ret
CalcDiscount ENDP

END main
