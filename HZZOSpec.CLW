!============================================================================
! HZZOSpec.CLW - Implementacija HZZO specifikacije osobnog racuna pomagala
! Bazirana na dokumentu OS_POM_25.docx
!============================================================================
  MEMBER()
  INCLUDE('HZZOSpec.INC')
  INCLUDE('ABWMFPAR.INC'),ONCE
  INCLUDE('abprI2pdf.inc'),ONCE
  INCLUDE('abrppsel.inc'),ONCE
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
                         BYTE pRbrPolja,STRING pNazivPolja,STRING pPoruka,|
                         STRING pVrijednost)
  CODE
  CLEAR(SELF.ErrorQ)
  SELF.ErrorQ.RacunIndex      = pRacunIdx
  SELF.ErrorQ.StavkaIndex     = pStavkaIdx
  SELF.ErrorQ.TipSloga        = pTipSloga
  SELF.ErrorQ.RedniBrPolja    = pRbrPolja
  SELF.ErrorQ.NazivPolja      = pNazivPolja
  SELF.ErrorQ.Poruka          = pPoruka
  SELF.ErrorQ.VrijednostPolja = pVrijednost
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
    SELF.AddError(0,0,'60',0,'','Nema racuna za validaciju','')
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
      SELF.AddError(nRacunIdx,0,'60',0,'Stavke','Racun nema niti jednu stavku (slog 61)','')
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
    SELF.AddError(nRacunIdx,0,'60',2,'SifraIsporucitelja','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateNumeric(sVal, 9) OR LEN(CLIP(sVal)) <> 9
    SELF.AddError(nRacunIdx,0,'60',2,'SifraIsporucitelja','Mora biti tocno 9 znamenki',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.CheckDigitSifraIsporucitelja(sVal)
    SELF.AddError(nRacunIdx,0,'60',2,'SifraIsporucitelja','Neispravna kontrolna znamenka (Prilog 3)',sVal)
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.RacunQ.SifraIsporucitelja)
    SELF.AddError(nRacunIdx,0,'60',2,'SifraIsporucitelja','Sadrzi nedozvoljeni znak dvotocka',sVal)
    RetVal = FALSE
  END

  ! --- Polje 3: Naziv isporucitelja (AN max 45, obavezno) ---
  sVal = CLIP(SELF.RacunQ.NazivIsporucitelja)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',3,'NazivIsporucitelja','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF LEN(CLIP(sVal)) > 45
    SELF.AddError(nRacunIdx,0,'60',3,'NazivIsporucitelja','Maksimalno 45 znakova',sVal)
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.RacunQ.NazivIsporucitelja)
    SELF.AddError(nRacunIdx,0,'60',3,'NazivIsporucitelja','Sadrzi nedozvoljeni znak dvotocka',sVal)
    RetVal = FALSE
  END

  ! --- Polje 4: Broj ovjerene potvrde (uvjetno) ---
  sVal = CLIP(SELF.RacunQ.BrojOvjerenePotvrde)
  IF sVal <> '' AND SELF.ContainsColon(sVal)
    SELF.AddError(nRacunIdx,0,'60',4,'BrojOvjerenePotvrde','Sadrzi nedozvoljeni znak dvotocka',sVal)
    RetVal = FALSE
  END

  ! --- Polje 5: Datum obracuna (DD.MM.YYYY, obavezno) ---
  sVal = CLIP(SELF.RacunQ.DatumObracuna)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',5,'DatumObracuna','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateDate(sVal)
    SELF.AddError(nRacunIdx,0,'60',5,'DatumObracuna','Neispravan format datuma (DD.MM.YYYY)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 6: Vrsta pomagala (N1, obavezno, 1-5,7,8) ---
  sVal = CLIP(SELF.RacunQ.VrstaPomagala)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',6,'VrstaPomagala','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT INRANGE(VAL(sVal),VAL('1'),VAL('8')) |
     OR sVal = '6' OR sVal = '9' OR LEN(CLIP(sVal)) <> 1 OR NOT NUMERIC(sVal)
    SELF.AddError(nRacunIdx,0,'60',6,'VrstaPomagala','Dozvoljena vrijednost: 1,2,3,4,5,7 ili 8',sVal)
    RetVal = FALSE
  END

  ! --- Polje 7: Datum narudzbe (DD.MM.YYYY, obavezno) ---
  sVal = CLIP(SELF.RacunQ.DatumNarudzbe)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',7,'DatumNarudzbe','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateDate(sVal)
    SELF.AddError(nRacunIdx,0,'60',7,'DatumNarudzbe','Neispravan format datuma (DD.MM.YYYY)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 8: Broj racuna dopunsko (ANS max 22, uvjetno) ---
  sVal = CLIP(SELF.RacunQ.BrojRacDopunsko)
  IF sVal <> '' AND LEN(CLIP(sVal)) > 22
    SELF.AddError(nRacunIdx,0,'60',8,'BrojRacDopunsko','Maksimalno 22 znaka',sVal)
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.RacunQ.BrojRacDopunsko)
    SELF.AddError(nRacunIdx,0,'60',8,'BrojRacDopunsko','Sadrzi nedozvoljeni znak dvotocka',sVal)
    RetVal = FALSE
  END

  ! --- Polje 9: Broj police (N8, uvjetno) ---
  sVal = CLIP(SELF.RacunQ.BrojPolice)
  IF sVal <> ''
    IF NOT SELF.ValidateNumeric(sVal, 8) OR LEN(CLIP(sVal)) <> 8
      SELF.AddError(nRacunIdx,0,'60',9,'BrojPolice','Mora biti tocno 8 znamenki',sVal)
      RetVal = FALSE
    END
  END

  ! --- Polje 10: Ukupni iznos pomagala (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.RacunQ.UkIznosPomagala)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',10,'UkIznosPomagala','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',10,'UkIznosPomagala','Neispravan format iznosa (N.NN)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 11: Iznos sudjelovanja (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.RacunQ.IznosSudjelovanja)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',11,'IznosSudjelovanja','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',11,'IznosSudjelovanja','Neispravan format iznosa (N.NN)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 12: Iznos dopunsko s PDV (N(max9).N2, uvjetno) ---
  sVal = CLIP(SELF.RacunQ.IznosDopunskoSPDV)
  IF sVal <> '' AND NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',12,'IznosDopunskoSPDV','Neispravan format iznosa (N.NN)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 13: Iznos PDV dopunsko (N(max9).N2, uvjetno) ---
  sVal = CLIP(SELF.RacunQ.IznosPDVDopunsko)
  IF sVal <> '' AND NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',13,'IznosPDVDopunsko','Neispravan format iznosa (N.NN)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 14: Iznos obvezno s PDV (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.RacunQ.IznosObveznoSPDV)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',14,'IznosObveznoSPDV','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',14,'IznosObveznoSPDV','Neispravan format iznosa (N.NN)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 15: Iznos PDV obvezno (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.RacunQ.IznosPDVObvezno)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',15,'IznosPDVObvezno','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',15,'IznosPDVObvezno','Neispravan format iznosa (N.NN)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 18: MBO (N9, uvjetno, K Prilog 5) ---
  bHasMBO = FALSE
  sVal = CLIP(SELF.RacunQ.MBO)
  IF sVal <> ''
    bHasMBO = TRUE
    IF NOT SELF.ValidateNumeric(sVal, 9) OR LEN(CLIP(sVal)) <> 9
      SELF.AddError(nRacunIdx,0,'60',18,'MBO','Mora biti tocno 9 znamenki',sVal)
      RetVal = FALSE
    ELSIF NOT SELF.CheckDigitMBO(sVal)
      SELF.AddError(nRacunIdx,0,'60',18,'MBO','Neispravna kontrolna znamenka (Prilog 5)',sVal)
      RetVal = FALSE
    END
  END

  ! --- Polje 19: Broj bolesnickog lista INO (uvjetno) ---
  bHasINO = FALSE
  sVal = CLIP(SELF.RacunQ.BrojBolesnickogLista)
  IF sVal <> ''
    bHasINO = TRUE
    IF LEN(CLIP(sVal)) > 20
      SELF.AddError(nRacunIdx,0,'60',19,'BrojBolesnickogLista','Maksimalno 20 znakova',sVal)
      RetVal = FALSE
    END
  END

  ! --- Polje 20: Drzava (A3, obavezno za INO) ---
  sVal = CLIP(SELF.RacunQ.Drzava)
  IF sVal <> ''
    IF LEN(CLIP(sVal)) <> 3
      SELF.AddError(nRacunIdx,0,'60',20,'Drzava','Mora biti tocno 3 slova',sVal)
      RetVal = FALSE
    END
  END
  ! Ako INO, drzava mora biti popunjena
  IF bHasINO AND CLIP(SELF.RacunQ.Drzava) = ''
    SELF.AddError(nRacunIdx,0,'60',20,'Drzava','Obavezan za INO osiguranike','')
    RetVal = FALSE
  END

  ! --- Polje 22: Uk iznos fakt postupaka HZZO (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.RacunQ.UkIznosFaktHZZO)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',22,'UkIznosFaktHZZO','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',22,'UkIznosFaktHZZO','Neispravan format iznosa (N.NN)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 23: Uk iznos fakt postupaka dopunsko (uvjetno) ---
  sVal = CLIP(SELF.RacunQ.UkIznosFaktDop)
  IF sVal <> '' AND NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',23,'UkIznosFaktDop','Neispravan format iznosa (N.NN)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 24: Broj osobnog racuna (ANS max 22, obavezno) ---
  sVal = CLIP(SELF.RacunQ.BrojOsobnogRacuna)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',24,'BrojOsobnogRacuna','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF LEN(CLIP(sVal)) > 22
    SELF.AddError(nRacunIdx,0,'60',24,'BrojOsobnogRacuna','Maksimalno 22 znaka',sVal)
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.RacunQ.BrojOsobnogRacuna)
    SELF.AddError(nRacunIdx,0,'60',24,'BrojOsobnogRacuna','Sadrzi nedozvoljeni znak dvotocka',sVal)
    RetVal = FALSE
  END

  ! --- Polje 25: Aktivnost obvezno (N7, obavezno) ---
  sVal = CLIP(SELF.RacunQ.AktivnostObvezno)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',25,'AktivnostObvezno','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateNumeric(sVal, 7)
    SELF.AddError(nRacunIdx,0,'60',25,'AktivnostObvezno','Mora biti numericki, max 7 znamenki',sVal)
    RetVal = FALSE
  END

  ! --- Polje 26: Aktivnost dopunsko (N5, nije obavezno) ---
  sVal = CLIP(SELF.RacunQ.AktivnostDopunsko)
  IF sVal <> '' AND NOT SELF.ValidateNumeric(sVal, 5)
    SELF.AddError(nRacunIdx,0,'60',26,'AktivnostDopunsko','Mora biti numericki, max 5 znamenki',sVal)
    RetVal = FALSE
  END

  ! --- Polje 27: Broj potvrde doktora (N14, uvjetno, K Prilog 8) ---
  sVal = CLIP(SELF.RacunQ.BrojPotvrdeDoktora)
  IF sVal <> ''
    IF LEN(CLIP(sVal)) <> 14
      SELF.AddError(nRacunIdx,0,'60',27,'BrojPotvrdeDoktora','Mora biti tocno 14 znamenki',sVal)
      RetVal = FALSE
    ELSIF NOT SELF.CheckDigitPotvrdaDoktora(sVal)
      SELF.AddError(nRacunIdx,0,'60',27,'BrojPotvrdeDoktora','Neispravna kontrolna znamenka (Prilog 8)',sVal)
      RetVal = FALSE
    END
  END

  ! --- Polje 28: Identifikator ePotvrde (ANS max 100, uvjetno) ---
  sVal = CLIP(SELF.RacunQ.IdentifikatorEPotvrde)
  IF sVal <> '' AND LEN(CLIP(sVal)) > 100
    SELF.AddError(nRacunIdx,0,'60',28,'IdentifikatorEPotvrde','Maksimalno 100 znakova',sVal)
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.RacunQ.IdentifikatorEPotvrde)
    SELF.AddError(nRacunIdx,0,'60',28,'IdentifikatorEPotvrde','Sadrzi nedozvoljeni znak dvotocka',sVal)
    RetVal = FALSE
  END

  ! --- Polje 29: Datum izdavanja (DD.MM.YYYY, obavezno) ---
  sVal = CLIP(SELF.RacunQ.DatumIzdavanja)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',29,'DatumIzdavanja','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateDate(sVal)
    SELF.AddError(nRacunIdx,0,'60',29,'DatumIzdavanja','Neispravan format datuma (DD.MM.YYYY)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 30: Ukupni iznos razlike u cijeni (nije obavezno) ---
  sVal = CLIP(SELF.RacunQ.UkIznosRazCijene)
  IF sVal <> '' AND NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,0,'60',30,'UkIznosRazCijene','Neispravan format iznosa (N.NN)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 31: OIB (N11, uvjetno, K ISO 7064) ---
  bHasOIB = FALSE
  sVal = CLIP(SELF.RacunQ.OIB)
  IF sVal <> ''
    bHasOIB = TRUE
    IF LEN(CLIP(sVal)) <> 11 OR NOT NUMERIC(sVal)
      SELF.AddError(nRacunIdx,0,'60',31,'OIB','Mora biti tocno 11 znamenki',sVal)
      RetVal = FALSE
    ELSIF NOT SELF.CheckDigitOIB(sVal)
      SELF.AddError(nRacunIdx,0,'60',31,'OIB','Neispravna kontrolna znamenka (ISO 7064)',sVal)
      RetVal = FALSE
    END
  END

  ! --- Polje 32: Valuta (A3, obavezno, EUR) ---
  sVal = CLIP(SELF.RacunQ.Valuta)
  IF sVal = ''
    SELF.AddError(nRacunIdx,0,'60',32,'Valuta','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF UPPER(sVal) <> 'EUR'
    SELF.AddError(nRacunIdx,0,'60',32,'Valuta','Valuta mora biti EUR',sVal)
    RetVal = FALSE
  END

  ! --- Poslovna pravila ---
  ! Identifikacija osigurane osobe: mora biti MBO ili OIB ili (INO polja 19+20)
  IF NOT bHasMBO AND NOT bHasOIB AND NOT bHasINO
    SELF.AddError(nRacunIdx,0,'60',18,'MBO/OIB/INO','Mora biti upisan MBO (polje 18) ili OIB (polje 31) ili INO podaci (polja 19,20)','')
    RetVal = FALSE
  END

  ! Identifikacija potvrde: mora biti barem jedan od polja 4, 27, 28
  bHasPotvrda = FALSE
  IF CLIP(SELF.RacunQ.BrojOvjerenePotvrde) <> '' THEN bHasPotvrda = TRUE.
  IF CLIP(SELF.RacunQ.BrojPotvrdeDoktora) <> ''  THEN bHasPotvrda = TRUE.
  IF CLIP(SELF.RacunQ.IdentifikatorEPotvrde) <> '' THEN bHasPotvrda = TRUE.
  IF NOT bHasPotvrda
    SELF.AddError(nRacunIdx,0,'60',4,'Potvrda','Mora biti upisan barem jedan: Broj ovjerene potvrde (4), Broj potvrde doktora (27) ili ePotvrda (28)','')
    RetVal = FALSE
  END

  ! Datum obracuna >= Datum narudzbe
  IF SELF.ValidateDate(CLIP(SELF.RacunQ.DatumObracuna)) AND SELF.ValidateDate(CLIP(SELF.RacunQ.DatumNarudzbe))
    IF CLIP(SELF.RacunQ.DatumObracuna) <> '' AND CLIP(SELF.RacunQ.DatumNarudzbe) <> ''
      ! Usporedba: pretvorimo DD.MM.YYYY u YYYYMMDD za usporedbu
      sDateA = SELF.RacunQ.DatumObracuna[7:10] & SELF.RacunQ.DatumObracuna[4:5] & SELF.RacunQ.DatumObracuna[1:2]
      sDateB = SELF.RacunQ.DatumNarudzbe[7:10] & SELF.RacunQ.DatumNarudzbe[4:5] & SELF.RacunQ.DatumNarudzbe[1:2]
      IF sDateA < sDateB
        SELF.AddError(nRacunIdx,0,'60',5,'DatumObracuna','Datum obracuna mora biti >= datum narudzbe','')
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
        SELF.AddError(nRacunIdx,0,'60',7,'DatumNarudzbe','Datum narudzbe mora biti <= datum izdavanja','')
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
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',2,'BrojOvjerenePotvrde','Sadrzi nedozvoljeni znak dvotocka',sVal)
    RetVal = FALSE
  END

  ! --- Polje 3: Datum obracuna (DD.MM.YYYY, obavezno) ---
  sVal = CLIP(SELF.StavkaQ.DatumObracuna)
  IF sVal = ''
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',3,'DatumObracuna','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateDate(sVal)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',3,'DatumObracuna','Neispravan format datuma (DD.MM.YYYY)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 4: Sifra pomagala (obavezno) ---
  sVal = CLIP(SELF.StavkaQ.SifraPomagala)
  IF sVal = ''
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',4,'SifraPomagala','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSE
    IF LEN(CLIP(sVal)) <> 7 AND LEN(CLIP(sVal)) <> 12 AND LEN(CLIP(sVal)) <> 13
      SELF.AddError(nRacunIdx,pStavkaPtr,'61',4,'SifraPomagala','Duljina sifre mora biti 7, 12 ili 13 znakova',sVal)
      RetVal = FALSE
    END
  END
  IF SELF.ContainsColon(SELF.StavkaQ.SifraPomagala)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',4,'SifraPomagala','Sadrzi nedozvoljeni znak dvotocka',sVal)
    RetVal = FALSE
  END

  ! --- Polje 5: Kolicina (N(max5).N2, obavezno) ---
  sVal = CLIP(SELF.StavkaQ.Kolicina)
  IF sVal = ''
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',5,'Kolicina','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal) AND NOT SELF.ValidateNumeric(sVal,5)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',5,'Kolicina','Neispravan format kolicine (N.NN ili cijeli broj)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 6: Ukupni iznos (N(max9).N2, obavezno) ---
  sVal = CLIP(SELF.StavkaQ.UkupniIznos)
  IF sVal = ''
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',6,'UkupniIznos','Obavezan podatak',sVal)
    RetVal = FALSE
  ELSIF NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',6,'UkupniIznos','Neispravan format iznosa (N.NN)',sVal)
    RetVal = FALSE
  END

  ! --- Polje 7: Sifra proizvodjaca (N10, nije obavezno) ---
  sVal = CLIP(SELF.StavkaQ.SifraProizvodjaca)
  IF sVal <> '' AND NOT SELF.ValidateNumeric(sVal, 10)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',7,'SifraProizvodjaca','Mora biti numericki, max 10 znamenki',sVal)
    RetVal = FALSE
  END

  ! --- Polje 8: Broj potvrde doktora (N14, uvjetno, K Prilog 8) ---
  sVal = CLIP(SELF.StavkaQ.BrojPotvrdeDoktora)
  IF sVal <> ''
    IF LEN(CLIP(sVal)) <> 14
      SELF.AddError(nRacunIdx,pStavkaPtr,'61',8,'BrojPotvrdeDoktora','Mora biti tocno 14 znamenki',sVal)
      RetVal = FALSE
    ELSIF NOT SELF.CheckDigitPotvrdaDoktora(sVal)
      SELF.AddError(nRacunIdx,pStavkaPtr,'61',8,'BrojPotvrdeDoktora','Neispravna kontrolna znamenka (Prilog 8)',sVal)
      RetVal = FALSE
    END
  END

  ! --- Polje 9: Sifra velicine obloge (N4, uvjetno) ---
  sVal = CLIP(SELF.StavkaQ.SifraVelicineObloge)
  IF sVal <> '' AND NOT SELF.ValidateNumeric(sVal, 4)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',9,'SifraVelicineObloge','Mora biti numericki, max 4 znamenke',sVal)
    RetVal = FALSE
  END

  ! --- Polje 10: Identifikacija izdanog pomagala (ANS max 30) ---
  sVal = CLIP(SELF.StavkaQ.IdentifikacijaPomagala)
  IF sVal <> '' AND LEN(CLIP(sVal)) > 30
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',10,'IdentifikacijaPomagala','Maksimalno 30 znakova',sVal)
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.StavkaQ.IdentifikacijaPomagala)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',10,'IdentifikacijaPomagala','Sadrzi nedozvoljeni znak dvotocka',sVal)
    RetVal = FALSE
  END

  ! --- Polje 11: Identifikator ePotvrde (ANS max 100) ---
  sVal = CLIP(SELF.StavkaQ.IdentifikatorEPotvrde)
  IF sVal <> '' AND LEN(CLIP(sVal)) > 100
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',11,'IdentifikatorEPotvrde','Maksimalno 100 znakova',sVal)
    RetVal = FALSE
  END
  IF SELF.ContainsColon(SELF.StavkaQ.IdentifikatorEPotvrde)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',11,'IdentifikatorEPotvrde','Sadrzi nedozvoljeni znak dvotocka',sVal)
    RetVal = FALSE
  END

  ! --- Polje 12: Iznos razlike u cijeni (nije obavezno) ---
  sVal = CLIP(SELF.StavkaQ.IznosRazCijene)
  IF sVal <> '' AND NOT SELF.ValidateAmount(sVal)
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',12,'IznosRazCijene','Neispravan format iznosa (N.NN)',sVal)
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
    SELF.AddError(nRacunIdx,pStavkaPtr,'61',2,'Potvrda','Mora biti upisan barem jedan identifikator potvrde','')
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
    SELF.AddError(0,0,'',0,'Export','Greska pri kreiranju datoteke: ' & CLIP(pFileName),'')
    RETURN FALSE
  END
  ! Zapisi sve racune i njihove stavke
  LOOP I = 1 TO RECORDS(SELF.RacunQ)
    GET(SELF.RacunQ, I)
    nRacunIdx = SELF.RacunQ.RacunIndex
    ! Zapisi slog racuna (60)
    sLine = SELF.FormatRacunLine(I)
    IF NOT WriteLine(hFile, sLine)
      SELF.AddError(nRacunIdx,0,'60',0,'Export','Greska pri zapisu sloga 60','')
      RetVal = FALSE
      BREAK
    END
    ! Zapisi sve stavke za ovaj racun (61)
    LOOP J = 1 TO RECORDS(SELF.StavkaQ)
      GET(SELF.StavkaQ, J)
      IF SELF.StavkaQ.RacunIndex = nRacunIdx
        sLine = SELF.FormatStavkaLine(J)
        IF NOT WriteLine(hFile, sLine)
          SELF.AddError(nRacunIdx,J,'61',0,'Export','Greska pri zapisu sloga 61','')
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

