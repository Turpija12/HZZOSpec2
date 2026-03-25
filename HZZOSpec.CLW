!============================================================================
! HZZOSpec.CLW - Implementacija HZZO specifikacije osobnog racuna pomagala
! Bazirana na dokumentu OS_POM_25.docx
!============================================================================
  MEMBER()
  INCLUDE('HZZOSpec.INC')
  MAP
    MODULE('Win32')
      kcr_CreateFile(*CSTRING,LONG,LONG,LONG,LONG,LONG,LONG),LONG,PASCAL,RAW,NAME('CreateFileA')
      kcr_WriteFile(LONG,*STRING,LONG,*LONG,LONG),LONG,PASCAL,RAW,NAME('WriteFile')
      kcr_CloseHandle(LONG),LONG,PASCAL,NAME('CloseHandle')
    END
    WriteLine(LONG,STRING),BOOL,PRIVATE
  END

GENERIC_WRITE       EQUATE(40000000h)
CREATE_ALWAYS       EQUATE(2)
FILE_ATTR_NORMAL    EQUATE(080h)
INVALID_HANDLE      EQUATE(-1)

!============================================================================
! Init - Inicijalizacija klase, alokacija queue-ova
!============================================================================
HZZOSpecClass.Init PROCEDURE()
  CODE
  SELF.RacunQ  &= NEW(HZZORacunQType)
  SELF.StavkaQ &= NEW(HZZOStavkaQType)
  SELF.ErrorQ  &= NEW(HZZOErrorQType)

!============================================================================
! Kill - Oslobadjanje resursa
!============================================================================
HZZOSpecClass.Kill PROCEDURE()
  CODE
  IF NOT SELF.RacunQ &= NULL
    FREE(SELF.RacunQ)
    DISPOSE(SELF.RacunQ)
  END
  IF NOT SELF.StavkaQ &= NULL
    FREE(SELF.StavkaQ)
    DISPOSE(SELF.StavkaQ)
  END
  IF NOT SELF.ErrorQ &= NULL
    FREE(SELF.ErrorQ)
    DISPOSE(SELF.ErrorQ)
  END

!============================================================================
! ClearAll - Brisanje svih podataka iz queue-ova
!============================================================================
HZZOSpecClass.ClearAll PROCEDURE()
  CODE
  FREE(SELF.RacunQ)
  FREE(SELF.StavkaQ)
  FREE(SELF.ErrorQ)

!============================================================================
! GetErrorCount - Vraca broj gresaka
!============================================================================
HZZOSpecClass.GetErrorCount PROCEDURE()
RetVal LONG(0)
  CODE
  RetVal = RECORDS(SELF.ErrorQ)
  RETURN RetVal

!============================================================================
! AddError - Dodaje gresku u ErrorQ
!============================================================================
HZZOSpecClass.AddError PROCEDURE(LONG pRacunIdx,LONG pStavkaIdx,STRING pTipSloga,|
                         BYTE pRbrPolja,STRING pNazivPolja,STRING pPoruka)
  CODE
  CLEAR(SELF.ErrorQ)
  SELF.ErrorQ.RacunIndex   = pRacunIdx
  SELF.ErrorQ.StavkaIndex  = pStavkaIdx
  SELF.ErrorQ.TipSloga     = pTipSloga
  SELF.ErrorQ.RedniBrPolja = pRbrPolja
  SELF.ErrorQ.NazivPolja   = pNazivPolja
  SELF.ErrorQ.Poruka       = pPoruka
  ADD(SELF.ErrorQ)

!============================================================================
! ContainsColon - Provjerava sadrzi li vrijednost dvotocku (nedozvoljen znak)
!============================================================================
HZZOSpecClass.ContainsColon PROCEDURE(STRING pValue)
RetVal BOOL(FALSE)
I      LONG
  CODE
  LOOP I = 1 TO LEN(CLIP(pValue))
    IF pValue[I] = ':'
      RetVal = TRUE
      BREAK
    END
  END
  RETURN RetVal

!============================================================================
! ValidateDate - Validacija datuma u formatu DD.MM.YYYY
!============================================================================
HZZOSpecClass.ValidateDate PROCEDURE(STRING pDate)
RetVal   BOOL(TRUE)
sDate    STRING(10)
nDay     LONG
nMonth   LONG
nYear    LONG
nMaxDay  LONG
  CODE
  sDate = CLIP(pDate)
  IF LEN(sDate) <> 10
    RETURN FALSE
  END
  ! Provjera formata: NN.NN.NNNN
  IF sDate[3] <> '.' OR sDate[6] <> '.'
    RETURN FALSE
  END
  IF NOT NUMERIC(sDate[1:2]) OR NOT NUMERIC(sDate[4:5]) OR NOT NUMERIC(sDate[7:10])
    RETURN FALSE
  END
  nDay   = sDate[1:2]
  nMonth = sDate[4:5]
  nYear  = sDate[7:10]
  IF nYear < 1900 OR nYear > 2099
    RETURN FALSE
  END
  IF nMonth < 1 OR nMonth > 12
    RETURN FALSE
  END
  ! Maksimalan broj dana u mjesecu
  EXECUTE nMonth
    nMaxDay = 31  ! Sijecanj
    nMaxDay = 28  ! Veljaca (korekcija za prijestupnu nize)
    nMaxDay = 31  ! Ozujak
    nMaxDay = 30  ! Travanj
    nMaxDay = 31  ! Svibanj
    nMaxDay = 30  ! Lipanj
    nMaxDay = 31  ! Srpanj
    nMaxDay = 31  ! Kolovoz
    nMaxDay = 30  ! Rujan
    nMaxDay = 31  ! Listopad
    nMaxDay = 30  ! Studeni
    nMaxDay = 31  ! Prosinac
  END
  ! Prijestupna godina
  IF nMonth = 2
    IF (nYear % 4 = 0 AND nYear % 100 <> 0) OR (nYear % 400 = 0)
      nMaxDay = 29
    END
  END
  IF nDay < 1 OR nDay > nMaxDay
    RETURN FALSE
  END
  RETURN RetVal

