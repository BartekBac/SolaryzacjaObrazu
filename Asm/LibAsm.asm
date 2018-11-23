.code

MyProc1 proc x: QWORD, y: QWORD

	xor rax,rax
	mov rax, x
	add rax, y
	ret

MyProc1 endp

MyProc2 proc
	mov rax, 99
	ret
MyProc2 endp

getPointer proc ; solaryzuje 8-bajtÛw w jednym cyklu
	xor r10, r10
	mov r10, rcx ; za≥aduj min_ponter
	mov rax, rdx ; jaki rozmiar
	;add rax, 08h
	mov r11, 000000000FFFFFFFFh
	and rax, r11  ; fixed rozmiar
	add r10, rax ; dodaj rozmiar -> mamy max_pointer
	mov rsi, rcx ; wskaünik na dane do rsi
loop1:
	;mov rcx, r10 ; max_pointer do rcx
	;sub rcx, rsi ; odejmij aktualny pointer
	; jrcxz end_loop1 ; jeúli 0 -> koniec
	cmp rsi, r10
	jnl end_loop1
	mov rbx, 0D0D0D0D0D0D0D0D0h ; limit (na razie rÍczny)
	vmovq xmm7, rbx	; limit do rejstru xmm7
	mov rbx, 0FFFFFFFFFFFFFFFFh
	mov r12, 08080808080808080h ; sta≥a do konwersji singed_int na unsigned_int
	vmovq xmm6, rbx	; jedynki do rejestru xmm6
	vmovq xmm5, r12 
	movups xmm0, [rsi] ; dane z pamiÍci do rejestru xmm0
	movq xmm1, xmm0 ; kopia danych - negacje
	movq xmm2, xmm0 ; kopia danych
	vpxor xmm1, xmm1, xmm6 ; wszytskie bajty: 255-val do xmm1
	vpxor xmm2, xmm2, xmm5 ; konwersja danych na unsigned_int
	vpxor xmm7, xmm7, xmm5 ; konwrsja progu na unsigned_int
	pcmpgtb xmm2, xmm7 ; ktÛrych negaci potrzebujemy do xmm2
					; wstawia FF tam gdzie BYTE z xmm2 jest wiÍkszy od BYTE na xmm7, inaczej wstawia 00
	vpand xmm3, xmm1, xmm2 ; negacje docelowe do xmm3
	vpxor xmm4, xmm2, xmm6 ; ktÛrych niezmienionych danych potrzebujemy do xmm4
	vpand xmm5, xmm0, xmm4 ; niezmienione dane docelowe do xmm5
	vpor xmm1, xmm3, xmm5 ; wynik do xmm1
	vmovq rax, xmm1 ; wynik do rax
	mov [rsi], rax ; zapisz wynik do pamiÍci
	add rsi, 08h ; poniter += 8 -> przesuniÍcie o 8 bajtÛw w pamiÍci
	jmp loop1
end_loop1:
	ret
getPointer endp


; PRZEZNACZENIA REJESTR”W:
  ; R8, XMM7 - prÛg
  ; R10 - wskaünik na koniec danych
  ; RSI - wskaünik na aktualne dane (8 bajtÛw)
  ; XMM5 - sta≥a konwersji bajtÛw singed_int na unsigned_int
  ; XMM6 - maska jedynek na wszystkich 32-bitach (na potrzeby operacji logicznych)

solarizeASM proc ; solaryzuje 8-bajtÛw w jednym cyklu
; USTALENIE ROZMIARU P TLI
	xor r10, r10 
	add rdx, rcx ; dodajemy do wskaüniak na poczπtek danych rozmiar
	sub rdx, 08h ; DO WYWALENIA jak naprawimy przekazywanie rozmiaru
	mov r10, rdx ; wskaünik na koniec danych do R10
; USTAWIENIE PROGU NA 8 BAJTACH
	mov rax, 00101010101010101h
	mul r8 ; prÛg w R8
	mov r8, rax ; powielony na wszytskie bajty
	vmovq xmm7, r8 ; prÛg do xmm7
; KONWERSJA singed_int na unsigned_int (na potrzeby rozkazu pcmpgtb)
	mov rax, 08080808080808080h ; sta≥a do konwersji 
	vmovq xmm5, rax  ;sta≥a do rejestru xmm, bo dane teø trzeba bÍdzie konwertowaÊ
	vpxor xmm7, xmm7, xmm5 ; konwrsja progu na unsigned_int
; USTAWIENIE MASKI JEDYNEK
	mov rax, 0FFFFFFFFFFFFFFFFh	
	vmovq xmm6, rax	; jedynki do rejestru xmm6
; WSKAèNIK NA DANE DO RSI	
	mov rsi, rcx
loop1:
; SPRAWDZENIE KO—CA P TLI
	cmp rsi, r10 ; porÛwnaj aktualny wskaünik z ostatnim
	jnl end_loop1 ; jesli (RSI >= R10) skacz
; PRZYGOTOWANIE DANYCH
	movups xmm0, [rsi] ; dane z pamiÍci do rejestru xmm0
	movq xmm1, xmm0 ; kopia danych - negacje
	movq xmm2, xmm0 ; kopia danych - do porÛwnania
; ALGORYTM
 ; MODYFIKACJA DANYCH 
	vpxor xmm1, xmm1, xmm6 ; wszytskie bajty: 255-val do xmm1
	vpxor xmm2, xmm2, xmm5 ; konwersja danych na unsigned_int (w celu porÛwnania z progiem)
 ; USTALENIE KT”RE DANE ODWRACAMY 
	pcmpgtb xmm2, xmm7 ; ktÛrych negacji potrzebujemy do xmm2
					; wstawia FF tam gdzie BYTE z xmm2 jest wiÍkszy od BYTE na xmm7, inaczej wstawia 00
	vpand xmm3, xmm1, xmm2 ; negacje docelowe do xmm3
 ; USTALENIE KT”RE DANE POZOSTAWIAMY BEZ ZMIAN
	vpxor xmm4, xmm2, xmm6 ; ktÛrych niezmienionych danych potrzebujemy (FF) do xmm4
	vpand xmm4, xmm0, xmm4 ; niezmienione dane docelowe do xmm4
 ; PO£•CZENIE DOCELOWYCH ZMIENIONYCH I NIEZMIENIONYCH DANYCH
	vpor xmm1, xmm3, xmm4 ; wynik do xmm1
; ZAPIS DANYCH DO PAMI CI
	vmovq rax, xmm1 ; wynik do rax
	mov [rsi], rax ; zapisz wynik do pamiÍci
; PRZESUNIECIE WSKAèNIKA
	add rsi, 08h ; wskaünik += 8 -> przesuniÍcie o 8 bajtÛw w pamiÍci
	jmp loop1
end_loop1:
; SPRAWDè CZY ZOSTA£Y 4 BAJTY
	cmp rsi, r10 ;potrzebne?? czy od razu skok
	je end_proc ; jeúli rozmiary rÛwne, zakoÒcz
; ZAMIE— 4 OSTATNIE BAJTY
	mov rax, [rsi]
end_proc:
	ret
solarizeASM endp



end