!============================================================================
! DateToStr - Pretvori Clarion LONG datum u string format DD.MM.YYYY
!============================================================================
HZZOSpecClass.DateToStr PROCEDURE(LONG pDate)
sDD   STRING(2)
sMM   STRING(2)
sYYYY STRING(4)
  CODE
  IF NOT pDate
    RETURN '00.00.0000'
  END
  sDD   = FORMAT(DAY(pDate),   @N02)
  sMM   = FORMAT(MONTH(pDate), @N02)
  sYYYY = FORMAT(YEAR(pDate),  @N04)
  RETURN sDD & '.' & sMM & '.' & sYYYY

!============================================================================
! HZZOSpecClass.StrToDate
!
! Parsira string formata 'DD.MM.YYYY - HH:MM' i vraca Clarion datum (LONG).
! Vraca 0 ako su dan, mjesec ili godina 0 (neispravan format).
!
! Format: pozicije 1-2=DD, 4-5=MM, 7-10=YYYY
!============================================================================
HZZOSpecClass.StrToDate PROCEDURE(STRING pDatumVrijeme)
l:DD    LONG
l:MM    LONG
l:YYYY  LONG
  CODE
  l:DD   = DEFORMAT(SUB(pDatumVrijeme, 1, 2), @N02)
  l:MM   = DEFORMAT(SUB(pDatumVrijeme, 4, 2), @N02)
  l:YYYY = DEFORMAT(SUB(pDatumVrijeme, 7, 4), @N04)
  IF l:DD = 0 OR l:MM = 0 OR l:YYYY = 0 THEN RETURN 0.
  RETURN DATE(l:MM, l:DD, l:YYYY)