!============================================================================
! ValidateAmount - Validacija iznosa u formatu N(max9).N2
!============================================================================
HZZOSpecClass.ValidateAmount PROCEDURE(STRING pAmount)
RetVal    BOOL(TRUE)
sAmt      STRING(12)
nLen      LONG
nDotPos   LONG
I         LONG
  CODE
  sAmt = CLIP(pAmount)
  nLen = LEN(CLIP(sAmt))
  IF nLen = 0
    RETURN FALSE
  END
  ! Pronadji tocku
  nDotPos = 0
  LOOP I = 1 TO nLen
    IF sAmt[I] = '.'
      IF nDotPos > 0   ! Dupla tocka
        RETURN FALSE
      END
      nDotPos = I
    ELSIF NOT NUMERIC(sAmt[I])
      RETURN FALSE
    END
  END
  IF nDotPos = 0
    RETURN FALSE        ! Mora imati decimalnu tocku
  END
  ! Cijeli dio: max 9 znamenki, bez vodecih nula (osim "0.xx")
  IF nDotPos - 1 > 9 OR nDotPos - 1 < 1
    RETURN FALSE
  END
  ! Decimalni dio: tocno 2 znamenke
  IF nLen - nDotPos <> 2
    RETURN FALSE
  END
  RETURN RetVal

!============================================================================
! ValidateNumeric - Provjera je li vrijednost numericka s max duljinom
!============================================================================
HZZOSpecClass.ValidateNumeric PROCEDURE(STRING pValue,LONG pMaxLen)
RetVal BOOL(TRUE)
sVal   STRING(20)
nLen   LONG
I      LONG
  CODE
  sVal = CLIP(pValue)
  nLen = LEN(CLIP(sVal))
  IF nLen = 0 OR nLen > pMaxLen
    RETURN FALSE
  END
  LOOP I = 1 TO nLen
    IF NOT NUMERIC(sVal[I])
      RETURN FALSE
    END
  END
  RETURN RetVal

!============================================================================
! CheckDigitSifraIsporucitelja - Prilog 3: Mod 11 za sifru isporucitelja
! Sifra: A1 A2 A3 A4 A5 A6 A7 A8 A9 (A9=kontrolna)
! Sum = A1*9 + A2*8 + A3*7 + A4*6 + A5*5 + A6*4 + A7*3 + A8*2
! Ostatak = Sum MOD 11
! Ako ostatak > 1 => KZ = 11 - ostatak
! Ako ostatak = 1 => KZ = 0
! Ako ostatak = 0 => KZ = 0
!============================================================================
HZZOSpecClass.CheckDigitSifraIsporucitelja PROCEDURE(STRING pSifra)
RetVal    BOOL(FALSE)
sSifra    STRING(9)
nSum      LONG(0)
nOstatak  LONG
nKZ       LONG
Weights   LONG,DIM(8)
I         LONG
  CODE
  sSifra = CLIP(pSifra)
  IF LEN(sSifra) <> 9
    RETURN FALSE
  END
  IF NOT NUMERIC(sSifra)
    RETURN FALSE
  END
  Weights[1]=9; Weights[2]=8; Weights[3]=7; Weights[4]=6
  Weights[5]=5; Weights[6]=4; Weights[7]=3; Weights[8]=2
  LOOP I = 1 TO 8
    nSum += (VAL(sSifra[I]) - VAL('0')) * Weights[I]
  END
  nOstatak = nSum % 11
  IF nOstatak > 1
    nKZ = 11 - nOstatak
  ELSE
    nKZ = 0
  END
  IF (VAL(sSifra[9]) - VAL('0')) = nKZ
    RetVal = TRUE
  END
  RETURN RetVal

!============================================================================
! CheckDigitMBO - Prilog 5: Mod 11 za maticni broj osigurane osobe
! Ponderi: 7 6 5 4 3 2 7 6 (s lijeva na desno)
! Ostatak = Sum MOD 11
! Ako ostatak = 0 => KZ = 0
! Ako ostatak = 1 => NEISPRAVAN (preskace se)
! Inace => KZ = 11 - ostatak
!============================================================================
HZZOSpecClass.CheckDigitMBO PROCEDURE(STRING pMBO)
RetVal    BOOL(FALSE)
sMBO      STRING(9)
nSum      LONG(0)
nOstatak  LONG
nKZ       LONG
Weights   LONG,DIM(8)
I         LONG
  CODE
  sMBO = CLIP(pMBO)
  IF LEN(sMBO) <> 9
    RETURN FALSE
  END
  IF NOT NUMERIC(sMBO)
    RETURN FALSE
  END
  Weights[1]=7; Weights[2]=6; Weights[3]=5; Weights[4]=4
  Weights[5]=3; Weights[6]=2; Weights[7]=7; Weights[8]=6
  LOOP I = 1 TO 8
    nSum += (VAL(sMBO[I]) - VAL('0')) * Weights[I]
  END
  nOstatak = nSum % 11
  IF nOstatak = 0
    nKZ = 0
  ELSIF nOstatak = 1
    RETURN FALSE  ! Neispravan MBO
  ELSE
    nKZ = 11 - nOstatak
  END
  IF (VAL(sMBO[9]) - VAL('0')) = nKZ
    RetVal = TRUE
  END
  RETURN RetVal

