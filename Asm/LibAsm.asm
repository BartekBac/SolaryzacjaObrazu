.code

; PRZEZNACZENIA REJESTR�W:
  ; R8, XMM7 - pr�g
  ; R9 - wska�nik na dane wyj�ciowe
  ; R10 - wska�nik na koniec danych
  ; RSI - wska�nik na aktualne dane wej�ciowe (8 bajt�w)
  ; RDI - wska�nik na aktualne dane wyj�ciowe (8 bajt�w)
  ; XMM5 - sta�a konwersji bajt�w singed_int na unsigned_int
  ; XMM6 - maska jedynek na wszystkich 32-bitach (na potrzeby operacji logicznych)

solarizeASM proc ; solaryzuje 8-bajt�w w jednym cyklu
; USTALENIE ROZMIARU P�TLI
	xor r10, r10 
	add rdx, rcx ; dodajemy do wska�niak na pocz�tek danych rozmiar
	;sub rdx, 08h ; DO WYWALENIA jak naprawimy przekazywanie rozmiaru
	mov r10, rdx ; wska�nik na koniec danych do R10
; USTAWIENIE PROGU NA 8 BAJTACH
	mov rax, 00101010101010101h
	mul r8 ; pr�g w R8
	mov r8, rax ; powielony na wszytskie bajty
	vmovq xmm7, r8 ; pr�g do xmm7
; KONWERSJA singed_int na unsigned_int (na potrzeby rozkazu pcmpgtb)
	mov rax, 08080808080808080h ; sta�a do konwersji 
	vmovq xmm5, rax  ;sta�a do rejestru xmm, bo dane te� trzeba b�dzie konwertowa�
	vpxor xmm7, xmm7, xmm5 ; konwrsja progu na unsigned_int
; USTAWIENIE MASKI JEDYNEK
	mov rax, 0FFFFFFFFFFFFFFFFh	
	vmovq xmm6, rax	; jedynki do rejestru xmm6
; WSKA�NIK NA DANE WEJ�CIOWE DO RSI	
	mov rsi, rcx
; WSKA�NIK NA DANE WYJ�CIOWE DO RDI	
	mov rdi, r9
loop1:
; SPRAWDZENIE KO�CA P�TLI
	cmp rsi, r10 ; por�wnaj aktualny wska�nik z ostatnim
	jnl end_loop1 ; jesli (RSI >= R10) skacz
; PRZYGOTOWANIE DANYCH
	movups xmm0, [rsi] ; dane z pami�ci do rejestru xmm0
	movq xmm1, xmm0 ; kopia danych - negacje
	movq xmm2, xmm0 ; kopia danych - do por�wnania
; ALGORYTM
 ; MODYFIKACJA DANYCH 
	vpxor xmm1, xmm1, xmm6 ; wszytskie bajty: 255-val do xmm1
	vpxor xmm2, xmm2, xmm5 ; konwersja danych na unsigned_int (w celu por�wnania z progiem)
 ; USTALENIE KT�RE DANE ODWRACAMY 
	pcmpgtb xmm2, xmm7 ; kt�rych negacji potrzebujemy do xmm2
					; wstawia FF tam gdzie BYTE z xmm2 jest wi�kszy od BYTE na xmm7, inaczej wstawia 00
	vpand xmm3, xmm1, xmm2 ; negacje docelowe do xmm3
 ; USTALENIE KT�RE DANE POZOSTAWIAMY BEZ ZMIAN
	vpxor xmm4, xmm2, xmm6 ; kt�rych niezmienionych danych potrzebujemy (FF) do xmm4
	vpand xmm4, xmm0, xmm4 ; niezmienione dane docelowe do xmm4
 ; PO��CZENIE DOCELOWYCH ZMIENIONYCH I NIEZMIENIONYCH DANYCH
	vpor xmm1, xmm3, xmm4 ; wynik do xmm1
; ZAPIS DANYCH DO PAMI�CI
	vmovq rax, xmm1 ; wynik do rax
	mov [rdi], rax ; zapisz wynik do pami�ci
; PRZESUNIECIE WSKA�NIKA
	add rsi, 08h ; wska�nik += 8 -> przesuni�cie o 8 bajt�w w pami�ci
	add rdi, 08h
	jmp loop1
end_loop1:
	ret
solarizeASM endp


end