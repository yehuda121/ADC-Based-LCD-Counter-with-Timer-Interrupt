;Coral Bahofrker - 322262221
;May Nigri - 322678491
;Yehuda Shmulevitz - 313366783

		LIST 	P=PIC16F877
		include	<P16f877.inc>
 __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC & _WRT_ENABLE_ON & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

		org 0x00 
reset:	goto start 
		
		org 0x04 ; psika - place 0x04 in memory
		goto psika

		org 0x10
start:	bcf	STATUS, RP1
		bcf	STATUS, RP0	; bank 0
		
;-----------initialize area-----------

		clrf PORTA ; port A0 - get DC power

		;initialize PORTD + PORTE - connect to the lcd
		clrf PORTD
		clrf PORTE 

		call init ; function to initialize the lcd

		;initialize AtD
		movlw 0x81 ; B'10000001'
		movwf ADCON0 ;Fosc/32, the last 1 means - turn on AtD
		call d_20
	
		; initialize TIMER1
		movlw 0x30 ;00110000 -> 1:8
		movwf T1CON ; clock PS -> 1:8 
		clrf TMR1L 
		clrf TMR1H
		;Td = 200ns*(2^16-0)*PS = 200ns*(2^16)*8 ~= 0.104sec
		
		clrf PIR1 ; clear the flags of Peripherals interrupts
		bsf INTCON,PEIE ;Enable Peripherals interrupts
		bsf INTCON,GIE ;Enable Global Interrupts 
		
		bsf STATUS,RP0 ;bank 1

		; initialize interrupts
		clrf PIE1
		bsf PIE1,TMR1IE ; enable timer1

		; initialize ADCON1
		movlw 0x02
		movwf ADCON1 ; all A analog & all E digital
					 ; forma: 6 lower bit of ADRESL = 0
	
		; initialize TRISA
		movlw 0xff
		movwf TRISA

		; initialize TRISD + TRISE
		clrf TRISD ; port D as output
		clrf TRISE ; port E as output
	
		bcf STATUS,RP0 ; back to bank 0
		
		clrf 0x50 ; counter for timer1

		; initialize for BCD
		clrf 0x62 ; meot
		clrf 0x61 ; asarot
		clrf 0x60 ; yehidot

;-------- main area ----------
		
main:	bsf T1CON, TMR1ON
		
		movlw d'10'
		movwf 0x50 ; counter

		bcf STATUS,C ; clear carry bit
		call print_number_on_screen ; will print at the beginning '000'

loop_timeing:	incf 0x50 ; 0x50 += 1
				decfsz 0x50 ; 0x50 -= 1
				goto loop_timeing

				bcf T1CON,TMR1ON ; if 0x50 = 0, disable timer1
				bsf ADCON1,GO ; start casting/conversation -> GO = 1

conversation:	btfsc ADCON0,GO ; if GO = 0 -> casting/conversation ended
				goto conversation
;----------------------------------------------------
				clrf 0x35
				clrf 0x51 ; if 0x51 = 0 will go to error, if 0x51 = 1 will go to up, if 0x51 = 2 will go down
				bcf STATUS,C ;clear carry
				bcf PIR1,ADIF ; clear AnalogToDigital's flag - cause: casting ended
				movf ADRESH,W ; will keep the casting's value
				movwf 0x35

				; check boundries of up
				movlw d'25'
				subwf 0x35,W
				btfss STATUS,C ; if the result is positive
				goto upOrDown
				movlw d'76'
				subwf 0x35,W
				btfsc STATUS,C ; if the result is negative
				goto check_down
				incf 0x51 ; 0x51 = 1
				goto upOrDown

; check boundries of down
check_down:	bcf STATUS,C
			movlw d'92'
			subwf 0x35,W
			btfss STATUS,C ; if the result is positive
			goto upOrDown
			movlw d'117'
			subwf 0x35,W
			btfss STATUS,C ; if the result is positive
			goto put2
			goto upOrDown

put2: 	movlw 0x02
		movwf 0x51 ; 0x51 = 2	

upOrDown:	btfsc 0x51,1
			goto down ; 0x51 = 10 => 2 -> down
			btfsc 0x51,0
			goto up ; 0x51 = 01 => 1 -> up
			call print_ERR ; 0x51 = 00 => 0 -> ERR
			goto main

