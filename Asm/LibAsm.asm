.code

; PRZEZNACZENIA REJESTRÓW:
  ; R8, XMM7 - próg
  ; R9 - wska¿nik na dane wyjœciowe
  ; R10 - wskaŸnik na koniec danych
  ; RSI - wskaŸnik na aktualne dane wejœciowe (8 bajtów)
  ; RDI - wskaŸnik na aktualne dane wyjœciowe (8 bajtów)
  ; XMM5 - sta³a konwersji bajtów singed_int na unsigned_int
  ; XMM6 - maska jedynek na wszystkich 32-bitach (na potrzeby operacji logicznych)

solarizeASM proc ; solaryzuje 8-bajtów w jednym cyklu
; USTALENIE ROZMIARU PÊTLI
	xor r10, r10 
	add rdx, rcx ; dodajemy do wskaŸniak na pocz¹tek danych rozmiar
	;sub rdx, 08h ; DO WYWALENIA jak naprawimy przekazywanie rozmiaru
	mov r10, rdx ; wskaŸnik na koniec danych do R10
; USTAWIENIE PROGU NA 8 BAJTACH
	mov rax, 00101010101010101h
	mul r8 ; próg w R8
	mov r8, rax ; powielony na wszytskie bajty
	vmovq xmm7, r8 ; próg do xmm7
; KONWERSJA singed_int na unsigned_int (na potrzeby rozkazu pcmpgtb)
	mov rax, 08080808080808080h ; sta³a do konwersji 
	vmovq xmm5, rax  ;sta³a do rejestru xmm, bo dane te¿ trzeba bêdzie konwertowaæ
	vpxor xmm7, xmm7, xmm5 ; konwrsja progu na unsigned_int
; USTAWIENIE MASKI JEDYNEK
	mov rax, 0FFFFFFFFFFFFFFFFh	
	vmovq xmm6, rax	; jedynki do rejestru xmm6
; WSKANIK NA DANE WEJŒCIOWE DO RSI	
	mov rsi, rcx
; WSKANIK NA DANE WYJŒCIOWE DO RDI	
	mov rdi, r9
loop1:
; SPRAWDZENIE KOÑCA PÊTLI
	cmp rsi, r10 ; porównaj aktualny wskaŸnik z ostatnim
	jnl end_loop1 ; jesli (RSI >= R10) skacz
; PRZYGOTOWANIE DANYCH
	movups xmm0, [rsi] ; dane z pamiêci do rejestru xmm0
	movq xmm1, xmm0 ; kopia danych - negacje
	movq xmm2, xmm0 ; kopia danych - do porównania
; ALGORYTM
 ; MODYFIKACJA DANYCH 
	vpxor xmm1, xmm1, xmm6 ; wszytskie bajty: 255-val do xmm1
	vpxor xmm2, xmm2, xmm5 ; konwersja danych na unsigned_int (w celu porównania z progiem)
 ; USTALENIE KTÓRE DANE ODWRACAMY 
	pcmpgtb xmm2, xmm7 ; których negacji potrzebujemy do xmm2
					; wstawia FF tam gdzie BYTE z xmm2 jest wiêkszy od BYTE na xmm7, inaczej wstawia 00
	vpand xmm3, xmm1, xmm2 ; negacje docelowe do xmm3
 ; USTALENIE KTÓRE DANE POZOSTAWIAMY BEZ ZMIAN
	vpxor xmm4, xmm2, xmm6 ; których niezmienionych danych potrzebujemy (FF) do xmm4
	vpand xmm4, xmm0, xmm4 ; niezmienione dane docelowe do xmm4
 ; PO£¥CZENIE DOCELOWYCH ZMIENIONYCH I NIEZMIENIONYCH DANYCH
	vpor xmm1, xmm3, xmm4 ; wynik do xmm1
; ZAPIS DANYCH DO PAMIÊCI
	vmovq rax, xmm1 ; wynik do rax
	mov [rdi], rax ; zapisz wynik do pamiêci
; PRZESUNIECIE WSKANIKA
	add rsi, 08h ; wskaŸnik += 8 -> przesuniêcie o 8 bajtów w pamiêci
	add rdi, 08h
	jmp loop1
end_loop1:
	ret
solarizeASM endp


end