!============================================================================
! CheckDigitPotvrdaDoktora - Prilog 8: Mod 11 za broj potvrde (14 znamenki)
! Ponderi: 7 6 5 4 3 2 7 6 5 4 3 2 7 (13 znamenki + 14. kontrolna)
! Ostatak = Sum MOD 11
! Ako ostatak = 0 => KZ = 5
! Ako ostatak = 1 => KZ = 0
! Inace => KZ = 11 - ostatak
!============================================================================
HZZOSpecClass.CheckDigitPotvrdaDoktora PROCEDURE(STRING pBroj)
RetVal    BOOL(FALSE)
sBroj     STRING(14)
nSum      LONG(0)
nOstatak  LONG
nKZ       LONG
Weights   LONG,DIM(13)
I         LONG
  CODE
  sBroj = CLIP(pBroj)
  IF LEN(sBroj) <> 14
    RETURN FALSE
  END
  IF NOT NUMERIC(sBroj)
    RETURN FALSE
  END
  Weights[1]=7;  Weights[2]=6;  Weights[3]=5;  Weights[4]=4
  Weights[5]=3;  Weights[6]=2;  Weights[7]=7;  Weights[8]=6
  Weights[9]=5;  Weights[10]=4; Weights[11]=3; Weights[12]=2
  Weights[13]=7
  LOOP I = 1 TO 13
    nSum += (VAL(sBroj[I]) - VAL('0')) * Weights[I]
  END
  nOstatak = nSum % 11
  IF nOstatak = 0
    nKZ = 5
  ELSIF nOstatak = 1
    nKZ = 0
  ELSE
    nKZ = 11 - nOstatak
  END
  IF (VAL(sBroj[14]) - VAL('0')) = nKZ
    RetVal = TRUE
  END
  RETURN RetVal

!============================================================================
! CheckDigitOIB - ISO 7064, MOD 11,10 za OIB (11 znamenki)
!============================================================================
HZZOSpecClass.CheckDigitOIB PROCEDURE(STRING pOIB)
RetVal  BOOL(FALSE)
sOIB    STRING(11)
a       LONG
nDigit  LONG
I       LONG
  CODE
  sOIB = CLIP(pOIB)
  IF LEN(sOIB) <> 11
    RETURN FALSE
  END
  IF NOT NUMERIC(sOIB)
    RETURN FALSE
  END
  a = 10
  LOOP I = 1 TO 10
    nDigit = VAL(sOIB[I]) - VAL('0')
    a = (a + nDigit) % 10
    IF a = 0
      a = 10
    END
    a = (a * 2) % 11
  END
  nDigit = (11 - a) % 10
  IF (VAL(sOIB[11]) - VAL('0')) = nDigit
    RetVal = TRUE
  END
  RETURN RetVal

!============================================================================
! Validate - Validacija svih racuna i stavki
! Vraca TRUE ako je sve ispravno, FALSE ako postoje greske (greske u ErrorQ)
!============================================================================
HZZOSpecClass.Validate PROCEDURE()
RetVal     BOOL(TRUE)
I          LONG
J          LONG
nRacunIdx  LONG
bHasStavka BOOL
  CODE
  FREE(SELF.ErrorQ)
  IF RECORDS(SELF.RacunQ) = 0
    SELF.AddError(0,0,'60',0,'','Nema racuna za validaciju')
    RETURN FALSE
  END
  ! Validacija svakog racuna
  LOOP I = 1 TO RECORDS(SELF.RacunQ)
    GET(SELF.RacunQ, I)
    nRacunIdx = SELF.RacunQ.RacunIndex
    IF NOT SELF.ValidateRacun(I)
      RetVal = FALSE
    END
    ! Provjera da racun ima barem jednu stavku
    bHasStavka = FALSE
    LOOP J = 1 TO RECORDS(SELF.StavkaQ)
      GET(SELF.StavkaQ, J)
      IF SELF.StavkaQ.RacunIndex = nRacunIdx
        bHasStavka = TRUE
        IF NOT SELF.ValidateStavka(I, J)
          RetVal = FALSE
        END
      END
    END
    IF NOT bHasStavka
      SELF.AddError(nRacunIdx,0,'60',0,'Stavke','Racun nema niti jednu stavku (slog 61)')
      RetVal = FALSE
    END
  END
  RETURN RetVal