!============================================================================
! HZZOSpecClass.StrToTime
!
! Parsira string formata 'DD.MM.YYYY - HH:MM' i vraca Clarion vrijeme (LONG).
! Clarion vrijeme = centisekunde od ponoci (1 sat = 360000, 1 minuta = 6000).
! Vraca 0 ako su sati i minute oba 0 ili format nije prepoznat.
!
! Format: pozicije 14-15=HH, 17-18=MM
!============================================================================
HZZOSpecClass.StrToTime PROCEDURE(STRING pDatumVrijeme)
l:HH    LONG
l:MIN   LONG
  CODE
  l:HH  = DEFORMAT(SUB(pDatumVrijeme, 14, 2), @N02)
  l:MIN = DEFORMAT(SUB(pDatumVrijeme, 17, 2), @N02)
  RETURN l:HH * 360000 + l:MIN * 6000

!============================================================================
! HZZOSpecClass.NumToStr
!
! Formatira REAL broj u string s tocno 2 decimale, bez vodecih razmaka.
! Koristiti za punjenje STRING polja u queue-u (Kolicina, iznosi...).
!
! Primjeri:
!   NumToStr(320.2)  -> '320.20'
!   NumToStr(35)     -> '35.00'
!   NumToStr(0)      -> '0.00'
!   NumToStr(-5.5)   -> '-5.50'
!============================================================================
HZZOSpecClass.NumToStr PROCEDURE(REAL pValue)
l:Buf   STRING(20)
I       LONG
  CODE
  l:Buf = FORMAT(pValue, @n-12.2)
  LOOP I = 1 TO 20
    IF l:Buf[I] <> ' '
      RETURN CLIP(l:Buf[I : 20])
    END
  END
  RETURN '0.00'

!============================================================================
! HZZOSpecClass.Report
!
! Generira PDF racun za osnovno ili dopunsko zdravstveno osiguranje.
!
! Parametri:
!   pRacunIndex  LONG    RacunIndex zapisa u SELF.RacunQ koji se ispisuje
!   pVrsta       BYTE    1 = osnovno zdravstveno osiguranje
!                        2 = dopunsko zdravstveno osiguranje
!   pPdfPath     STRING  putanja do izlazne PDF datoteke ('' = print preview)
!
! Preduvjeti:
!   - SELF.RacunQ i SELF.StavkaQ moraju biti popunjeni
!   - Report-only polja: SifraMaloprodajneLokacije, AdresaIsporucitelja,
!     ZiroRacun, MaticniBroj, OIBIsporucitelja, PozivNaBroj, MjestoIzdavanja,
!     HZZOPodrucniUred, HZZOMjesto, HZZOUlicaBroj, HZZOOIB (u RacunQ)
!   - NazivPomagala, JedCijenaEur, StopaPDV, JedRazlikaEur (u StavkaQ)
!
! Razlika OS vs DOP:
!   Osnovno  (pVrsta=1) - 5 financijskih redaka, sakrivena 'Br. police' labela
!   Dopunsko (pVrsta=2) - 6 financijskih redaka, vidljiva polica,
!                         f5='5. Iznos na teret dopunskog...',
!                         f6='6. Iznos PDV-a u tocki 5.'
!
! PDF generiranje (Clarion 11):
!   SYSTEM{PROP:PrintMode} = 3 zahtijeva instaliran PDF driver.
!   Za print preview: proslijedi pPdfPath = '' (prazno).
!============================================================================
HZZOSpecClass.Report PROCEDURE(LONG pRacunIndex, BYTE pVrsta, STRING pPdfPath)

!--- Header varijable ---
l:RacunZa           STRING(80)
l:RacunBroj         STRING(60)
l:Oib               STRING(40)
l:PodrucniUred      STRING(80)
l:HZZOMjesto        STRING(60)
l:HZZOUlicaBroj     STRING(60)
l:SifraMalLok       STRING(10)
l:Naziv_Isp         STRING(80)
l:Adresa_Isp        STRING(80)
l:Ziro              STRING(50)
l:BrojPotvrde       STRING(110)
l:BrojPolice        STRING(50)
l:MaticniBrojOib    STRING(30)
l:MBOPacijenta      STRING(30)
l:PozivNaBroj       STRING(30)

