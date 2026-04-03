!============================================================================
! HZZOCalc.CLW - Implementacija HZZOCalcClass
! MEMBER() modul - dodati u cwproj kao: <Compile Include="HZZOCalc.CLW" />
!============================================================================
  MEMBER()

  INCLUDE('HZZOCalc.INC'),ONCE

  MAP
  END

!============================================================
! HZZOCalcClass.Init
! Postavi defaultne konstante za 2025/2026
!============================================================
HZZOCalcClass.Init          PROCEDURE()
  CODE
  SELF.MinParticipacija   = 8.83
  SELF.MaxParticipacija   = 530.88
  SELF.StopaParticipacije = 0.2000
  SELF.MaxIznosFact       = 2654.40    ! = 530.88 / 0.20

!============================================================
! HZZOCalcClass.Kill
!============================================================
HZZOCalcClass.Kill          PROCEDURE()
  CODE
  ! Nema dinamickih resursa za osloboditi

!============================================================
! HZZOCalcClass.SetKonstante
! Postavi prilagodene konstante (npr. kada se promijeni proracunska osnovica)
! MaxIznosFact se izracuna automatski: pMax / pStopa
!============================================================
HZZOCalcClass.SetKonstante  PROCEDURE(REAL pMin, REAL pMax, REAL pStopa)
  CODE
  IF pMin > 0   THEN SELF.MinParticipacija   = pMin.
  IF pMax > 0   THEN SELF.MaxParticipacija   = pMax.
  IF pStopa > 0
    SELF.StopaParticipacije = pStopa
    SELF.MaxIznosFact       = ROUND(pMax / pStopa, .01)
  END

!============================================================
! HZZOCalcClass.FormatAmount (PRIVATE)
! DECIMAL -> STRING N.NN bez vodecih razmaka (npr. 244.71 -> '244.71')
! Koristi: FORMAT(@N14.2) pa trazi prvu ne-space poziciju
!============================================================
HZZOCalcClass.FormatAmount  PROCEDURE(REAL pVal)
l:s  STRING(14)
l:i  LONG
  CODE
  l:s = FORMAT(pVal, @N14.2)
  LOOP l:i = 1 TO 14
    IF SUB(l:s, l:i, 1) <> ' '
      RETURN SUB(l:s, l:i, 14 - l:i + 1)
    END
  END
  RETURN '0.00'

!============================================================
! HZZOCalcClass.FormatAmountCond (PRIVATE)
! Kao FormatAmount, ali za uvjetna polja: vraca '' kada je vrijednost 0
! (HZZO spec: uvjetna polja trebaju biti prazna, ne '0.00')
!============================================================
HZZOCalcClass.FormatAmountCond PROCEDURE(REAL pVal)
  CODE
  IF pVal = 0 THEN RETURN ''.
  RETURN SELF.FormatAmount(pVal)

!============================================================
! HZZOCalcClass.CalcRacun
!
! Izracunava sve financijske iznose za zadani racun i upisuje u pRacQ.
!
! Ulazni uvjeti:
!   pRacQ.TipOsiguranja mora biti 'D1', 'P1' ili 'P0'
!   pStavQ.StopaPDV mora biti unesena (npr. '5.00' ili '25.00') za svaku stavku
!   pStavQ.UkupniIznos mora biti unesena (iznos S PDV-om)
!   pStavQ.IznosRazCijene opciona ('' ili '0.00' ako nema razlike)
!
! Izlaz (upisuje u pRacQ za racun s RacunIndex=pRacunIdx):
!   UkIznosPomagala   - ukupni iznos svih stavki (s PDV)
!   IznosSudjelovanja - sudjelovanje pacijenta (0 za D1 i P0)
!   IznosObveznoSPDV  - iznos na teret HZZO obveznog (s PDV)
!   IznosPDVObvezno   - PDV na obvezni dio
!   IznosDopunskoSPDV - iznos na teret HZZO dopunskog ('' za P1/P0)
!   IznosPDVDopunsko  - PDV na dopunski dio ('' za P1/P0)
!   UkIznosFaktHZZO   - = IznosObveznoSPDV
!   UkIznosFaktDop    - = IznosDopunskoSPDV ('' za P1/P0)
!   UkIznosRazCijene  - ukupna razlika u cijeni ('' ako nema)
!
! Vraca: 1=OK, 0=greska (racun nije nadjen, nevaljan tip, StopaPDV=0)
!============================================================
HZZOCalcClass.CalcRacun     PROCEDURE(                  |
                              *HZZORacunQType  pRacQ,   |
                              *HZZOStavkaQType pStavQ,  |
                              LONG             pRacunIdx|
                            )