!============================================================================
! ValidateRacun - Validacija jednog racuna (slog 60)
!============================================================================
HZZOSpecClass.ValidateRacun PROCEDURE(LONG pRacunPtr)
RetVal     BOOL(TRUE)
nRacunIdx  LONG
sVal       STRING(100)
bHasMBO    BOOL
bHasOIB    BOOL
bHasINO    BOOL
bHasPotvrda BOOL
sDateA     STRING(8)
sDateB     STRING(8)
  CODE
  GET(SELF.RacunQ, pRacunPtr)
  nRacunIdx = SELF.RacunQ.RacunIndex

  ! --- Polje 2: Sifra isporucitelja (N9, obavezno, K) ---
  sVal = CLIP(SELF.RacunQ.SifraIsporucitelja)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',2,'SifraIsporucitelja','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateNumeric(sVal, 9) OR LEN(CLIP(sVal)) <> 9
    SELF.AddError(nRacunIdx,0,'60',2,'SifraIsporucitelja','Mora biti tocno 9 znamenki')
    RetVal = FALSE
  ELSIF NOT SELF.CheckDigitSifraIsporucitelja(sVal)
    SELF.AddError(nRacunIdx,0,'60',2,'SifraIsporucitelja','Neispravna kontrolna znamenka (Prilog 3)')
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.RacunQ.SifraIsporucitelja)
    SELF.AddError(nRacunIdx,0,'60',2,'SifraIsporucitelja','Sadrzi nedozvoljeni znak dvotocka')
    RetVal = FALSE
  END

  ! --- Polje 3: Naziv isporucitelja (AN max 45, obavezno) ---
  sVal = CLIP(SELF.RacunQ.NazivIsporucitelja)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',3,'NazivIsporucitelja','Obavezan podatak')
    RetVal = FALSE
  ELSIF LEN(CLIP(sVal)) > 45
    SELF.AddError(nRacunIdx,0,'60',3,'NazivIsporucitelja','Maksimalno 45 znakova')
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.RacunQ.NazivIsporucitelja)
    SELF.AddError(nRacunIdx,0,'60',3,'NazivIsporucitelja','Sadrzi nedozvoljeni znak dvotocka')
    RetVal = FALSE
  END

  ! --- Polje 4: Broj ovjerene potvrde (uvjetno) ---
  sVal = CLIP(SELF.RacunQ.BrojOvjerenePotvrde)
  IF sVal <> '' AND SELF.ContainsColon(sVal)
    SELF.AddError(nRacunIdx,0,'60',4,'BrojOvjerenePotvrde','Sadrzi nedozvoljeni znak dvotocka')
    RetVal = FALSE
  END

  ! --- Polje 5: Datum obracuna (DD.MM.YYYY, obavezno) ---
  sVal = CLIP(SELF.RacunQ.DatumObracuna)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',5,'DatumObracuna','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateDate(sVal)
    SELF.AddError(nRacunIdx,0,'60',5,'DatumObracuna','Neispravan format datuma (DD.MM.YYYY)')
    RetVal = FALSE
  END

  ! --- Polje 6: Vrsta pomagala (N1, obavezno, 1-5,7,8) ---
  sVal = CLIP(SELF.RacunQ.VrstaPomagala)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',6,'VrstaPomagala','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT INRANGE(VAL(sVal),VAL('1'),VAL('8')) |
     OR sVal = '6' OR sVal = '9' OR LEN(CLIP(sVal)) <> 1 OR NOT NUMERIC(sVal)
    SELF.AddError(nRacunIdx,0,'60',6,'VrstaPomagala','Dozvoljena vrijednost: 1,2,3,4,5,7 ili 8')
    RetVal = FALSE
  END

  ! --- Polje 7: Datum narudzbe (DD.MM.YYYY, obavezno) ---
  sVal = CLIP(SELF.RacunQ.DatumNarudzbe)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',7,'DatumNarudzbe','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateDate(sVal)
    SELF.AddError(nRacunIdx,0,'60',7,'DatumNarudzbe','Neispravan format datuma (DD.MM.YYYY)')
    RetVal = FALSE
  END

  ! --- Polje 8: Broj racuna dopunsko (ANS max 22, uvjetno) ---
  sVal = CLIP(SELF.RacunQ.BrojRacDopunsko)
  IF sVal <> '' AND LEN(CLIP(sVal)) > 22
    SELF.AddError(nRacunIdx,0,'60',8,'BrojRacDopunsko','Maksimalno 22 znaka')
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.RacunQ.BrojRacDopunsko)
    SELF.AddError(nRacunIdx,0,'60',8,'BrojRacDopunsko','Sadrzi nedozvoljeni znak dvotocka')
    RetVal = FALSE
  END

  ! --- Polje 9: Broj police (N8, uvjetno) ---
  sVal = CLIP(SELF.RacunQ.BrojPolice)
  IF sVal <> ''
    IF NOT SELF.ValidateNumeric(sVal, 8) OR LEN(CLIP(sVal)) <> 8
      SELF.AddError(nRacunIdx,0,'60',9,'BrojPolice','Mora biti tocno 8 znamenki')
      RetVal = FALSE
    END
  END

  ! --- Polje 10: Ukupni iznos pomagala (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.RacunQ.UkIznosPomagala)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',10,'UkIznosPomagala','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',10,'UkIznosPomagala','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 11: Iznos sudjelovanja (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.RacunQ.IznosSudjelovanja)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',11,'IznosSudjelovanja','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',11,'IznosSudjelovanja','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 12: Iznos dopunsko s PDV (N(max9).N2, uvjetno) ---
  sVal = CLIP(SELF.RacunQ.IznosDopunskoSPDV)
  IF sVal <> '' AND NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',12,'IznosDopunskoSPDV','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 13: Iznos PDV dopunsko (N(max9).N2, uvjetno) ---
  sVal = CLIP(SELF.RacunQ.IznosPDVDopunsko)
  IF sVal <> '' AND NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',13,'IznosPDVDopunsko','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 14: Iznos obvezno s PDV (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.RacunQ.IznosObveznoSPDV)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',14,'IznosObveznoSPDV','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',14,'IznosObveznoSPDV','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 15: Iznos PDV obvezno (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.RacunQ.IznosPDVObvezno)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',15,'IznosPDVObvezno','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',15,'IznosPDVObvezno','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 18: MBO (N9, uvjetno, K Prilog 5) ---
  bHasMBO = FALSE
  sVal = CLIP(SELF.RacunQ.MBO)
  IF sVal <> ''
    bHasMBO = TRUE
    IF NOT SELF.ValidateNumeric(sVal, 9) OR LEN(CLIP(sVal)) <> 9
      SELF.AddError(nRacunIdx,0,'60',18,'MBO','Mora biti tocno 9 znamenki')
      RetVal = FALSE
    ELSIF NOT SELF.CheckDigitMBO(sVal)
      SELF.AddError(nRacunIdx,0,'60',18,'MBO','Neispravna kontrolna znamenka (Prilog 5)')
      RetVal = FALSE
    END
  END

  ! --- Polje 19: Broj bolesnickog lista INO (uvjetno) ---
  bHasINO = FALSE
  sVal = CLIP(SELF.RacunQ.BrojBolesnickogLista)
  IF sVal <> ''
    bHasINO = TRUE
    IF LEN(CLIP(sVal)) > 20
      SELF.AddError(nRacunIdx,0,'60',19,'BrojBolesnickogLista','Maksimalno 20 znakova')
      RetVal = FALSE
    END
  END

  ! --- Polje 20: Drzava (A3, obavezno za INO) ---
  sVal = CLIP(SELF.RacunQ.Drzava)
  IF sVal <> ''
    IF LEN(CLIP(sVal)) <> 3
      SELF.AddError(nRacunIdx,0,'60',20,'Drzava','Mora biti tocno 3 slova')
      RetVal = FALSE
    END
  END
  ! Ako INO, drzava mora biti popunjena
  IF bHasINO AND CLIP(SELF.RacunQ.Drzava) = ''
    SELF.AddError(nRacunIdx,0,'60',20,'Drzava','Obavezan za INO osiguranike')
    RetVal = FALSE
  END

  ! --- Polje 22: Uk iznos fakt postupaka HZZO (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.RacunQ.UkIznosFaktHZZO)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',22,'UkIznosFaktHZZO','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',22,'UkIznosFaktHZZO','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 23: Uk iznos fakt postupaka dopunsko (uvjetno) ---
  sVal = CLIP(SELF.RacunQ.UkIznosFaktDop)
  IF sVal <> '' AND NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',23,'UkIznosFaktDop','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 24: Broj osobnog racuna (ANS max 22, obavezno) ---
  sVal = CLIP(SELF.RacunQ.BrojOsobnogRacuna)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',24,'BrojOsobnogRacuna','Obavezan podatak')
    RetVal = FALSE
  ELSIF LEN(CLIP(sVal)) > 22
    SELF.AddError(nRacunIdx,0,'60',24,'BrojOsobnogRacuna','Maksimalno 22 znaka')
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.RacunQ.BrojOsobnogRacuna)
    SELF.AddError(nRacunIdx,0,'60',24,'BrojOsobnogRacuna','Sadrzi nedozvoljeni znak dvotocka')
    RetVal = FALSE
  END

  ! --- Polje 25: Aktivnost obvezno (N7, obavezno) ---
  sVal = CLIP(SELF.RacunQ.AktivnostObvezno)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',25,'AktivnostObvezno','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateNumeric(sVal, 7)
    SELF.AddError(nRacunIdx,0,'60',25,'AktivnostObvezno','Mora biti numericki, max 7 znamenki')
    RetVal = FALSE
  END

  ! --- Polje 26: Aktivnost dopunsko (N5, nije obavezno) ---
  sVal = CLIP(SELF.RacunQ.AktivnostDopunsko)
  IF sVal <> '' AND NOT SELF.ValidateNumeric(sVal, 5)
    SELF.AddError(nRacunIdx,0,'60',26,'AktivnostDopunsko','Mora biti numericki, max 5 znamenki')
    RetVal = FALSE
  END

  ! --- Polje 27: Broj potvrde doktora (N14, uvjetno, K Prilog 8) ---
  sVal = CLIP(SELF.RacunQ.BrojPotvrdeDoktora)
  IF sVal <> ''
    IF LEN(CLIP(sVal)) <> 14
      SELF.AddError(nRacunIdx,0,'60',27,'BrojPotvrdeDoktora','Mora biti tocno 14 znamenki')
      RetVal = FALSE
    ELSIF NOT SELF.CheckDigitPotvrdaDoktora(sVal)
      SELF.AddError(nRacunIdx,0,'60',27,'BrojPotvrdeDoktora','Neispravna kontrolna znamenka (Prilog 8)')
      RetVal = FALSE
    END
  END

  ! --- Polje 28: Identifikator ePotvrde (ANS max 100, uvjetno) ---
  sVal = CLIP(SELF.RacunQ.IdentifikatorEPotvrde)
  IF sVal <> '' AND LEN(CLIP(sVal)) > 100
    SELF.AddError(nRacunIdx,0,'60',28,'IdentifikatorEPotvrde','Maksimalno 100 znakova')
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.RacunQ.IdentifikatorEPotvrde)
    SELF.AddError(nRacunIdx,0,'60',28,'IdentifikatorEPotvrde','Sadrzi nedozvoljeni znak dvotocka')
    RetVal = FALSE
  END

  ! --- Polje 29: Datum izdavanja (DD.MM.YYYY, obavezno) ---
  sVal = CLIP(SELF.RacunQ.DatumIzdavanja)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',29,'DatumIzdavanja','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateDate(sVal)
    SELF.AddError(nRacunIdx,0,'60',29,'DatumIzdavanja','Neispravan format datuma (DD.MM.YYYY)')
    RetVal = FALSE
  END

  ! --- Polje 30: Ukupni iznos razlike u cijeni (nije obavezno) ---
  sVal = CLIP(SELF.RacunQ.UkIznosRazCijene)
  IF sVal <> '' AND NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',30,'UkIznosRazCijene','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 31: OIB (N11, uvjetno, K ISO 7064) ---
  bHasOIB = FALSE
  sVal = CLIP(SELF.RacunQ.OIB)
  IF sVal <> ''
    bHasOIB = TRUE
    IF LEN(CLIP(sVal)) <> 11 OR NOT NUMERIC(sVal)
      SELF.AddError(nRacunIdx,0,'60',31,'OIB','Mora biti tocno 11 znamenki')
      RetVal = FALSE
    ELSIF NOT SELF.CheckDigitOIB(sVal)
      SELF.AddError(nRacunIdx,0,'60',31,'OIB','Neispravna kontrolna znamenka (ISO 7064)')
      RetVal = FALSE
    END
  END

  ! --- Polje 32: Valuta (A3, obavezno, EUR) ---
  sVal = CLIP(SELF.RacunQ.Valuta)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',32,'Valuta','Obavezan podatak')
    RetVal = FALSE
  ELSIF UPPER(sVal) <> 'EUR'
    SELF.AddError(nRacunIdx,0,'60',32,'Valuta','Valuta mora biti EUR')
    RetVal = FALSE
  END

  ! --- Poslovna pravila ---
  ! Identifikacija osigurane osobe: mora biti MBO ili OIB ili (INO polja 19+20)
  IF NOT bHasMBO AND NOT bHasOIB AND NOT bHasINO
    SELF.AddError(nRacunIdx,0,'60',18,'MBO/OIB/INO','Mora biti upisan MBO (polje 18) ili OIB (polje 31) ili INO podaci (polja 19,20)')
    RetVal = FALSE
  END

  ! Identifikacija potvrde: mora biti barem jedan od polja 4, 27, 28
  bHasPotvrda = FALSE
  IF CLIP(SELF.RacunQ.BrojOvjerenePotvrde) <> '' THEN bHasPotvrda = TRUE.
  IF CLIP(SELF.RacunQ.BrojPotvrdeDoktora) <> ''  THEN bHasPotvrda = TRUE.
  IF CLIP(SELF.RacunQ.IdentifikatorEPotvrde) <> '' THEN bHasPotvrda = TRUE.
  IF NOT bHasPotvrda
    SELF.AddError(nRacunIdx,0,'60',4,'Potvrda','Mora biti upisan barem jedan: Broj ovjerene potvrde (4), Broj potvrde doktora (27) ili ePotvrda (28)')
    RetVal = FALSE
  END

  ! Datum obracuna >= Datum narudzbe
  IF SELF.ValidateDate(CLIP(SELF.RacunQ.DatumObracuna)) AND SELF.ValidateDate(CLIP(SELF.RacunQ.DatumNarudzbe))
    IF CLIP(SELF.RacunQ.DatumObracuna) <> '' AND CLIP(SELF.RacunQ.DatumNarudzbe) <> ''
      ! Usporedba: pretvorimo DD.MM.YYYY u YYYYMMDD za usporedbu
      sDateA = SELF.RacunQ.DatumObracuna[7:10] & SELF.RacunQ.DatumObracuna[4:5] & SELF.RacunQ.DatumObracuna[1:2]
      sDateB = SELF.RacunQ.DatumNarudzbe[7:10] & SELF.RacunQ.DatumNarudzbe[4:5] & SELF.RacunQ.DatumNarudzbe[1:2]
      IF sDateA < sDateB
        SELF.AddError(nRacunIdx,0,'60',5,'DatumObracuna','Datum obracuna mora biti >= datum narudzbe')
        RetVal = FALSE
      END
    END
  END

  ! Datum narudzbe <= Datum izdavanja
  IF SELF.ValidateDate(CLIP(SELF.RacunQ.DatumNarudzbe)) AND SELF.ValidateDate(CLIP(SELF.RacunQ.DatumIzdavanja))
    IF CLIP(SELF.RacunQ.DatumNarudzbe) <> '' AND CLIP(SELF.RacunQ.DatumIzdavanja) <> ''
      sDateA = SELF.RacunQ.DatumNarudzbe[7:10] & SELF.RacunQ.DatumNarudzbe[4:5] & SELF.RacunQ.DatumNarudzbe[1:2]
      sDateB = SELF.RacunQ.DatumIzdavanja[7:10] & SELF.RacunQ.DatumIzdavanja[4:5] & SELF.RacunQ.DatumIzdavanja[1:2]
      IF sDateA > sDateB
        SELF.AddError(nRacunIdx,0,'60',7,'DatumNarudzbe','Datum narudzbe mora biti <= datum izdavanja')
        RetVal = FALSE
      END
    END
  END

  RETURN RetVal