!--- Tablica stavki ---
l:Br                LONG
l:Sifra             STRING(13)
l:NazivS            STRING(100)
l:Kolicina          DECIMAL(7,2)
l:JedCijena         DECIMAL(14,4)
l:StopaPDVa         DECIMAL(5,2)
l:Iznos             DECIMAL(11,2)
l:JedRazlika        DECIMAL(15,4)
l:UkRazlika         DECIMAL(11,2)
l:UkupnoIznos       DECIMAL(11,2)
l:UkupnoRazlika     DECIMAL(11,2)

!--- PDV tablica (max 2 stope) ---
l:Stopa1            STRING(5)
l:Osnovica1         DECIMAL(11,2)
l:PDVIznos1         DECIMAL(11,2)
l:Stopa2            STRING(5)
l:Osnovica2         DECIMAL(11,2)
l:PDVIznos2         DECIMAL(11,2)
l:StopaDec          DECIMAL(5,2)
l:OsnovicaI         DECIMAL(11,4)
l:PDVIznosI         DECIMAL(11,4)

!--- Financijski zbroji ---
l:UkIznosPomagala   DECIMAL(11,2)
l:IznosSudjelovanja DECIMAL(11,2)
l:IznosObvezno      DECIMAL(11,2)
l:IznosRazlike      DECIMAL(11,2)
l:IznosPDV5         DECIMAL(11,2)
l:f6_Iznos          DECIMAL(11,2)

!--- Labele financijskog sazetka ---
l:f1                STRING(80)
l:f2                STRING(80)
l:f3                STRING(80)
l:f4                STRING(80)
l:f5                STRING(80)
l:f6                STRING(80)

!--- Datumi ---
l:DatumNarudzbeStr  STRING(60)
l:DatumIzdavanjaStr STRING(60)
l:MjestoIDatum      STRING(90)

!--- Iterator ---
ii                 LONG

RacunRpt            REPORT,AT(11,115,189,149),PRE(RPT),|
                      PAPER(PAPER:A4),|
                      FONT('Arial',10,,FONT:regular,CHARSET:EASTEUROPE),MM

                      HEADER,AT(11,12,189,103),USE(?Header)
                        LINE,AT(0,0,189,0),USE(?HdrTop)
                        LINE,AT(0,103,189,0),USE(?HdrBot)
                        LINE,AT(0,0,0,103),USE(?HdrLeft)
                        LINE,AT(189,0,0,103),USE(?HdrRight)
                        STRING('Hrvatski zavod za zdravstveno osiguranje'),|
                          AT(26,7,68,5),USE(?HZZONaslov),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING(@s40),AT(26,14,63,5),USE(l:Oib),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s80),AT(26,20,63,5),USE(l:PodrucniUred),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s60),AT(26,26,63,5),USE(l:HZZOMjesto),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s60),AT(26,32,63,5),USE(l:HZZOUlicaBroj),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        LINE,AT(0,40,189,0),USE(?HdrSep)
                        STRING(@s60),AT(111,1,76,5),USE(l:RacunBroj),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),RIGHT(2)
                        TEXT,AT(130,8,56,15),USE(l:RacunZa),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING('I. IZDAVANJE POMAGALA, DIJELA POMAGALA'),|
                          AT(2,45,84,5),USE(?SekcijaI),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('(Ispunjava ugovorni isporucitelj)'),|
                          AT(87,45,42,5),USE(?SekcijaISub),|
                          FONT(,8,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING('Sifra maloprodajne lokacije:'),|
                          AT(2,55,44,5),USE(?LblSifraLok),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s10),AT(47,55,53,5),USE(l:SifraMalLok),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('Naziv:'),AT(2,64,15,5),USE(?LblNaziv),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s80),AT(19,64,60,5),USE(l:Naziv_Isp),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('Adresa (mjesto, ulica i broj):'),|
                          AT(2,73,46,5),USE(?LblAdresa),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        TEXT,AT(47,73,66,12),USE(l:Adresa_Isp),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('Broj ziro-racun:'),|
                          AT(2,88,27,5),USE(?LblZiro),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s50),AT(30,88,77,5),USE(l:Ziro),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('Broj potvrde / racuna:'),|
                          AT(133,45,35,5),USE(?LblBrojPotvrde),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s110),AT(71,51,115,5),USE(l:BrojPotvrde),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),RIGHT(2)
                        STRING('Br. police dop. zdr. osig. HZZO'),|
                          AT(133,59,52,5),USE(?SDOP),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s50),AT(133,65,51,5),USE(l:BrojPolice),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),CENTER
                        STRING('Maticni broj i OIB isporucitelja:'),|
                          AT(133,73,52,5),USE(?LblMaticni),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s30),AT(133,79,52,5),USE(l:MaticniBrojOib),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),CENTER
                        STRING(@s30),AT(133,85,52,4),USE(l:MBOPacijenta),|
                          FONT(,9,,FONT:regular,CHARSET:EASTEUROPE),CENTER
                        STRING('Poziv na broj:'),|
                          AT(148,91,26,5),USE(?LblPoziv),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s30),AT(133,97,52,5),USE(l:PozivNaBroj),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),CENTER
                      END  !HEADER

detailh               DETAIL,AT(0,0,189,10),USE(?DETAILH)
                        LINE,AT(0,0,189,0),USE(?DHTop)
                        LINE,AT(0,10,189,0),USE(?DHBot)
                        LINE,AT(0,0,0,10),USE(?DHLeft)
                        LINE,AT(189,0,0,10),USE(?DHRight)
                        LINE,AT(8,0,0,10),USE(?DHCol1)
                        LINE,AT(38,0,0,10),USE(?DHCol2)
                        LINE,AT(80,0,0,10),USE(?DHCol3)
                        LINE,AT(93,0,0,10),USE(?DHCol4)
                        LINE,AT(113,0,0,10),USE(?DHCol5)
                        LINE,AT(127,0,0,10),USE(?DHCol6)
                        LINE,AT(150,0,0,10),USE(?DHCol7)
                        LINE,AT(168,0,0,10),USE(?DHCol8)
                        STRING('R.'),AT(1,1,5,4),USE(?DHRbr1),FONT(,8,,,239)
                        STRING('br.'),AT(1,5,5,4),USE(?DHRbr2),FONT(,8,,,239)
                        STRING('Sifra pomagala'),AT(10,2,24,6),USE(?DHSifra),|
                          FONT(,8,,,239),CENTER
                        STRING('Naziv pomagala'),AT(40,2,26,6),USE(?DHNaziv),|
                          FONT(,8,,,239)
                        STRING('Kolicina'),AT(81,2,11,4),USE(?DHKolicina),|
                          FONT(,8,,,CHARSET:EASTEUROPE)
                        STRING('Jedinicna cijena'),AT(94,1,18,2),USE(?DHCijena1),|
                          FONT(,6,,,239),CENTER
                        STRING('u EUR s PDV-om'),AT(94,5,18,2),USE(?DHCijena2),|
                          FONT(,6,,,239),CENTER
                        STRING('Stopa'),AT(115,1,11,3),USE(?DHStopa1),|
                          FONT(,8,,,239)
                        STRING('PDV-a'),AT(115,5,11,3),USE(?DHStopa2),|
                          FONT(,8,,,239)
                        STRING('Ukupni iznos'),AT(128,1,21,4),USE(?DHUkupni1),|
                          FONT(,8,,,239)
                        STRING('u EUR s PDV-om'),AT(128,5,21,4),USE(?DHUkupni2),|
                          FONT(,7,,,239),CENTER
                        STRING('Jedinicna '),AT(152,1,12,2),USE(?DHJedRazl1),|
                          FONT(,6,,,CHARSET:EASTEUROPE)
                        STRING('razlika u cijeni'),AT(151,3,15,2),USE(?DHJedRazl2),|
                          FONT(,6,,,239)
                        STRING('u EUR s PDV-om'),AT(151,6,15,2),USE(?DHJedRazl3),|
                          FONT(,6,,,239)
                        STRING('Ukupni iznos'),AT(169,1,19,2),USE(?DHUkRazl1),|
                          FONT(,6,,,239),CENTER
                        STRING('razlike u EUR'),AT(169,4,19,2),USE(?DHUkRazl2),|
                          FONT(,6,,,239),CENTER
                        STRING('s PDV-om'),AT(169,7,19,2),USE(?DHUkRazl3),|
                          FONT(,6,,,239),CENTER
                      END  !detailh

Detail                DETAIL,AT(0,0,189,10),USE(?Detail)
                        STRING(@n-14),AT(1,2,6,5),USE(l:Br),RIGHT
                        STRING(@s13),AT(9,2,29,5),USE(l:Sifra),CENTER
                        TEXT,AT(39,1,37,9),USE(l:NazivS),FONT(,8)
                        STRING(@n-14.2),AT(75,2,16,5),USE(l:Kolicina),RIGHT
                        STRING(@n-13.4),AT(92,2,20,5),USE(l:JedCijena),RIGHT
                        STRING(@n5.2),AT(115,2,10,5),USE(l:StopaPDVa),RIGHT
                        STRING(@n-13.2),AT(127,2,20,5),USE(l:Iznos),RIGHT
                        STRING(@n-15.4),AT(147,2,20,5),USE(l:JedRazlika),RIGHT
                        STRING(@n-14.2),AT(168,2,19,5),USE(l:UkRazlika),RIGHT
                      END  !Detail