up:	call print_up
	call check_if_250
	movlw 0x09
	subwf 0x60,W
	btfsc STATUS,2
	goto asarot ; if 9
	incf 0x60 ; if not 9
	call print_number_on_screen
	goto main

asarot: clrf 0x60
		movlw 0x09
		subwf 0x61,W
		btfsc STATUS,2
		goto meot
		incf 0x61
		call print_number_on_screen
		goto main

meot:	clrf 0x61
		incf 0x62
		call print_number_on_screen
		goto main


down:	call print_down
		call check_if_0
		movlw 0x00
		subwf 0x60,W ; if 0x60 = 0
		btfss STATUS,2 ; if 1 -> sub is 0
		goto dec_yehidot ; if the sub isn't 0
		
		movlw 0x00
		subwf 0x61,W ; if 0x61 = 0
		btfss STATUS,2 ; if 1 -> sub is 0
		goto dec_asarot ; if the sub isn't 0

		movlw 0x00
		subwf 0x62,W ; if 0x62 = 0
		btfss STATUS,2 ; if 1 -> sub is 0
		goto dec_meot ; if the sub isn't 0


dec_yehidot:	decf 0x60
				call print_number_on_screen
				goto main


dec_asarot:		decf 0x61
				movlw 0x09
				movwf 0x60
				call print_number_on_screen
				goto main			


dec_meot:		decf 0x62
				movlw 0x09	
				movwf 0x61
				movlw 0x09	
				movwf 0x60
				call print_number_on_screen
				goto main


check_if_0:	movlw 0x00
			subwf 0x62,W ; if 0
			btfss STATUS,2	
			return

			movlw 0x00
			subwf 0x61,W ; if 0
			btfss STATUS,2	
			return

			movlw 0x00
			subwf 0x60,W ; if 0
			btfss STATUS,2	
			return

			; put 250
			movlw 0x02
			movwf 0x62
			movlw 0x05
			movwf 0x61
			call print_number_on_screen
			return


check_if_250:	movlw 0x02
				subwf 0x62,W ; if 2
				btfss STATUS,2
				return

				movlw 0x05
				subwf 0x61,W ; if 5
				btfss STATUS,2
				return

				; put 000
				movlw 0x00
				movwf 0x61
				movlw 0x00
				movwf 0x62
				call print_number_on_screen
				return

psika:	movwf 0x7A ; store W_reg --> 0x7A
		swapf STATUS, w
		movwf 0x7B ; store STATUS --> 0x7B

		bcf STATUS,RP1
		bcf STATUS,RP0 ; bank 0

		btfsc PIR1, ADIF
		goto ERR

		btfsc PIR1, TMR1IF	;check timer1 flag
		goto Timer1

ERR:	goto ERR

Timer1:	clrf TMR1H ; initialize timer1
		clrf TMR1L
		bcf PIR1,TMR1IF ; timer1's flag = 0 (down)
		decf 0x50
		goto finish_psika

finish_psika:	swapf 0x7B, W
				movwf STATUS ; restore STATUS <-- 0x7B
				swapf 0x7A, f
				swapf 0x7A, W ; restore W_reg <-- 0x7A
				retfie	; go out of the psika

print_ERR:	movlw B'11000000' ; PLACE for the data on the LCD
			movwf 0x20 ; B'11000000'
			call lcdc
			call mdel

			movlw 0x45 ; E CHAR (the data )
			movwf 0x20
			call lcdd
			call mdel
	
			movlw 0x52 ; R CHAR (the data )
			movwf 0x20
			call lcdd
			call mdel

			movlw 0x52 ; R CHAR (the data )
			movwf 0x20
			call lcdd
			call mdel

			movlw 0x20 ; space
			movwf 0x20
			call lcdd
			call mdel
			return

print_up:	movlw B'11000000' ; PLACE for the data on the LCD
			movwf 0x20 ; B'11000000'
			call lcdc
			call mdel

			movlw 0x55 ; U CHAR (the data )
			movwf 0x20
			call lcdd
			call mdel
	
			movlw 0x50 ; P CHAR (the data )
			movwf 0x20
			call lcdd
			call mdel

			movlw 0x20 ; space
			movwf 0x20
			call lcdd
			call mdel

			movlw 0x20 ; space
			movwf 0x20
			call lcdd
			call mdel
			return