!============================================================================
! ValidateStavka - Validacija jedne stavke (slog 61)
!============================================================================
HZZOSpecClass.ValidateStavka PROCEDURE(LONG pRacunPtr,LONG pStavkaPtr)
RetVal      BOOL(TRUE)
nRacunIdx   LONG
sVal        STRING(100)
bHasPotvrda BOOL
  CODE
  GET(SELF.RacunQ, pRacunPtr)
  nRacunIdx = SELF.RacunQ.RacunIndex
  GET(SELF.StavkaQ, pStavkaPtr)

  ! --- Polje 2: Broj ovjerene potvrde (uvjetno) ---
  sVal = CLIP(SELF.StavkaQ.BrojOvjerenePotvrde)
  IF sVal <> '' AND SELF.ContainsColon(sVal)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',2,'BrojOvjerenePotvrde','Sadrzi nedozvoljeni znak dvotocka')
    RetVal = FALSE
  END

  ! --- Polje 3: Datum obracuna (DD.MM.YYYY, obavezno) ---
  sVal = CLIP(SELF.StavkaQ.DatumObracuna)
  IF sVal = ''
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',3,'DatumObracuna','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateDate(sVal)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',3,'DatumObracuna','Neispravan format datuma (DD.MM.YYYY)')
    RetVal = FALSE
  END

  ! --- Polje 4: Sifra pomagala (obavezno) ---
  sVal = CLIP(SELF.StavkaQ.SifraPomagala)
  IF sVal = ''
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',4,'SifraPomagala','Obavezan podatak')
    RetVal = FALSE
  ELSE
    IF LEN(CLIP(sVal)) <> 7 AND LEN(CLIP(sVal)) <> 12 AND LEN(CLIP(sVal)) <> 13
      SELF.AddError(nRacunIdx,pStavkaPtr,'61',4,'SifraPomagala','Duljina sifre mora biti 7, 12 ili 13 znakova')
      RetVal = FALSE
    END
  END
  IF SELF.ContainsColon(SELF.StavkaQ.SifraPomagala)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',4,'SifraPomagala','Sadrzi nedozvoljeni znak dvotocka')
    RetVal = FALSE
  END

  ! --- Polje 5: Kolicina (N(max5).N2, obavezno) ---
  sVal = CLIP(SELF.StavkaQ.Kolicina)
  IF sVal = ''
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',5,'Kolicina','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',5,'Kolicina','Neispravan format kolicine (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 6: Ukupni iznos (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.StavkaQ.UkupniIznos)
  IF sVal = ''
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',6,'UkupniIznos','Obavezan podatak')
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',6,'UkupniIznos','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Polje 7: Sifra proizvodjaca (N10, nije obavezno) ---
  sVal = CLIP(SELF.StavkaQ.SifraProizvodjaca)
  IF sVal <> '' AND NOT SELF.ValidateNumeric(sVal, 10)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',7,'SifraProizvodjaca','Mora biti numericki, max 10 znamenki')
    RetVal = FALSE
  END

  ! --- Polje 8: Broj potvrde doktora (N14, uvjetno, K Prilog 8) ---
  sVal = CLIP(SELF.StavkaQ.BrojPotvrdeDoktora)
  IF sVal <> ''
    IF LEN(CLIP(sVal)) <> 14
      SELF.AddError(nRacunIdx,pStavkaPtr,'61',8,'BrojPotvrdeDoktora','Mora biti tocno 14 znamenki')
      RetVal = FALSE
    ELSIF NOT SELF.CheckDigitPotvrdaDoktora(sVal)
      SELF.AddError(nRacunIdx,pStavkaPtr,'61',8,'BrojPotvrdeDoktora','Neispravna kontrolna znamenka (Prilog 8)')
      RetVal = FALSE
    END
  END

  ! --- Polje 9: Sifra velicine obloge (N4, uvjetno) ---
  sVal = CLIP(SELF.StavkaQ.SifraVelicineObloge)
  IF sVal <> '' AND NOT SELF.ValidateNumeric(sVal, 4)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',9,'SifraVelicineObloge','Mora biti numericki, max 4 znamenke')
    RetVal = FALSE
  END

  ! --- Polje 10: Identifikacija izdanog pomagala (ANS max 30) ---
  sVal = CLIP(SELF.StavkaQ.IdentifikacijaPomagala)
  IF sVal <> '' AND LEN(CLIP(sVal)) > 30
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',10,'IdentifikacijaPomagala','Maksimalno 30 znakova')
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.StavkaQ.IdentifikacijaPomagala)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',10,'IdentifikacijaPomagala','Sadrzi nedozvoljeni znak dvotocka')
    RetVal = FALSE
  END

  ! --- Polje 11: Identifikator ePotvrde (ANS max 100) ---
  sVal = CLIP(SELF.StavkaQ.IdentifikatorEPotvrde)
  IF sVal <> '' AND LEN(CLIP(sVal)) > 100
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',11,'IdentifikatorEPotvrde','Maksimalno 100 znakova')
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.StavkaQ.IdentifikatorEPotvrde)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',11,'IdentifikatorEPotvrde','Sadrzi nedozvoljeni znak dvotocka')
    RetVal = FALSE
  END

  ! --- Polje 12: Iznos razlike u cijeni (nije obavezno) ---
  sVal = CLIP(SELF.StavkaQ.IznosRazCijene)
  IF sVal <> '' AND NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',12,'IznosRazCijene','Neispravan format iznosa (N.NN)')
    RetVal = FALSE
  END

  ! --- Poslovno pravilo: identifikacija potvrde ---
  bHasPotvrda = FALSE
  IF CLIP(SELF.StavkaQ.BrojOvjerenePotvrde) <> '' THEN bHasPotvrda = TRUE.
  IF CLIP(SELF.StavkaQ.BrojPotvrdeDoktora) <> ''  THEN bHasPotvrda = TRUE.
  IF CLIP(SELF.StavkaQ.IdentifikatorEPotvrde) <> '' THEN bHasPotvrda = TRUE.
  ! Provjera i na razini racuna
  GET(SELF.RacunQ, pRacunPtr)
  IF CLIP(SELF.RacunQ.BrojOvjerenePotvrde) <> '' THEN bHasPotvrda = TRUE.
  IF CLIP(SELF.RacunQ.BrojPotvrdeDoktora) <> ''  THEN bHasPotvrda = TRUE.
  IF CLIP(SELF.RacunQ.IdentifikatorEPotvrde) <> '' THEN bHasPotvrda = TRUE.
  IF NOT bHasPotvrda
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',2,'Potvrda','Mora biti upisan barem jedan identifikator potvrde')
    RetVal = FALSE
  END

  RETURN RetVal