detailF               DETAIL,AT(0,0,189,85),USE(?DETAILF)
                        LINE,AT(0,0,189,0),USE(?DFTop)
                        BOX,AT(98,0,91,7),USE(?UkupnoBox),|
                          COLOR(COLOR:Black),FILL(COLOR:White),LINEWIDTH(0)
                        STRING('UKUPNO:'),AT(103,1,20,4),USE(?UkupnoLbl),|
                          FONT(,,,FONT:bold)
                        STRING(@n-14.2),AT(121,1,28,4),USE(l:UkupnoIznos),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-15.2),AT(158,1,28,4),USE(l:UkupnoRazlika),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@s80),AT(64,10,89,5),USE(l:f1),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(64,17,89,5),USE(l:f2),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(64,24,89,5),USE(l:f3),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(64,30,89,5),USE(l:f4),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(64,37,89,5),USE(l:f5),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(64,42,89,5),USE(l:f6),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@n-19.2),AT(159,10,28,5),USE(l:UkIznosPomagala),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-19.2),AT(159,17,28,5),USE(l:IznosSudjelovanja),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-19.2),AT(159,24,28,5),USE(l:IznosObvezno),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-15.2),AT(159,30,28,5),USE(l:IznosRazlike),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-19.2),AT(159,37,28,5),USE(l:IznosPDV5),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-15.2),AT(159,42,28,5),USE(l:f6_Iznos),|
                          FONT(,,,FONT:bold),RIGHT
                        BOX,AT(0,9,63,24),USE(?PDVBox),|
                          COLOR(COLOR:Black),FILL(COLOR:White),LINEWIDTH(0)
                        LINE,AT(0,16,62,0),USE(?PDVSep)
                        STRING('Stopa %'),AT(2,10,18,4),USE(?PDVLblStopa)
                        STRING('Osnovica'),AT(22,10,18,4),USE(?PDVLblOsn)
                        STRING('Iznos'),AT(46,10,12,4),USE(?PDVLblIznos)
                        STRING(@s5),AT(2,18,12,5),USE(l:Stopa1),LEFT
                        STRING(@n-14.2),AT(16,18,22,5),USE(l:Osnovica1),RIGHT
                        STRING(@n-13.2),AT(39,18,22,5),USE(l:PDVIznos1),RIGHT
                        STRING(@s5),AT(2,25,12,5),USE(l:Stopa2),LEFT
                        STRING(@n-13.2b),AT(16,25,22,5),USE(l:Osnovica2),RIGHT
                        STRING(@n-13.2b),AT(39,25,22,5),USE(l:PDVIznos2),RIGHT
                        STRING(@s80),AT(10,47,100,5),USE(l:DatumNarudzbeStr),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(10,53,100,5),USE(l:DatumIzdavanjaStr),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s90),AT(10,59,110,5),USE(l:MjestoIDatum),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        LINE,AT(14,73,51,0),USE(?PotpisL1)
                        LINE,AT(114,73,59,0),USE(?PotpisL2)
                        STRING('Potpis odgovorne osobe'),AT(20,75,45,4),|
                          USE(?LblPotpis1),FONT(,8)
                        STRING('M.P.'),AT(83,70,12,5),USE(?LblMP),FONT(,8)
                        STRING('Ime, prezime i potpis odgovorne osobe'),|
                          AT(114,75,70,4),USE(?LblPotpis2),FONT(,8)
                      END  !detailF

                      FOOTER,AT(6,264,201,29),USE(?Footer)
                        LINE,AT(0,0,201,0),USE(?FtrTop)
                        STRING(@s200),AT(1,4,197,4),USE(l:MjestoIDatum),|
                          FONT(,8,,,CHARSET:EASTEUROPE),CENTER
                        STRING('Ovaj racun je izdan na racunalu i punovaljan je bez potpisa i pecata.'),|
                          AT(10,22,175,4),USE(?FtrLegal),|
                          FONT(,8,,FONT:bold,CHARSET:EASTEUROPE)
                      END  !FOOTER

                    END  !RacunRpt

                    CODE

                    !--- 1. Dohvati racun iz queue-a po RacunIndex ---
                    LOOP ii = 1 TO RECORDS(SELF.RacunQ)
                      GET(SELF.RacunQ, ii)
                      IF SELF.RacunQ.RacunIndex = pRacunIndex THEN BREAK.
                    END
                    IF SELF.RacunQ.RacunIndex <> pRacunIndex THEN RETURN.

                    !--- 2. Header varijable ---
                    IF pVrsta = 1
                      l:RacunZa   = 'RACUN za obvezno zdravstveno osiguranje'
                      l:RacunBroj = 'Racun broj: ' & CLIP(SELF.RacunQ.BrojOsobnogRacuna)
                    ELSE
                      l:RacunZa   = 'RACUN za dopunsko zdravstveno osiguranje'
                      IF CLIP(SELF.RacunQ.BrojRacDopunsko) <> ''
                        l:RacunBroj = 'Racun broj: ' & CLIP(SELF.RacunQ.BrojRacDopunsko)
                      ELSE
                        l:RacunBroj = 'Racun broj: ' & CLIP(SELF.RacunQ.BrojOsobnogRacuna)
                      END
                    END

                    l:Oib           = 'OIB: '             & CLIP(SELF.RacunQ.HZZOOIB)
                    l:PodrucniUred  = 'Podrucni ured: '   & CLIP(SELF.RacunQ.HZZOPodrucniUred)
                    l:HZZOMjesto    = 'Mjesto: '          & CLIP(SELF.RacunQ.HZZOMjesto)
                    l:HZZOUlicaBroj = 'Ulica i broj: '   & CLIP(SELF.RacunQ.HZZOUlicaBroj)
                    l:SifraMalLok   = CLIP(SELF.RacunQ.SifraMaloprodajneLokacije)
                    l:Naziv_Isp     = CLIP(SELF.RacunQ.NazivIsporucitelja)
                    l:Adresa_Isp    = CLIP(SELF.RacunQ.AdresaIsporucitelja)
                    l:Ziro          = CLIP(SELF.RacunQ.ZiroRacun)
                    l:BrojPotvrde   = CLIP(SELF.RacunQ.IdentifikatorEPotvrde)
                    l:BrojPolice    = CLIP(SELF.RacunQ.BrojPolice)
                    l:MaticniBrojOib= CLIP(SELF.RacunQ.MaticniBroj) & ' ' & |
                                      CLIP(SELF.RacunQ.OIBIsporucitelja)
                    l:MBOPacijenta  = 'MBO Pacijenta: '  & CLIP(SELF.RacunQ.MBO)
                    l:PozivNaBroj   = CLIP(SELF.RacunQ.PozivNaBroj)

                    !--- 3. Datumi ---
                    l:DatumNarudzbeStr  = 'Datum narudzbe: ' & |
                                          CLIP(SELF.RacunQ.DatumNarudzbe)
                    l:DatumIzdavanjaStr = 'Datum izdavanja pomagala: ' & |
                                          CLIP(SELF.RacunQ.DatumObracuna)
                    l:MjestoIDatum      = 'Mjesto i datum izdavanja racuna: ' & |
                                          CLIP(SELF.RacunQ.MjestoIzdavanja) & ', ' & |
                                          CLIP(SELF.RacunQ.DatumIzdavanja)

                    !--- 4. Labele financijskog sazetka ---
                    l:f1 = '1. Ukupan iznos (s PDV-om):'
                    l:f2 = '2. Iznos sudjelovanja:'
                    l:f3 = '3. Iznos na teret obveznog zdravstvenog osiguranja:'
                    l:f4 = '4. Iznos razlike u cijeni'
                    IF pVrsta = 1
                      l:f5 = '5. Iznos obracunatog PDV-a u tocki 3.'
                      l:f6 = ''
                    ELSE
                      l:f5 = '5. Iznos na teret dopunskog zdravstvenog osiguranja'
                      l:f6 = '6. Iznos obracunatog PDV-a u tocki 5.'
                    END

                    !--- 5. Financijski iznosi iz RacunQ ---
                    l:UkIznosPomagala   = SELF.RacunQ.UkIznosPomagala
                    l:IznosSudjelovanja = SELF.RacunQ.IznosSudjelovanja
                    l:IznosObvezno      = SELF.RacunQ.IznosObveznoSPDV
                    l:IznosRazlike      = SELF.RacunQ.UkIznosRazCijene
                    IF pVrsta = 1
                      l:IznosPDV5 = SELF.RacunQ.IznosPDVObvezno
                      l:f6_Iznos  = 0
                    ELSE
                      l:IznosPDV5 = SELF.RacunQ.IznosDopunskoSPDV
                      l:f6_Iznos  = SELF.RacunQ.IznosPDVDopunsko
                    END

                    !--- 6. Otvori report ---
                    IF CLIP(pPdfPath) <> ''
                      SYSTEM{PROP:PrintMode} = 3
                    END
                    OPEN(RacunRpt)
                    RacunRpt{PROP:Extend} = TRUE

                    !--- 7. Sakrij/prikazi elemente ovisno o vrsti ---
                    IF pVrsta = 1
                      RacunRpt$?SDOP{PROP:Hide}         = TRUE
                      RacunRpt$?l:BrojPolice{PROP:Hide} = TRUE
                      RacunRpt$?l:f6{PROP:Hide}         = TRUE
                      RacunRpt$?l:f6_Iznos{PROP:Hide}   = TRUE
                    ELSE
                      RacunRpt$?SDOP{PROP:Hide}         = FALSE
                      RacunRpt$?l:BrojPolice{PROP:Hide} = FALSE
                      RacunRpt$?l:f6{PROP:Hide}         = FALSE
                      RacunRpt$?l:f6_Iznos{PROP:Hide}   = FALSE
                    END

                    !--- 8. Zaglavlje tablice ---
                    PRINT(RPT:detailh)

                    !--- 9. Petlja kroz stavke ---
                    l:Br            = 0
                    l:UkupnoIznos   = 0
                    l:UkupnoRazlika = 0
                    CLEAR(l:Stopa1)  ;  CLEAR(l:Stopa2)
                    l:Osnovica1 = 0  ;  l:PDVIznos1 = 0
                    l:Osnovica2 = 0  ;  l:PDVIznos2 = 0

                    LOOP ii = 1 TO RECORDS(SELF.StavkaQ)
                      GET(SELF.StavkaQ, ii)
                      IF SELF.StavkaQ.RacunIndex <> pRacunIndex THEN CYCLE.

                      l:Br         += 1
                      l:Sifra       = CLIP(SELF.StavkaQ.SifraPomagala)
                      l:NazivS      = CLIP(SELF.StavkaQ.NazivPomagala)
                      l:Kolicina    = SELF.StavkaQ.Kolicina
                      l:JedCijena   = SELF.StavkaQ.JedCijenaEur
                      l:StopaPDVa   = SELF.StavkaQ.StopaPDV
                      l:Iznos       = SELF.StavkaQ.UkupniIznos
                      l:JedRazlika  = SELF.StavkaQ.JedRazlikaEur
                      IF l:JedRazlika < 0 THEN l:JedRazlika = 0.
                      l:UkRazlika   = l:JedRazlika * l:Kolicina

                      l:UkupnoIznos   += l:Iznos
                      l:UkupnoRazlika += l:UkRazlika

                      !--- PDV grupiranje ---
                      l:StopaDec = l:StopaPDVa
                      IF l:StopaDec > 0
                        l:OsnovicaI = l:Iznos / (1 + l:StopaDec / 100)
                        l:PDVIznosI = l:Iznos - l:OsnovicaI
                        IF CLIP(l:Stopa1) = ''
                          l:Stopa1    = CLIP(SELF.StavkaQ.StopaPDV)
                          l:Osnovica1 += l:OsnovicaI
                          l:PDVIznos1 += l:PDVIznosI
                        ELSIF CLIP(SELF.StavkaQ.StopaPDV) = CLIP(l:Stopa1)
                          l:Osnovica1 += l:OsnovicaI
                          l:PDVIznos1 += l:PDVIznosI
                        ELSIF CLIP(l:Stopa2) = ''
                          l:Stopa2    = CLIP(SELF.StavkaQ.StopaPDV)
                          l:Osnovica2 += l:OsnovicaI
                          l:PDVIznos2 += l:PDVIznosI
                        ELSIF CLIP(SELF.StavkaQ.StopaPDV) = CLIP(l:Stopa2)
                          l:Osnovica2 += l:OsnovicaI
                          l:PDVIznos2 += l:PDVIznosI
                        END
                      END

                      PRINT(RPT:Detail)
                    END

                    !--- 10. Footer i kraj ---
                    PRINT(RPT:detailF)
                    ENDPAGE(RacunRpt)
                    CLOSE(RacunRpt)