TotalSPDV       DECIMAL(14,2)   ! ukupni iznos S PDV (sve stavke)
TotalBezPDV     DECIMAL(14,2)   ! ukupni iznos BEZ PDV (za PDV omjer)
UkRazCijene     DECIMAL(14,2)   ! ukupna razlika u cijeni
BazaHZZO        DECIMAL(14,2)   ! = TotalSPDV - UkRazCijene (HZZO referentna cijena)
IzracunataSudj  DECIMAL(14,2)   ! participacija (izracunata, bez obzira na tip)
IznosObvezno    DECIMAL(14,2)   ! iznos na teret HZZO obveznog (s PDV)
IznosDopunsko   DECIMAL(14,2)   ! iznos na teret HZZO dopunskog (s PDV); 0 za P1/P0
IznosSudj       DECIMAL(14,2)   ! konacno sudjelovanje pacijenta; 0 za D1/P0
BezPDV_Ratio    DECIMAL(16,8)   ! omjer TotalBezPDV / TotalSPDV (za PDV raspad)
IznosPDVObv     DECIMAL(14,2)   ! PDV na obvezni dio
IznosPDVDop     DECIMAL(14,2)   ! PDV na dopunski dio
l:StopaPDV      DECIMAL(8,2)    ! stopa PDV za trenutnu stavku
l:UkpStavka     DECIMAL(14,2)   ! UkupniIznos trenutne stavke
l:RazStavka     DECIMAL(14,2)   ! IznosRazCijene trenutne stavke
l:TipOsig       STRING(2)       ! TipOsiguranja iz RacunQ
l:RacNadjen     BYTE            ! 1 ako je racun pronadjen u pRacQ
i               LONG            ! loop counter

  CODE
  TotalSPDV    = 0
  TotalBezPDV  = 0
  UkRazCijene  = 0
  l:RacNadjen  = 0

  ! --- 1. Provjeri TipOsiguranja (nadjemo racun u pRacQ) ---
  LOOP i = 1 TO RECORDS(pRacQ)
    GET(pRacQ, i)
    IF pRacQ.RacunIndex = pRacunIdx
      l:TipOsig   = CLIP(pRacQ.TipOsiguranja)
      l:RacNadjen = 1
      BREAK
    END
  END

  IF l:RacNadjen = 0 THEN RETURN 0.  ! Racun nije nadjen

  IF l:TipOsig <> HZZO:TipD1 AND l:TipOsig <> HZZO:TipP1 AND l:TipOsig <> HZZO:TipP0
    RETURN 0                          ! Nevaljan TipOsiguranja
  END

  ! --- 2. Iteriraj stavke, akumuliraj iznose i PDV ---
  LOOP i = 1 TO RECORDS(pStavQ)
    GET(pStavQ, i)
    IF pStavQ.RacunIndex <> pRacunIdx THEN CYCLE.

    l:UkpStavka = pStavQ.UkupniIznos
    l:RazStavka = pStavQ.IznosRazCijene
    l:StopaPDV  = pStavQ.StopaPDV

    IF l:StopaPDV = 0 THEN RETURN 0.  ! StopaPDV mora biti unesena (5.00 ili 25.00)

    TotalSPDV   += l:UkpStavka
    UkRazCijene += l:RazStavka
    ! BezPDV za ovu stavku: ROUND(iznos / (1 + stopa/100), .01)
    TotalBezPDV += ROUND(l:UkpStavka / (1 + l:StopaPDV / 100), .01)
  END

  IF TotalSPDV = 0 THEN RETURN 0.  ! Nema stavki za ovaj racun

  ! --- 3. Baza za sudjelovanje = HZZO referentna cijena (bez razlike) ---
  BazaHZZO = TotalSPDV - UkRazCijene

  ! --- 4. Korekcija: ako baza prelazi MaxIznosFact, visak ide u razliku ---
  IF BazaHZZO > SELF.MaxIznosFact
    UkRazCijene += BazaHZZO - SELF.MaxIznosFact
    BazaHZZO    =  SELF.MaxIznosFact
  END

  ! --- 5. Izracun participacije ---
  IF l:TipOsig = HZZO:TipP0 OR BazaHZZO <= 0
    IzracunataSudj = 0              ! P0 ili nema HZZO pokrica
  ELSE
    IzracunataSudj = ROUND(BazaHZZO * SELF.StopaParticipacije, .01)
    IF IzracunataSudj < SELF.MinParticipacija THEN IzracunataSudj = SELF.MinParticipacija.
    IF IzracunataSudj > SELF.MaxParticipacija THEN IzracunataSudj = SELF.MaxParticipacija.
  END

  ! --- 6. Dodjela sudjelovanja po tipu osiguranja ---
  CASE l:TipOsig
  OF HZZO:TipD1
    ! Ima dopunsko: pacijent placa 0, dopunsko pokriva participaciju
    IznosSudj     = 0
    IznosDopunsko = IzracunataSudj
  OF HZZO:TipP1
    ! Nema dopunsko: pacijent placa participaciju
    IznosSudj     = IzracunataSudj
    IznosDopunsko = 0
  OF HZZO:TipP0
    ! Izuzet: nema participacije, HZZO obvezno pokriva sve
    IznosSudj     = 0
    IznosDopunsko = 0
  END

  ! --- 7. HZZO obvezno dio (isti za sve tipove) ---
  IznosObvezno = BazaHZZO - IzracunataSudj

  ! --- 8. PDV raspad (proporcionalni po BezPDV_Ratio) ---
  ! Radi ispravno za jednu i za vise PDV stopa na istom racunu.
  ! Omjer BezPDV_Ratio = udio bez-PDV u ukupnom iznosu (s PDV).
  ! Svaki iznos S PDV mnozimo s omjerom -> dobijemo bez-PDV dio -> PDV = razlika.
  BezPDV_Ratio = TotalBezPDV / TotalSPDV
  IznosPDVObv  = IznosObvezno  - ROUND(IznosObvezno  * BezPDV_Ratio, .01)
  IznosPDVDop  = IznosDopunsko - ROUND(IznosDopunsko * BezPDV_Ratio, .01)

  ! --- 9. Upisi rezultate u pRacQ ---
  LOOP i = 1 TO RECORDS(pRacQ)
    GET(pRacQ, i)
    IF pRacQ.RacunIndex = pRacunIdx
      pRacQ.UkIznosPomagala   = SELF.FormatAmount(TotalSPDV)
      pRacQ.UkIznosRazCijene  = SELF.FormatAmountCond(UkRazCijene)
      pRacQ.IznosSudjelovanja = SELF.FormatAmount(IznosSudj)
      pRacQ.IznosObveznoSPDV  = SELF.FormatAmount(IznosObvezno)
      pRacQ.IznosPDVObvezno   = SELF.FormatAmount(IznosPDVObv)
      pRacQ.IznosDopunskoSPDV = SELF.FormatAmountCond(IznosDopunsko)
      pRacQ.IznosPDVDopunsko  = SELF.FormatAmountCond(IznosPDVDop)
      pRacQ.UkIznosFaktHZZO   = SELF.FormatAmount(IznosObvezno)
      pRacQ.UkIznosFaktDop    = SELF.FormatAmountCond(IznosDopunsko)
      PUT(pRacQ)
      BREAK
    END
  END

  RETURN 1