!============================================================================
! FormatRacunLine - Formatira jedan redak sloga 60 (32 polja + trailing :)
!============================================================================
HZZOSpecClass.FormatRacunLine PROCEDURE(LONG pRacunPtr)
sLine   STRING(2000)
  CODE
  GET(SELF.RacunQ, pRacunPtr)
  sLine = '60'                                          |
    & ':' & CLIP(SELF.RacunQ.SifraIsporucitelja)        |
    & ':' & CLIP(SELF.RacunQ.NazivIsporucitelja)        |
    & ':' & CLIP(SELF.RacunQ.BrojOvjerenePotvrde)       |
    & ':' & CLIP(SELF.RacunQ.DatumObracuna)             |
    & ':' & CLIP(SELF.RacunQ.VrstaPomagala)             |
    & ':' & CLIP(SELF.RacunQ.DatumNarudzbe)             |
    & ':' & CLIP(SELF.RacunQ.BrojRacDopunsko)           |
    & ':' & CLIP(SELF.RacunQ.BrojPolice)                |
    & ':' & CLIP(SELF.RacunQ.UkIznosPomagala)           |
    & ':' & CLIP(SELF.RacunQ.IznosSudjelovanja)         |
    & ':' & CLIP(SELF.RacunQ.IznosDopunskoSPDV)         |
    & ':' & CLIP(SELF.RacunQ.IznosPDVDopunsko)          |
    & ':' & CLIP(SELF.RacunQ.IznosObveznoSPDV)          |
    & ':' & CLIP(SELF.RacunQ.IznosPDVObvezno)           |
    & ':' & CLIP(SELF.RacunQ.NeKoristiSe1)              |
    & ':' & CLIP(SELF.RacunQ.NeKoristiSe2)              |
    & ':' & CLIP(SELF.RacunQ.MBO)                       |
    & ':' & CLIP(SELF.RacunQ.BrojBolesnickogLista)      |
    & ':' & CLIP(SELF.RacunQ.Drzava)                    |
    & ':' & CLIP(SELF.RacunQ.SifraProizvodjaca)         |
    & ':' & CLIP(SELF.RacunQ.UkIznosFaktHZZO)           |
    & ':' & CLIP(SELF.RacunQ.UkIznosFaktDop)            |
    & ':' & CLIP(SELF.RacunQ.BrojOsobnogRacuna)         |
    & ':' & CLIP(SELF.RacunQ.AktivnostObvezno)          |
    & ':' & CLIP(SELF.RacunQ.AktivnostDopunsko)         |
    & ':' & CLIP(SELF.RacunQ.BrojPotvrdeDoktora)        |
    & ':' & CLIP(SELF.RacunQ.IdentifikatorEPotvrde)     |
    & ':' & CLIP(SELF.RacunQ.DatumIzdavanja)            |
    & ':' & CLIP(SELF.RacunQ.UkIznosRazCijene)          |
    & ':' & CLIP(SELF.RacunQ.OIB)                       |
    & ':' & CLIP(SELF.RacunQ.Valuta)                    |
    & ':'
  RETURN CLIP(sLine)