!============================================================================
! HZZOSpecClass.ReportAll
!
! Generira sve racune iz RacunQ u jedan PDF (jedna datoteka, vise stranica).
!
! Za svaki racun:
!   - uvijek generira stranicu za osnovno zdravstveno osiguranje (pVrsta=1)
!   - generira stranicu za dopunsko (pVrsta=2) samo ako je
!     RacunQ.TipOsiguranja = HZZO:TipD1
!
! Redoslijed stranica: os1, dop1, os2, dop2, os3, ...
!
! Preduvjeti: isti kao Report() - RacunQ i StavkaQ moraju biti popunjeni
!             ukljucujuci report-only polja i TipOsiguranja.
!============================================================================
HZZOSpecClass.ReportAll PROCEDURE(STRING pPdfPath)

!--- PDF pipeline ---
lPDFReporter    I2PDFReportGenerator
lWMFParser      WMFDocumentParser
lPreviewQueue   PrintPreviewFileQueue

!--- Header varijable ---
l:RacunZa           STRING(80)
l:RacunBroj         STRING(60)
l:Oib               STRING(40)
l:PodrucniUred      STRING(80)
l:HZZOMjesto        STRING(60)
l:HZZOUlicaBroj     STRING(60)
l:SifraMalLok       STRING(10)
l:Naziv_Isp         STRING(80)
l:Adresa_Isp        STRING(80)
l:Ziro              STRING(50)
l:BrojPotvrde       STRING(110)
l:BrojPolice        STRING(50)
l:MaticniBrojOib    STRING(30)
l:MBOPacijenta      STRING(30)
l:PozivNaBroj       STRING(30)

!--- Tablica stavki ---
l:Br                LONG
l:Sifra             STRING(13)
l:NazivS            STRING(100)
l:Kolicina          DECIMAL(7,2)
l:JedCijena         DECIMAL(14,4)
l:StopaPDVa         DECIMAL(5,2)
l:Iznos             DECIMAL(11,2)
l:JedRazlika        DECIMAL(15,4)
l:UkRazlika         DECIMAL(11,2)
l:UkupnoIznos       DECIMAL(11,2)
l:UkupnoRazlika     DECIMAL(11,2)

!--- PDV tablica (max 2 stope) ---
l:Stopa1            STRING(5)
l:Osnovica1         DECIMAL(11,2)
l:PDVIznos1         DECIMAL(11,2)
l:Stopa2            STRING(5)
l:Osnovica2         DECIMAL(11,2)
l:PDVIznos2         DECIMAL(11,2)
l:StopaDec          DECIMAL(5,2)
l:OsnovicaI         DECIMAL(11,4)
l:PDVIznosI         DECIMAL(11,4)

!--- Financijski zbroji ---
l:UkIznosPomagala   DECIMAL(11,2)
l:IznosSudjelovanja DECIMAL(11,2)
l:IznosObvezno      DECIMAL(11,2)
l:IznosRazlike      DECIMAL(11,2)
l:IznosPDV5         DECIMAL(11,2)
l:f6_Iznos          DECIMAL(11,2)

!--- Labele financijskog sazetka ---
l:f1                STRING(80)
l:f2                STRING(80)
l:f3                STRING(80)
l:f4                STRING(80)
l:f5                STRING(80)
l:f6                STRING(80)

!--- Datumi ---
l:DatumNarudzbeStr  STRING(60)
l:DatumIzdavanjaStr STRING(60)
l:MjestoIDatum      STRING(90)

!--- Iteratori ---
rr                  LONG        ! index kroz RacunQ
ii                  LONG        ! index kroz StavkaQ
lVrsta              BYTE        ! 1=osnovno, 2=dopunsko
lMaxVrsta           BYTE        ! 1 ili 2 ovisno o TipOsiguranja

RacunRpt            REPORT,AT(11,115,189,149),PRE(RPT),|
                      PAPER(PAPER:A4),|
                      FONT('Arial',10,,FONT:regular,CHARSET:EASTEUROPE),MM

                      HEADER,AT(11,12,189,103),USE(?Header)
                        LINE,AT(0,0,189,0),USE(?HdrTop)
                        LINE,AT(0,103,189,0),USE(?HdrBot)
                        LINE,AT(0,0,0,103),USE(?HdrLeft)
                        LINE,AT(189,0,0,103),USE(?HdrRight)
                        STRING('Hrvatski zavod za zdravstveno osiguranje'),|
                          AT(26,7,68,5),USE(?HZZONaslov),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING(@s40),AT(26,14,63,5),USE(l:Oib),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s80),AT(26,20,63,5),USE(l:PodrucniUred),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s60),AT(26,26,63,5),USE(l:HZZOMjesto),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s60),AT(26,32,63,5),USE(l:HZZOUlicaBroj),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        LINE,AT(0,40,189,0),USE(?HdrSep)
                        STRING(@s60),AT(111,1,76,5),USE(l:RacunBroj),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),RIGHT(2)
                        TEXT,AT(130,8,56,15),USE(l:RacunZa),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING('I. IZDAVANJE POMAGALA, DIJELA POMAGALA'),|
                          AT(2,45,84,5),USE(?SekcijaI),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('(Ispunjava ugovorni isporucitelj)'),|
                          AT(87,45,42,5),USE(?SekcijaISub),|
                          FONT(,8,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING('Sifra maloprodajne lokacije:'),|
                          AT(2,55,44,5),USE(?LblSifraLok),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s10),AT(47,55,53,5),USE(l:SifraMalLok),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('Naziv:'),AT(2,64,15,5),USE(?LblNaziv),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s80),AT(19,64,60,5),USE(l:Naziv_Isp),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('Adresa (mjesto, ulica i broj):'),|
                          AT(2,73,46,5),USE(?LblAdresa),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        TEXT,AT(47,73,66,12),USE(l:Adresa_Isp),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('Broj ziro-racun:'),|
                          AT(2,88,27,5),USE(?LblZiro),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s50),AT(30,88,77,5),USE(l:Ziro),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('Broj potvrde / racuna:'),|
                          AT(133,45,35,5),USE(?LblBrojPotvrde),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s110),AT(71,51,115,5),USE(l:BrojPotvrde),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),RIGHT(2)
                        STRING('Br. police dop. zdr. osig. HZZO'),|
                          AT(133,59,52,5),USE(?SDOP),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s50),AT(133,65,51,5),USE(l:BrojPolice),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),CENTER
                        STRING('Maticni broj i OIB isporucitelja:'),|
                          AT(133,73,52,5),USE(?LblMaticni),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s30),AT(133,79,52,5),USE(l:MaticniBrojOib),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),CENTER
                        STRING(@s30),AT(133,85,52,4),USE(l:MBOPacijenta),|
                          FONT(,9,,FONT:regular,CHARSET:EASTEUROPE),CENTER
                        STRING('Poziv na broj:'),|
                          AT(148,91,26,5),USE(?LblPoziv),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s30),AT(133,97,52,5),USE(l:PozivNaBroj),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),CENTER
                      END  !HEADER

