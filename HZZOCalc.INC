!============================================================================
! HZZOCalc.INC - HZZO kalkulator iznosa za ortopedska pomagala
!
! Racuna: participaciju, HZZO obvezno/dopunsko, PDV raspad
! Upisuje rezultate u HZZORacunQType queue.
!
! Ovisnost: HZZOSpec.INC (ukljuceno automatski)
!============================================================================
  OMIT('_EndOfCalcInclude_',_HZZOCalcDefined_)
_HZZOCalcDefined_ EQUATE(1)

  INCLUDE('HZZOSpec.INC'),ONCE

!--- Konstante za TipOsiguranja ---
HZZO:TipD1    EQUATE('D1')   ! Ima dopunsko HZZO osiguranje (pacijent placa 0)
HZZO:TipP1    EQUATE('P1')   ! Nema dopunsko, placa participaciju
HZZO:TipP0    EQUATE('P0')   ! Izuzet od sudjelovanja (djeca, RVI...)

!============================================================================
! HZZOCalcClass - Kalkulator financijskih iznosa HZZO racuna za pomagala
!
! Pravila:
!   participacija = MAX(MinParticipacija, MIN(bazaHZZO * StopaParticipacije, MaxParticipacija))
!   D1: IznosSudjelovanja=0, IznosDopunskoSPDV=participacija
!   P1: IznosSudjelovanja=participacija, IznosDopunskoSPDV=0
!   P0: IznosSudjelovanja=0, IznosDopunskoSPDV=0 (obvezno pokriva sve)
!   PDV raspad: proporcionalni po omjeru TotalBezPDV/TotalSPDV
!============================================================================
HZZOCalcClass   CLASS,TYPE,MODULE('HZZOCalc.CLW'),LINK('HZZOCalc.CLW')
! --- Konfiguracija (postavljeno u Init; mijenjati sa SetKonstante) ---
MinParticipacija    DECIMAL(8,2)    ! min participacija po racunu (default: 8.83 EUR)
MaxParticipacija    DECIMAL(8,2)    ! max participacija po racunu (default: 530.88 EUR)
StopaParticipacije  DECIMAL(6,4)    ! stopa participacije (default: 0.2000 = 20%)
MaxIznosFact        DECIMAL(10,2)   ! max HZZO priznatog troska (default: 2654.40 EUR)

! --- Javne metode ---
Init            PROCEDURE()
Kill            PROCEDURE()
SetKonstante    PROCEDURE(DECIMAL pMin, DECIMAL pMax, DECIMAL pStopa)
                !   pMin   - novi min participacije (npr. 8.83)
                !   pMax   - novi max participacije (npr. 530.88)
                !   pStopa - stopa kao decimala (npr. 0.2000 za 20%)
                !   MaxIznosFact se izracuna automatski: pMax / pStopa

CalcRacun       PROCEDURE(                  |
                  &HZZORacunQType  pRacQ,   |
                  &HZZOStavkaQType pStavQ,  |
                  LONG             pRacunIdx|
                ),BYTE
                ! Izracunava sve iznos-polje za navedeni racun.
                ! Procitava RacunQ.TipOsiguranja i StavkaQ.StopaPDV.
                ! Upisuje: UkIznosPomagala, IznosSudjelovanja, IznosObveznoSPDV,
                !          IznosPDVObvezno, IznosDopunskoSPDV, IznosPDVDopunsko,
                !          UkIznosFaktHZZO, UkIznosFaktDop, UkIznosRazCijene
                ! Vraca: 1=OK, 0=greska

! --- Privatne metode ---
FormatAmount    PROCEDURE(DECIMAL pVal),STRING,PRIVATE
                ! DECIMAL -> STRING N.NN bez vodecih razmaka (npr. '244.71')
FormatAmountCond PROCEDURE(DECIMAL pVal),STRING,PRIVATE
                ! Kao FormatAmount, ali vraca '' za vrijednost 0 (za uvjetna polja)
              END

_EndOfCalcInclude_