!============================================================================
! FormatStavkaLine - Formatira jedan redak stavke 61 (12 polja + trailing :)
!============================================================================
HZZOSpecClass.FormatStavkaLine PROCEDURE(LONG pStavkaPtr)
sLine   STRING(2000)
  CODE
  GET(SELF.StavkaQ, pStavkaPtr)
  sLine = '61'                                          |
    & ':' & CLIP(SELF.StavkaQ.BrojOvjerenePotvrde)      |
    & ':' & CLIP(SELF.StavkaQ.DatumObracuna)            |
    & ':' & CLIP(SELF.StavkaQ.SifraPomagala)            |
    & ':' & CLIP(SELF.StavkaQ.Kolicina)                 |
    & ':' & CLIP(SELF.StavkaQ.UkupniIznos)              |
    & ':' & CLIP(SELF.StavkaQ.SifraProizvodjaca)        |
    & ':' & CLIP(SELF.StavkaQ.BrojPotvrdeDoktora)       |
    & ':' & CLIP(SELF.StavkaQ.SifraVelicineObloge)      |
    & ':' & CLIP(SELF.StavkaQ.IdentifikacijaPomagala)   |
    & ':' & CLIP(SELF.StavkaQ.IdentifikatorEPotvrde)    |
    & ':' & CLIP(SELF.StavkaQ.IznosRazCijene)           |
    & ':'
  RETURN CLIP(sLine)