detailh               DETAIL,AT(0,0,189,10),USE(?DETAILH)
                        LINE,AT(0,0,189,0),USE(?DHTop)
                        LINE,AT(0,10,189,0),USE(?DHBot)
                        LINE,AT(0,0,0,10),USE(?DHLeft)
                        LINE,AT(189,0,0,10),USE(?DHRight)
                        LINE,AT(8,0,0,10),USE(?DHCol1)
                        LINE,AT(38,0,0,10),USE(?DHCol2)
                        LINE,AT(80,0,0,10),USE(?DHCol3)
                        LINE,AT(93,0,0,10),USE(?DHCol4)
                        LINE,AT(113,0,0,10),USE(?DHCol5)
                        LINE,AT(127,0,0,10),USE(?DHCol6)
                        LINE,AT(150,0,0,10),USE(?DHCol7)
                        LINE,AT(168,0,0,10),USE(?DHCol8)
                        STRING('R.'),AT(1,1,5,4),USE(?DHRbr1),FONT(,8,,,239)
                        STRING('br.'),AT(1,5,5,4),USE(?DHRbr2),FONT(,8,,,239)
                        STRING('Sifra pomagala'),AT(10,2,24,6),USE(?DHSifra),|
                          FONT(,8,,,239),CENTER
                        STRING('Naziv pomagala'),AT(40,2,26,6),USE(?DHNaziv),|
                          FONT(,8,,,239)
                        STRING('Kolicina'),AT(81,2,11,4),USE(?DHKolicina),|
                          FONT(,8,,,CHARSET:EASTEUROPE)
                        STRING('Jedinicna cijena'),AT(94,1,18,2),USE(?DHCijena1),|
                          FONT(,6,,,239),CENTER
                        STRING('u EUR s PDV-om'),AT(94,5,18,2),USE(?DHCijena2),|
                          FONT(,6,,,239),CENTER
                        STRING('Stopa'),AT(115,1,11,3),USE(?DHStopa1),|
                          FONT(,8,,,239)
                        STRING('PDV-a'),AT(115,5,11,3),USE(?DHStopa2),|
                          FONT(,8,,,239)
                        STRING('Ukupni iznos'),AT(128,1,21,4),USE(?DHUkupni1),|
                          FONT(,8,,,239)
                        STRING('u EUR s PDV-om'),AT(128,5,21,4),USE(?DHUkupni2),|
                          FONT(,7,,,239),CENTER
                        STRING('Jedinicna '),AT(152,1,12,2),USE(?DHJedRazl1),|
                          FONT(,6,,,CHARSET:EASTEUROPE)
                        STRING('razlika u cijeni'),AT(151,3,15,2),USE(?DHJedRazl2),|
                          FONT(,6,,,239)
                        STRING('u EUR s PDV-om'),AT(151,6,15,2),USE(?DHJedRazl3),|
                          FONT(,6,,,239)
                        STRING('Ukupni iznos'),AT(169,1,19,2),USE(?DHUkRazl1),|
                          FONT(,6,,,239),CENTER
                        STRING('razlike u EUR'),AT(169,4,19,2),USE(?DHUkRazl2),|
                          FONT(,6,,,239),CENTER
                        STRING('s PDV-om'),AT(169,7,19,2),USE(?DHUkRazl3),|
                          FONT(,6,,,239),CENTER
                      END  !detailh

Detail                DETAIL,AT(0,0,189,10),USE(?Detail)
                        STRING(@n-14),AT(1,2,6,5),USE(l:Br),RIGHT
                        STRING(@s13),AT(9,2,29,5),USE(l:Sifra),CENTER
                        TEXT,AT(39,1,37,9),USE(l:NazivS),FONT(,8)
                        STRING(@n-14.2),AT(75,2,16,5),USE(l:Kolicina),RIGHT
                        STRING(@n-13.4),AT(92,2,20,5),USE(l:JedCijena),RIGHT
                        STRING(@n5.2),AT(115,2,10,5),USE(l:StopaPDVa),RIGHT
                        STRING(@n-13.2),AT(127,2,20,5),USE(l:Iznos),RIGHT
                        STRING(@n-15.4),AT(147,2,20,5),USE(l:JedRazlika),RIGHT
                        STRING(@n-14.2),AT(168,2,19,5),USE(l:UkRazlika),RIGHT
                      END  !Detail