print_down:	movlw B'11000000' ; PLACE for the data on the LCD
			movwf 0x20 ; B'11000000'
			call lcdc
			call mdel

			movlw 0x44 ; D CHAR (the data )
			movwf 0x20
			call lcdd
			call mdel
	
			movlw 0x4f ; O CHAR (the data )
			movwf 0x20
			call lcdd
			call mdel

			movlw 0x57 ; w CHAR (the data )
			movwf 0x20
			call lcdd
			call mdel

			movlw 0x4E ; N CHAR (the data )
			movwf 0x20
			call lcdd
			call mdel
			return	

print_number_on_screen:	movlw B'10000000' ; PLACE for the data on the LCD
						movwf 0x20 ; B'10000000'
						call lcdc
						call mdel

						movlw 0x30 ; the char/data of the meot number
						addwf 0x62,W ; adding 0x30 to get the ASCII value of the char
						movwf 0x20
						call lcdd
						call mdel

						movlw 0x30 ; the char/data of the meot number
						addwf 0x61,W ; adding 0x30 to get the ASCII value of the char
						movwf 0x20
						call lcdd
						call mdel

						movlw 0x30 ; the char/data of the meot number
						addwf 0x60,W ; adding 0x30 to get the ASCII value of the char
						movwf 0x20
						call lcdd
						call mdel
						return

;subroutine to write data to LCD
lcdd:	movlw 0x02		; E=0, RS=1
		movwf PORTE
		movf 0x20,w
		movwf PORTD
        movlw 0x03		; E=1, rs=1  
		movwf PORTE
		call sdel
		movlw 0x02		; E=0, rs=1  
		movwf PORTE
		return


;subroutine to write command to LCD
lcdc:	movlw 0x00		; E=0,RS=0 
		movwf PORTE
		movf 0x20,w
		movwf PORTD
		movlw 0x01		; E=1,RS=0
		movwf PORTE
        call sdel
		movlw 0x00		; E=0,RS=0
		movwf PORTE
		return

d_20: 	movlw 0x20
		movwf 0x22

lulaa11:	decfsz 0x22,f
			goto lulaa11
			return

d_4:	movlw 0x06
		movwf 0x22

lulaa12: 	decfsz 0x22,f
			goto lulaa12
			return

del_41:		movlw 0xcd
			movwf 0x23

lulaa6:		movlw 0x20
			movwf 0x22

lulaa7:		decfsz 0x22,1
			goto lulaa7
			decfsz 0x23,1
			goto lulaa6 
			return


del_01:		movlw 0x20
			movwf 0x22

lulaa8:		decfsz 0x22,1
			goto lulaa8
			return


sdel:	movlw 0x19	; movlw = 1 cycle
		movwf 0x23	; movwf	= 1 cycle

lulaa2:	movlw 0xfa
		movwf 0x22

lulaa1:	decfsz 0x22,1	; decfsz= 12 cycle
		goto lulaa1		; goto	= 2 cycles
		decfsz 0x23,1
		goto lulaa2 
		return


mdel:	movlw 0x0a
		movwf 0x24

lulaa5:	movlw 0x19
		movwf 0x23

lulaa4:	movlw 0xfa
		movwf 0x22

lulaa3:	decfsz 0x22,1
		goto lulaa3
		decfsz 0x23,1
		goto lulaa4 
		decfsz 0x24,1
		goto lulaa5
		return	


;subroutine to initialize LCD
init:	movlw 0x30 ;00011110
		movwf 0x20
		call lcdc
		call del_41

		movlw 0x30
		movwf 0x20
		call lcdc
		call del_01

		movlw 0x30
		movwf 0x20
		call lcdc
		call mdel

		movlw 0x01	; display clear
		movwf 0x20
		call lcdc
		call mdel

		movlw 0x06	;3. ID=1,S=0 increment,no  shift 000001 ID S  
		movwf 0x20
		call lcdc
		call mdel

		movlw 0x0c	;4. D=1,C=B=0 set display ,no cursor, no blinking
		movwf 0x20
		call lcdc
		call mdel

		movlw 0x38	; dl=1 ( 8 bits interface,n=2 lines,f=5x8 dots)
		movwf 0x20
		call lcdc
		call mdel
		return	

end	