!============================================================================
! Export - Exportira podatke u datoteku prema HZZO specifikaciji
! Format: dvotockom razdvojeni podaci, CR/LF na kraju retka
! Redoslijed: Slog 60, zatim stavke 61 za taj racun, pa sljedeci racun...
! Vraca TRUE ako je uspjesno, FALSE uz greske u ErrorQ
!============================================================================
HZZOSpecClass.Export PROCEDURE(STRING pFileName)
RetVal      BOOL(TRUE)
I           LONG
J           LONG
nRacunIdx   LONG
sLine       STRING(2000)
hFile       LONG
csFileName  CSTRING(261)
  CODE
  ! Prvo validiraj
  IF NOT SELF.Validate()
    RETURN FALSE
  END
  ! Otvori/kreiraj datoteku za pisanje (Win32 API)
  csFileName = CLIP(pFileName)
  hFile = kcr_CreateFile(csFileName, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTR_NORMAL, 0)
  IF hFile = INVALID_HANDLE
    SELF.AddError(0,0,'',0,'Export','Greska pri kreiranju datoteke: ' & CLIP(pFileName))
    RETURN FALSE
  END
  ! Zapisi sve racune i njihove stavke
  LOOP I = 1 TO RECORDS(SELF.RacunQ)
    GET(SELF.RacunQ, I)
    nRacunIdx = SELF.RacunQ.RacunIndex
    ! Zapisi slog racuna (60)
    sLine = SELF.FormatRacunLine(I)
    IF NOT WriteLine(hFile, sLine)
      SELF.AddError(nRacunIdx,0,'60',0,'Export','Greska pri zapisu sloga 60')
      RetVal = FALSE
      BREAK
    END
    ! Zapisi sve stavke za ovaj racun (61)
    LOOP J = 1 TO RECORDS(SELF.StavkaQ)
      GET(SELF.StavkaQ, J)
      IF SELF.StavkaQ.RacunIndex = nRacunIdx
        sLine = SELF.FormatStavkaLine(J)
        IF NOT WriteLine(hFile, sLine)
          SELF.AddError(nRacunIdx,J,'61',0,'Export','Greska pri zapisu sloga 61')
          RetVal = FALSE
          BREAK
        END
      END
    END
    IF NOT RetVal THEN BREAK.
  END
  kcr_CloseHandle(hFile)
  RETURN RetVal

!============================================================================
! GenerateFileName - Generira naziv datoteke prema HZZO specifikaciji
! Format: aaabbbbbbbbbcccc.Ozz
! aaa = sifra podrucne sluzbe (3 znamenke)
! bbbbbbbbb = sifra isporucitelja (9 znamenki)
! cccc = redni broj datoteke u godini (4 znamenke)
! O = konstanta za ortopedska pomagala
! zz = godina (2 znamenke)
!============================================================================
HZZOSpecClass.GenerateFileName PROCEDURE(STRING pSifraPodSluzbe,STRING pSifraIsporucitelja,|
                                 LONG pRedniBroj,LONG pGodina)
sResult      STRING(30)
sSifraPS     STRING(3)
sSifraIsp    STRING(9)
sRedniBroj   STRING(4)
sGodina      STRING(2)
  CODE
  sSifraPS   = ALL('0', 3 - LEN(CLIP(pSifraPodSluzbe))) & CLIP(pSifraPodSluzbe)
  sSifraIsp  = CLIP(pSifraIsporucitelja)
  ! Redni broj na 4 znamenke s vodecim nulama
  sRedniBroj = FORMAT(pRedniBroj, @n04)
  ! Godina - zadnje 2 znamenke
  sGodina    = FORMAT(pGodina % 100, @n02)
  sResult = CLIP(sSifraPS) & CLIP(sSifraIsp) & CLIP(sRedniBroj) & '.O' & CLIP(sGodina)
  RETURN CLIP(sResult)

!============================================================================
! WriteLine - Zapisi liniju u Win32 datoteku s CRLF zavrsekom
!============================================================================
WriteLine PROCEDURE(LONG pHandle, STRING pLine)
sData    STRING(2002)
nWritten LONG
nLen     LONG
  CODE
  sData    = CLIP(pLine) & '<13,10>'
  nLen     = LEN(CLIP(pLine)) + 2
  kcr_WriteFile(pHandle, sData, nLen, nWritten, 0)
  IF nWritten = nLen
    RETURN TRUE
  END
  RETURN FALSE