detailF               DETAIL,AT(0,0,189,85),USE(?DETAILF)
                        LINE,AT(0,0,189,0),USE(?DFTop)
                        BOX,AT(98,0,91,7),USE(?UkupnoBox),|
                          COLOR(COLOR:Black),FILL(COLOR:White),LINEWIDTH(0)
                        STRING('UKUPNO:'),AT(103,1,20,4),USE(?UkupnoLbl),|
                          FONT(,,,FONT:bold)
                        STRING(@n-14.2),AT(121,1,28,4),USE(l:UkupnoIznos),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-15.2),AT(158,1,28,4),USE(l:UkupnoRazlika),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@s80),AT(64,10,89,5),USE(l:f1),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(64,17,89,5),USE(l:f2),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(64,24,89,5),USE(l:f3),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(64,30,89,5),USE(l:f4),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(64,37,89,5),USE(l:f5),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(64,42,89,5),USE(l:f6),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@n-19.2),AT(159,10,28,5),USE(l:UkIznosPomagala),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-19.2),AT(159,17,28,5),USE(l:IznosSudjelovanja),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-19.2),AT(159,24,28,5),USE(l:IznosObvezno),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-15.2),AT(159,30,28,5),USE(l:IznosRazlike),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-19.2),AT(159,37,28,5),USE(l:IznosPDV5),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-15.2),AT(159,42,28,5),USE(l:f6_Iznos),|
                          FONT(,,,FONT:bold),RIGHT
                        BOX,AT(0,9,63,24),USE(?PDVBox),|
                          COLOR(COLOR:Black),FILL(COLOR:White),LINEWIDTH(0)
                        LINE,AT(0,16,62,0),USE(?PDVSep)
                        STRING('Stopa %'),AT(2,10,18,4),USE(?PDVLblStopa)
                        STRING('Osnovica'),AT(22,10,18,4),USE(?PDVLblOsn)
                        STRING('Iznos'),AT(46,10,12,4),USE(?PDVLblIznos)
                        STRING(@s5),AT(2,18,12,5),USE(l:Stopa1),LEFT
                        STRING(@n-14.2),AT(16,18,22,5),USE(l:Osnovica1),RIGHT
                        STRING(@n-13.2),AT(39,18,22,5),USE(l:PDVIznos1),RIGHT
                        STRING(@s5),AT(2,25,12,5),USE(l:Stopa2),LEFT
                        STRING(@n-13.2b),AT(16,25,22,5),USE(l:Osnovica2),RIGHT
                        STRING(@n-13.2b),AT(39,25,22,5),USE(l:PDVIznos2),RIGHT
                        STRING(@s80),AT(10,47,100,5),USE(l:DatumNarudzbeStr),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(10,53,100,5),USE(l:DatumIzdavanjaStr),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s90),AT(10,59,110,5),USE(l:MjestoIDatum),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        LINE,AT(14,73,51,0),USE(?PotpisL1)
                        LINE,AT(114,73,59,0),USE(?PotpisL2)
                        STRING('Potpis odgovorne osobe'),AT(20,75,45,4),|
                          USE(?LblPotpis1),FONT(,8)
                        STRING('M.P.'),AT(83,70,12,5),USE(?LblMP),FONT(,8)
                        STRING('Ime, prezime i potpis odgovorne osobe'),|
                          AT(114,75,70,4),USE(?LblPotpis2),FONT(,8)
                      END  !detailF

                      FOOTER,AT(6,264,201,29),USE(?Footer)
                        LINE,AT(0,0,201,0),USE(?FtrTop)
                        STRING(@s200),AT(1,4,197,4),USE(l:MjestoIDatum),|
                          FONT(,8,,,CHARSET:EASTEUROPE),CENTER
                        STRING('Ovaj racun je izdan na racunalu i punovaljan je bez potpisa i pecata.'),|
                          AT(10,22,175,4),USE(?FtrLegal),|
                          FONT(,8,,FONT:bold,CHARSET:EASTEUROPE)
                      END  !FOOTER

                    END  !RacunRpt

                    CODE

                    !--- 1. Otvori report jednom za sve racune ---
                    IF CLIP(pPdfPath) <> ''
                      SYSTEM{PROP:PrintMode} = 3   ! PDF pipeline - bez print dialoga
                    END
                    OPEN(RacunRpt)
                    RacunRpt{PROP:Extend} = TRUE
                    IF CLIP(pPdfPath) <> ''
                      RacunRpt{PROP:Preview} = lPreviewQueue.Filename  ! NAKON OPEN: runtime auto-puni queue za svaku stranicu
                    END

                    !--- 2. Petlja kroz sve racune ---
                    LOOP rr = 1 TO RECORDS(SELF.RacunQ)
                      GET(SELF.RacunQ, rr)

                      !--- Koliko vrsta za ovaj racun? ---
                      IF CLIP(SELF.RacunQ.TipOsiguranja) = 'D1'
                        lMaxVrsta = 2        ! osnovno + dopunsko
                      ELSE
                        lMaxVrsta = 1        ! samo osnovno
                      END

                      !--- Petlja: 1=osnovno, 2=dopunsko (ako D1) ---
                      LOOP lVrsta = 1 TO lMaxVrsta

                        !--- 3. Header varijable ---
                        IF lVrsta = 1
                          l:RacunZa   = 'RACUN za obvezno zdravstveno osiguranje'
                          l:RacunBroj = 'Racun broj: ' & CLIP(SELF.RacunQ.BrojOsobnogRacuna)
                        ELSE
                          l:RacunZa   = 'RACUN za dopunsko zdravstveno osiguranje'
                          IF CLIP(SELF.RacunQ.BrojRacDopunsko) <> ''
                            l:RacunBroj = 'Racun broj: ' & CLIP(SELF.RacunQ.BrojRacDopunsko)
                          ELSE
                            l:RacunBroj = 'Racun broj: ' & CLIP(SELF.RacunQ.BrojOsobnogRacuna)
                          END
                        END

                        l:Oib           = 'OIB: '           & CLIP(SELF.RacunQ.HZZOOIB)
                        l:PodrucniUred  = 'Podrucni ured: ' & CLIP(SELF.RacunQ.HZZOPodrucniUred)
                        l:HZZOMjesto    = 'Mjesto: '        & CLIP(SELF.RacunQ.HZZOMjesto)
                        l:HZZOUlicaBroj = 'Ulica i broj: ' & CLIP(SELF.RacunQ.HZZOUlicaBroj)
                        l:SifraMalLok   = CLIP(SELF.RacunQ.SifraMaloprodajneLokacije)
                        l:Naziv_Isp     = CLIP(SELF.RacunQ.NazivIsporucitelja)
                        l:Adresa_Isp    = CLIP(SELF.RacunQ.AdresaIsporucitelja)
                        l:Ziro          = CLIP(SELF.RacunQ.ZiroRacun)
                        l:BrojPotvrde   = CLIP(SELF.RacunQ.IdentifikatorEPotvrde)
                        l:BrojPolice    = CLIP(SELF.RacunQ.BrojPolice)
                        l:MaticniBrojOib= CLIP(SELF.RacunQ.MaticniBroj) & ' ' & |
                                          CLIP(SELF.RacunQ.OIBIsporucitelja)
                        l:MBOPacijenta  = 'MBO Pacijenta: ' & CLIP(SELF.RacunQ.MBO)
                        l:PozivNaBroj   = CLIP(SELF.RacunQ.PozivNaBroj)

                        !--- 4. Datumi ---
                        l:DatumNarudzbeStr  = 'Datum narudzbe: ' & |
                                              CLIP(SELF.RacunQ.DatumNarudzbe)
                        l:DatumIzdavanjaStr = 'Datum izdavanja pomagala: ' & |
                                              CLIP(SELF.RacunQ.DatumObracuna)
                        l:MjestoIDatum      = 'Mjesto i datum izdavanja racuna: ' & |
                                              CLIP(SELF.RacunQ.MjestoIzdavanja) & ', ' & |
                                              CLIP(SELF.RacunQ.DatumIzdavanja)

                        !--- 5. Labele financijskog sazetka ---
                        l:f1 = '1. Ukupan iznos (s PDV-om):'
                        l:f2 = '2. Iznos sudjelovanja:'
                        l:f3 = '3. Iznos na teret obveznog zdravstvenog osiguranja:'
                        l:f4 = '4. Iznos razlike u cijeni'
                        IF lVrsta = 1
                          l:f5 = '5. Iznos obracunatog PDV-a u tocki 3.'
                          l:f6 = ''
                        ELSE
                          l:f5 = '5. Iznos na teret dopunskog zdravstvenog osiguranja'
                          l:f6 = '6. Iznos obracunatog PDV-a u tocki 5.'
                        END

                        !--- 6. Financijski iznosi ---
                        l:UkIznosPomagala   = SELF.RacunQ.UkIznosPomagala
                        l:IznosSudjelovanja = SELF.RacunQ.IznosSudjelovanja
                        l:IznosObvezno      = SELF.RacunQ.IznosObveznoSPDV
                        l:IznosRazlike      = SELF.RacunQ.UkIznosRazCijene
                        IF lVrsta = 1
                          l:IznosPDV5 = SELF.RacunQ.IznosPDVObvezno
                          l:f6_Iznos  = 0
                        ELSE
                          l:IznosPDV5 = SELF.RacunQ.IznosDopunskoSPDV
                          l:f6_Iznos  = SELF.RacunQ.IznosPDVDopunsko
                        END

                        !--- 7. Sakrij/prikazi ovisno o vrsti ---
                        IF lVrsta = 1
                          RacunRpt$?SDOP{PROP:Hide}         = TRUE
                          RacunRpt$?l:BrojPolice{PROP:Hide} = TRUE
                          RacunRpt$?l:f6{PROP:Hide}         = TRUE
                          RacunRpt$?l:f6_Iznos{PROP:Hide}   = TRUE
                        ELSE
                          RacunRpt$?SDOP{PROP:Hide}         = FALSE
                          RacunRpt$?l:BrojPolice{PROP:Hide} = FALSE
                          RacunRpt$?l:f6{PROP:Hide}         = FALSE
                          RacunRpt$?l:f6_Iznos{PROP:Hide}   = FALSE
                        END

                        !--- 8. Zaglavlje tablice ---
                        PRINT(RPT:detailh)

                        !--- 9. Stavke za ovaj racun ---
                        l:Br            = 0
                        l:UkupnoIznos   = 0
                        l:UkupnoRazlika = 0
                        CLEAR(l:Stopa1)  ;  CLEAR(l:Stopa2)
                        l:Osnovica1 = 0  ;  l:PDVIznos1 = 0
                        l:Osnovica2 = 0  ;  l:PDVIznos2 = 0

                        LOOP ii = 1 TO RECORDS(SELF.StavkaQ)
                          GET(SELF.StavkaQ, ii)
                          IF SELF.StavkaQ.RacunIndex <> SELF.RacunQ.RacunIndex THEN CYCLE.

                          l:Br         += 1
                          l:Sifra       = CLIP(SELF.StavkaQ.SifraPomagala)
                          l:NazivS      = CLIP(SELF.StavkaQ.NazivPomagala)
                          l:Kolicina    = SELF.StavkaQ.Kolicina
                          l:JedCijena   = SELF.StavkaQ.JedCijenaEur
                          l:StopaPDVa   = SELF.StavkaQ.StopaPDV
                          l:Iznos       = SELF.StavkaQ.UkupniIznos
                          l:JedRazlika  = SELF.StavkaQ.JedRazlikaEur
                          IF l:JedRazlika < 0 THEN l:JedRazlika = 0.
                          l:UkRazlika   = l:JedRazlika * l:Kolicina

                          l:UkupnoIznos   += l:Iznos
                          l:UkupnoRazlika += l:UkRazlika

                          l:StopaDec = l:StopaPDVa
                          IF l:StopaDec > 0
                            l:OsnovicaI = l:Iznos / (1 + l:StopaDec / 100)
                            l:PDVIznosI = l:Iznos - l:OsnovicaI
                            IF CLIP(l:Stopa1) = ''
                              l:Stopa1    = CLIP(SELF.StavkaQ.StopaPDV)
                              l:Osnovica1 += l:OsnovicaI
                              l:PDVIznos1 += l:PDVIznosI
                            ELSIF CLIP(SELF.StavkaQ.StopaPDV) = CLIP(l:Stopa1)
                              l:Osnovica1 += l:OsnovicaI
                              l:PDVIznos1 += l:PDVIznosI
                            ELSIF CLIP(l:Stopa2) = ''
                              l:Stopa2    = CLIP(SELF.StavkaQ.StopaPDV)
                              l:Osnovica2 += l:OsnovicaI
                              l:PDVIznos2 += l:PDVIznosI
                            ELSIF CLIP(SELF.StavkaQ.StopaPDV) = CLIP(l:Stopa2)
                              l:Osnovica2 += l:OsnovicaI
                              l:PDVIznos2 += l:PDVIznosI
                            END
                          END

                          PRINT(RPT:Detail)
                        END

                        !--- 10. Footer, nova stranica ---
                        PRINT(RPT:detailF)
                        ENDPAGE(RacunRpt)

                      END  !LOOP lVrsta

                    END  !LOOP rr

                    !--- Konvertiraj WMF preview u PDF PRIJE CLOSE (WMF temp fileovi jos postoje) ---
                    IF CLIP(pPdfPath) <> ''
                      lPDFReporter.SetFileName(CLIP(pPdfPath))   ! postavi filename PRIJE AskProperties
                      IF lPDFReporter.IReportGenerator.AskProperties(FALSE) = Level:Benign
                        lWMFParser.Init(lPreviewQueue, lPDFReporter.IReportGenerator)
                        lWMFParser.GenerateReport(FALSE)
                      END
                    END

                    CLOSE(RacunRpt)

