!============================================================================
! HZZOSpecTest2.CLW - Primjer koristenja HZZOSpecClass klase
!
! Ovaj primjer demonstrira:
!   1. Inicijalizaciju klase
!   2. Punjenje racuna (slog 60) i stavki (slog 61) iz podataka
!   3. Samo validaciju (bez exporta)
!   4. Export u datoteku prema HZZO specifikaciji
!   5. Generiranje naziva datoteke
!   6. Prikaz gresaka iz ErrorQ
!   7. Primjer s neispravanim podacima (demonstracija gresaka)
!============================================================================
  PROGRAM

  INCLUDE('HZZOSpec.INC')
  INCLUDE('HZZOCalc.INC'),ONCE

  MAP
PrimjerIspravniPodaci   PROCEDURE()
PrimjerNeispravniPodaci PROCEDURE()
PrimjerViseRacuna       PROCEDURE()
PrimjerReport           PROCEDURE()
PrimjerReportSviRacuni  PROCEDURE()
PrimjerCalcRacun        PROCEDURE()
PrikaziGreske           PROCEDURE(HZZOSpecClass pSpec)
LogOpen                 PROCEDURE(STRING pFileName)
LogWrite                PROCEDURE(STRING pMsg)
LogClose                PROCEDURE()
    MODULE('Win32')
      log_CreateFile(*CSTRING,LONG,LONG,LONG,LONG,LONG,LONG),LONG,PASCAL,RAW,NAME('CreateFileA')
      log_WriteFile(LONG,*STRING,LONG,*LONG,LONG),LONG,PASCAL,RAW,NAME('WriteFile')
      log_CloseHandle(LONG),LONG,PASCAL,NAME('CloseHandle')
    END
  END

Spec     HZZOSpecClass                ! Globalna instanca klase
I        LONG
hLogFile LONG(0)                      ! Handle log datoteke

  CODE
  LogOpen('.\HZZOSpecTest2.log')
  LogWrite('============================================================')
  LogWrite('HZZO Spec Test2 - Pocetak')
  LogWrite('============================================================')

  ! --- Primjer 1: Ispravni podaci ---
  ! --- Demonstracija DateToStr metode ---
  LogWrite('--- DateToStr demonstracija ---')
  LogWrite('  Datum danas (TODAY()): ' & Spec.DateToStr(TODAY()))
  LogWrite('  DATE(1,2,2023) -> ocekivano 02.01.2023: ' & Spec.DateToStr(DATE(1,2,2023)))
  LogWrite('  DATE(12,31,2025) -> ocekivano 31.12.2025: ' & Spec.DateToStr(DATE(12,31,2025)))
  LogWrite('  pDate=0 -> ocekivano 00.00.0000: ' & Spec.DateToStr(0))
  LogWrite('')

  LogWrite('--- TEST 1: Ispravni podaci ---')
  PrimjerIspravniPodaci()

  ! --- Primjer 2: Vise racuna (3 racuna, 5 stavki) ---
  LogWrite('')
  LogWrite('--- TEST 2: Vise racuna ---')
  PrimjerViseRacuna()

  ! --- Primjer 3: Neispravni podaci (demonstracija validacijskih gresaka) ---
  LogWrite('')
  LogWrite('--- TEST 3: Neispravni podaci ---')
  PrimjerNeispravniPodaci()

  ! --- Primjer 4: Generiranje PDF racuna (osnovno i dopunsko ZO) ---
  LogWrite('')
  LogWrite('--- TEST 4: Report - PDF racun (jedan racun) ---')
  PrimjerReport()

  ! --- Primjer 4b: Svi racuni u jednom PDF-u (ReportAll) ---
  LogWrite('')
  LogWrite('--- TEST 4b: ReportAll - svi racuni u jednom PDF-u ---')
  PrimjerReportSviRacuni()

  ! --- Primjer 5: Kalkulator iznosa (HZZOCalcClass) ---
  LogWrite('')
  LogWrite('--- TEST 5: HZZOCalcClass.CalcRacun ---')
  PrimjerCalcRacun()

  LogWrite('')
  LogWrite('============================================================')
  LogWrite('HZZO Spec Test2 - Kraj')
  LogWrite('============================================================')
  LogClose()

  MESSAGE('Gotovo! Log zapisan u HZZOSpecTest2.log','Kraj')

!============================================================================
! PrimjerIspravniPodaci - Demonstracija s ispravnim podacima iz specifikacije
! Podaci preuzeti iz Priloga 7 dokumenta OS_POM_25.docx
!============================================================================
PrimjerIspravniPodaci PROCEDURE()
Spec       HZZOSpecClass
sFileName  STRING(30)
sFullPath  STRING(260)
bResult    BOOL
dDatum     LONG                          ! Clarion datum (koristimo DateToStr za formatiranje)
  CODE
  LogWrite('  Spec.Init()')
  Spec.Init()

  !--- Punjenje racuna (vodeci slog 60) ---
  dDatum = DATE(1, 2, 2023)             ! Clarion datum: 2. sijecnja 2023.
  LogWrite('  Punjenje racuna (slog 60)...')
  LogWrite('  DateToStr(DATE(1,2,2023)) = ' & Spec.DateToStr(dDatum))
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex          = 1
  Spec.RacunQ.SifraIsporucitelja  = '200326791'
  Spec.RacunQ.NazivIsporucitelja  = 'Ustanova 1'
  Spec.RacunQ.BrojOvjerenePotvrde = ''
  Spec.RacunQ.DatumObracuna       = Spec.DateToStr(dDatum)
  Spec.RacunQ.VrstaPomagala       = '7'
  Spec.RacunQ.DatumNarudzbe       = Spec.DateToStr(dDatum)
  Spec.RacunQ.BrojRacDopunsko     = '25/2023-D'
  Spec.RacunQ.BrojPolice          = '10042090'
  Spec.RacunQ.UkIznosPomagala     = '17.77'
  Spec.RacunQ.IznosSudjelovanja   = '0.00'
  Spec.RacunQ.IznosDopunskoSPDV   = '6.62'
  Spec.RacunQ.IznosPDVDopunsko    = '0.32'
  Spec.RacunQ.IznosObveznoSPDV    = '11.15'
  Spec.RacunQ.IznosPDVObvezno     = '0.53'
  Spec.RacunQ.NeKoristiSe1        = ''
  Spec.RacunQ.NeKoristiSe2        = ''
  Spec.RacunQ.MBO                 = '123456782'           ! KZ=2 (ispravna kontrolna znamenka)
  Spec.RacunQ.BrojBolesnickogLista = ''
  Spec.RacunQ.Drzava              = ''
  Spec.RacunQ.SifraProizvodjaca   = ''
  Spec.RacunQ.UkIznosFaktHZZO     = '0.00'
  Spec.RacunQ.UkIznosFaktDop      = '0.00'
  Spec.RacunQ.BrojOsobnogRacuna   = '25/2023'
  Spec.RacunQ.AktivnostObvezno    = '10055'
  Spec.RacunQ.AktivnostDopunsko   = '11201'
  Spec.RacunQ.BrojPotvrdeDoktora  = ''
  Spec.RacunQ.IdentifikatorEPotvrde = '7773017bf16f2155b-xebe68d184545c21027cf1'
  Spec.RacunQ.DatumIzdavanja      = Spec.DateToStr(dDatum)
  Spec.RacunQ.UkIznosRazCijene    = '0.00'
  Spec.RacunQ.OIB                 = ''
  Spec.RacunQ.Valuta              = 'EUR'
  ADD(Spec.RacunQ)
  LogWrite('  Racun dodan. RacunIndex=1, SifraIsporucitelja=200326791')

  !--- Punjenje stavke 1 (slog 61) ---
  LogWrite('  Punjenje stavke 1 (slog 61)...')
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex          = 1
  Spec.StavkaQ.BrojOvjerenePotvrde = ''
  Spec.StavkaQ.DatumObracuna       = Spec.DateToStr(dDatum)
  Spec.StavkaQ.SifraPomagala       = '0324120807006'
  Spec.StavkaQ.Kolicina            = '50.00'
  Spec.StavkaQ.UkupniIznos         = '15.12'
  Spec.StavkaQ.SifraProizvodjaca   = '10250'
  Spec.StavkaQ.BrojPotvrdeDoktora  = ''
  Spec.StavkaQ.SifraVelicineObloge = ''
  Spec.StavkaQ.IdentifikacijaPomagala = ''
  Spec.StavkaQ.IdentifikatorEPotvrde  = '7773017bf16f2155b-xebe68d184545c21027cf1'
  Spec.StavkaQ.IznosRazCijene      = '0.00'
  ADD(Spec.StavkaQ)
  LogWrite('  Stavka 1 dodana. SifraPomagala=0324120807006')

  !--- Punjenje stavke 2 (slog 61) ---
  LogWrite('  Punjenje stavke 2 (slog 61)...')
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex          = 1
  Spec.StavkaQ.BrojOvjerenePotvrde = ''
  Spec.StavkaQ.DatumObracuna       = Spec.DateToStr(dDatum)
  Spec.StavkaQ.SifraPomagala       = '0321120808003'
  Spec.StavkaQ.Kolicina            = '50.00'
  Spec.StavkaQ.UkupniIznos         = '2.65'
  Spec.StavkaQ.SifraProizvodjaca   = '10250'
  Spec.StavkaQ.BrojPotvrdeDoktora  = ''
  Spec.StavkaQ.SifraVelicineObloge = ''
  Spec.StavkaQ.IdentifikacijaPomagala = ''
  Spec.StavkaQ.IdentifikatorEPotvrde  = '7773017bf16f2155b-xebe68d184545c21027cf1'
  Spec.StavkaQ.IznosRazCijene      = '0.00'
  ADD(Spec.StavkaQ)
  LogWrite('  Stavka 2 dodana. SifraPomagala=0321120808003')

  !--- Samo validacija (bez exporta) ---
  LogWrite('  Pokretanje Spec.Validate()...')
  bResult = Spec.Validate()
  IF bResult
    LogWrite('  Validacija: USPJESNA (0 gresaka)')
  ELSE
    LogWrite('  Validacija: NEUSPJESNA - Broj gresaka: ' & Spec.GetErrorCount())
    PrikaziGreske(Spec)
  END

  !--- Generiranje naziva datoteke ---
  sFileName = Spec.GenerateFileName('060','200326791', 1, 2023)
  LogWrite('  Generirani naziv datoteke: ' & CLIP(sFileName))

  !--- Export u datoteku ---
  sFullPath = '.\' & sFileName
  LogWrite('  Pokretanje Spec.Export(' & CLIP(sFullPath) & ')...')
  bResult = Spec.Export(sFullPath)
  IF bResult
    LogWrite('  Export: USPJESAN -> ' & CLIP(sFullPath))
  ELSE
    LogWrite('  Export: NEUSPJESAN - Broj gresaka: ' & Spec.GetErrorCount())
    PrikaziGreske(Spec)
  END

  LogWrite('  Spec.Kill()')
  Spec.Kill()

!============================================================================
! PrimjerViseRacuna - 3 racuna, 5 stavki ukupno, razliciti pacijenti
! Racun 1: MBO pacijent, vrsta 7 (secerna bolest), 2 stavke
! Racun 2: OIB pacijent, vrsta 1 (ortopedska pomagala), 2 stavke
! Racun 3: MBO pacijent, vrsta 3 (sluh), 1 stavka
!============================================================================
PrimjerViseRacuna PROCEDURE()
Spec       HZZOSpecClass
sFileName  STRING(30)
sFullPath  STRING(260)
bResult    BOOL
dDatum1    LONG                          ! datum racuna 1: 05.01.2023
dDatum2    LONG                          ! datum racuna 2: 06.01.2023
dDatum3    LONG                          ! datum racuna 3: 07.01.2023
  CODE
  dDatum1 = DATE(1, 5, 2023)
  dDatum2 = DATE(1, 6, 2023)
  dDatum3 = DATE(1, 7, 2023)
  LogWrite('  Spec.Init()')
  Spec.Init()

  !=== RACUN 1: Pacijent s MBO, secerna bolest (vrsta 7) ===
  LogWrite('  Punjenje racuna 1 (MBO, vrsta=7, secerna bolest)...')
  LogWrite('  DateToStr(dDatum1) = ' & Spec.DateToStr(dDatum1))
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex            = 1
  Spec.RacunQ.SifraIsporucitelja    = '200326791'
  Spec.RacunQ.NazivIsporucitelja    = 'Ljekarna Centar d.o.o.'
  Spec.RacunQ.BrojOvjerenePotvrde   = ''
  Spec.RacunQ.DatumObracuna         = Spec.DateToStr(dDatum1)
  Spec.RacunQ.VrstaPomagala         = '7'
  Spec.RacunQ.DatumNarudzbe         = Spec.DateToStr(DATE(1, 4, 2023))
  Spec.RacunQ.BrojRacDopunsko       = ''
  Spec.RacunQ.BrojPolice            = ''
  Spec.RacunQ.UkIznosPomagala       = '22.50'
  Spec.RacunQ.IznosSudjelovanja     = '0.00'
  Spec.RacunQ.IznosDopunskoSPDV     = '0.00'
  Spec.RacunQ.IznosPDVDopunsko      = '0.00'
  Spec.RacunQ.IznosObveznoSPDV      = '22.50'
  Spec.RacunQ.IznosPDVObvezno       = '1.07'
  Spec.RacunQ.NeKoristiSe1          = ''
  Spec.RacunQ.NeKoristiSe2          = ''
  Spec.RacunQ.MBO                   = '123456782'    ! KZ=2
  Spec.RacunQ.BrojBolesnickogLista  = ''
  Spec.RacunQ.Drzava                = ''
  Spec.RacunQ.SifraProizvodjaca     = ''
  Spec.RacunQ.UkIznosFaktHZZO       = '0.00'
  Spec.RacunQ.UkIznosFaktDop        = '0.00'
  Spec.RacunQ.BrojOsobnogRacuna     = '1/2023'
  Spec.RacunQ.AktivnostObvezno      = '1005500'
  Spec.RacunQ.AktivnostDopunsko     = ''
  Spec.RacunQ.BrojPotvrdeDoktora    = ''
  Spec.RacunQ.IdentifikatorEPotvrde = '7773017bf16f2155b-aaa11111111111111111'
  Spec.RacunQ.DatumIzdavanja        = Spec.DateToStr(dDatum1)
  Spec.RacunQ.UkIznosRazCijene      = '0.00'
  Spec.RacunQ.OIB                   = ''
  Spec.RacunQ.Valuta                = 'EUR'
  ADD(Spec.RacunQ)

  ! Stavka 1.1
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex           = 1
  Spec.StavkaQ.BrojOvjerenePotvrde  = ''
  Spec.StavkaQ.DatumObracuna        = Spec.DateToStr(dDatum1)
  Spec.StavkaQ.SifraPomagala        = '0324120807006'
  Spec.StavkaQ.Kolicina             = '100.00'
  Spec.StavkaQ.UkupniIznos          = '15.00'
  Spec.StavkaQ.SifraProizvodjaca    = '10250'
  Spec.StavkaQ.BrojPotvrdeDoktora   = ''
  Spec.StavkaQ.SifraVelicineObloge  = ''
  Spec.StavkaQ.IdentifikacijaPomagala = ''
  Spec.StavkaQ.IdentifikatorEPotvrde  = '7773017bf16f2155b-aaa11111111111111111'
  Spec.StavkaQ.IznosRazCijene       = '0.00'
  ADD(Spec.StavkaQ)

  ! Stavka 1.2
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex           = 1
  Spec.StavkaQ.BrojOvjerenePotvrde  = ''
  Spec.StavkaQ.DatumObracuna        = Spec.DateToStr(dDatum1)
  Spec.StavkaQ.SifraPomagala        = '0321120808003'
  Spec.StavkaQ.Kolicina             = '50.00'
  Spec.StavkaQ.UkupniIznos          = '7.50'
  Spec.StavkaQ.SifraProizvodjaca    = '10250'
  Spec.StavkaQ.BrojPotvrdeDoktora   = ''
  Spec.StavkaQ.SifraVelicineObloge  = ''
  Spec.StavkaQ.IdentifikacijaPomagala = ''
  Spec.StavkaQ.IdentifikatorEPotvrde  = '7773017bf16f2155b-aaa11111111111111111'
  Spec.StavkaQ.IznosRazCijene       = '0.00'
  ADD(Spec.StavkaQ)
  LogWrite('  Racun 1 dodan (2 stavke, MBO=123456782)')

  !=== RACUN 2: Pacijent s OIB, ortopedska pomagala (vrsta 1) ===
  LogWrite('  Punjenje racuna 2 (OIB, vrsta=1, ortopedska pomagala)...')
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex            = 2
  Spec.RacunQ.SifraIsporucitelja    = '200326791'
  Spec.RacunQ.NazivIsporucitelja    = 'Ljekarna Centar d.o.o.'
  Spec.RacunQ.BrojOvjerenePotvrde   = '10/12345678'   ! format: redni/broj
  Spec.RacunQ.DatumObracuna         = '06.01.2023'
  Spec.RacunQ.VrstaPomagala         = '1'
  Spec.RacunQ.DatumNarudzbe         = '03.01.2023'
  Spec.RacunQ.BrojRacDopunsko       = '26/2023-D'
  Spec.RacunQ.BrojPolice            = '20051234'
  Spec.RacunQ.UkIznosPomagala       = '350.00'
  Spec.RacunQ.IznosSudjelovanja     = '50.00'
  Spec.RacunQ.IznosDopunskoSPDV     = '50.00'
  Spec.RacunQ.IznosPDVDopunsko      = '2.38'
  Spec.RacunQ.IznosObveznoSPDV      = '300.00'
  Spec.RacunQ.IznosPDVObvezno       = '14.29'
  Spec.RacunQ.NeKoristiSe1          = ''
  Spec.RacunQ.NeKoristiSe2          = ''
  Spec.RacunQ.MBO                   = ''
  Spec.RacunQ.BrojBolesnickogLista  = ''
  Spec.RacunQ.Drzava                = ''
  Spec.RacunQ.SifraProizvodjaca     = ''
  Spec.RacunQ.UkIznosFaktHZZO       = '0.00'
  Spec.RacunQ.UkIznosFaktDop        = '0.00'
  Spec.RacunQ.BrojOsobnogRacuna     = '26/2023'
  Spec.RacunQ.AktivnostObvezno      = '1005501'
  Spec.RacunQ.AktivnostDopunsko     = '11201'
  Spec.RacunQ.BrojPotvrdeDoktora    = ''
  Spec.RacunQ.IdentifikatorEPotvrde = ''
  Spec.RacunQ.DatumIzdavanja        = '06.01.2023'
  Spec.RacunQ.UkIznosRazCijene      = '0.00'
  Spec.RacunQ.OIB                   = '12345678903'    ! OIB s ispravnom KZ=3
  Spec.RacunQ.Valuta                = 'EUR'
  ADD(Spec.RacunQ)

  ! Stavka 2.1
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex           = 2
  Spec.StavkaQ.BrojOvjerenePotvrde  = '10/12345678'
  Spec.StavkaQ.DatumObracuna        = '06.01.2023'
  Spec.StavkaQ.SifraPomagala        = '0110011'        ! 7-znamenkasta sifra
  Spec.StavkaQ.Kolicina             = '1.00'
  Spec.StavkaQ.UkupniIznos          = '200.00'
  Spec.StavkaQ.SifraProizvodjaca    = ''
  Spec.StavkaQ.BrojPotvrdeDoktora   = ''
  Spec.StavkaQ.SifraVelicineObloge  = ''
  Spec.StavkaQ.IdentifikacijaPomagala = 'Proteza lijeva noga'
  Spec.StavkaQ.IdentifikatorEPotvrde  = ''
  Spec.StavkaQ.IznosRazCijene       = '0.00'
  ADD(Spec.StavkaQ)

  ! Stavka 2.2
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex           = 2
  Spec.StavkaQ.BrojOvjerenePotvrde  = '10/12345678'
  Spec.StavkaQ.DatumObracuna        = '06.01.2023'
  Spec.StavkaQ.SifraPomagala        = '0110012'        ! 7-znamenkasta sifra
  Spec.StavkaQ.Kolicina             = '1.00'
  Spec.StavkaQ.UkupniIznos          = '150.00'
  Spec.StavkaQ.SifraProizvodjaca    = ''
  Spec.StavkaQ.BrojPotvrdeDoktora   = ''
  Spec.StavkaQ.SifraVelicineObloge  = ''
  Spec.StavkaQ.IdentifikacijaPomagala = 'Stopalo lijevo'
  Spec.StavkaQ.IdentifikatorEPotvrde  = ''
  Spec.StavkaQ.IznosRazCijene       = '0.00'
  ADD(Spec.StavkaQ)
  LogWrite('  Racun 2 dodan (2 stavke, OIB=12345678903)')

  !=== RACUN 3: Pacijent s MBO, sluh (vrsta 3), 1 stavka ===
  LogWrite('  Punjenje racuna 3 (MBO, vrsta=3, sluh)...')
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex            = 3
  Spec.RacunQ.SifraIsporucitelja    = '200326791'
  Spec.RacunQ.NazivIsporucitelja    = 'Ljekarna Centar d.o.o.'
  Spec.RacunQ.BrojOvjerenePotvrde   = ''
  Spec.RacunQ.DatumObracuna         = '07.01.2023'
  Spec.RacunQ.VrstaPomagala         = '3'
  Spec.RacunQ.DatumNarudzbe         = '07.01.2023'
  Spec.RacunQ.BrojRacDopunsko       = ''
  Spec.RacunQ.BrojPolice            = ''
  Spec.RacunQ.UkIznosPomagala       = '1200.00'
  Spec.RacunQ.IznosSudjelovanja     = '0.00'
  Spec.RacunQ.IznosDopunskoSPDV     = '0.00'
  Spec.RacunQ.IznosPDVDopunsko      = '0.00'
  Spec.RacunQ.IznosObveznoSPDV      = '1200.00'
  Spec.RacunQ.IznosPDVObvezno       = '57.14'
  Spec.RacunQ.NeKoristiSe1          = ''
  Spec.RacunQ.NeKoristiSe2          = ''
  Spec.RacunQ.MBO                   = '987654325'    ! KZ=5
  Spec.RacunQ.BrojBolesnickogLista  = ''
  Spec.RacunQ.Drzava                = ''
  Spec.RacunQ.SifraProizvodjaca     = ''
  Spec.RacunQ.UkIznosFaktHZZO       = '0.00'
  Spec.RacunQ.UkIznosFaktDop        = '0.00'
  Spec.RacunQ.BrojOsobnogRacuna     = '27/2023'
  Spec.RacunQ.AktivnostObvezno      = '1005502'
  Spec.RacunQ.AktivnostDopunsko     = ''
  Spec.RacunQ.BrojPotvrdeDoktora    = ''
  Spec.RacunQ.IdentifikatorEPotvrde = '7773017bf16f2155b-ccc33333333333333333'
  Spec.RacunQ.DatumIzdavanja        = '07.01.2023'
  Spec.RacunQ.UkIznosRazCijene      = '0.00'
  Spec.RacunQ.OIB                   = ''
  Spec.RacunQ.Valuta                = 'EUR'
  ADD(Spec.RacunQ)

  ! Stavka 3.1
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex           = 3
  Spec.StavkaQ.BrojOvjerenePotvrde  = ''
  Spec.StavkaQ.DatumObracuna        = '07.01.2023'
  Spec.StavkaQ.SifraPomagala        = '052001010001'   ! 12-znamenkasta sifra
  Spec.StavkaQ.Kolicina             = '1.00'
  Spec.StavkaQ.UkupniIznos          = '1200.00'
  Spec.StavkaQ.SifraProizvodjaca    = '99999'
  Spec.StavkaQ.BrojPotvrdeDoktora   = ''
  Spec.StavkaQ.SifraVelicineObloge  = ''
  Spec.StavkaQ.IdentifikacijaPomagala = 'Slusni aparat BTE'
  Spec.StavkaQ.IdentifikatorEPotvrde  = '7773017bf16f2155b-ccc33333333333333333'
  Spec.StavkaQ.IznosRazCijene       = '0.00'
  ADD(Spec.StavkaQ)
  LogWrite('  Racun 3 dodan (1 stavka, MBO=987654325)')

  !--- Validacija ---
  LogWrite('  Pokretanje Spec.Validate() za 3 racuna / 5 stavki...')
  bResult = Spec.Validate()
  IF bResult
    LogWrite('  Validacija: USPJESNA (0 gresaka)')
  ELSE
    LogWrite('  Validacija: NEUSPJESNA - Broj gresaka: ' & Spec.GetErrorCount())
    PrikaziGreske(Spec)
  END

  !--- Export ---
  sFileName = Spec.GenerateFileName('060','200326791', 2, 2023)
  sFullPath = '.\' & sFileName
  LogWrite('  Export: ' & CLIP(sFullPath))
  bResult = Spec.Export(sFullPath)
  IF bResult
    LogWrite('  Export: USPJESAN -> ' & CLIP(sFullPath))
  ELSE
    LogWrite('  Export: NEUSPJESAN - Broj gresaka: ' & Spec.GetErrorCount())
    PrikaziGreske(Spec)
  END

  LogWrite('  Spec.Kill()')
  Spec.Kill()

!============================================================================
! PrimjerNeispravniPodaci - Demonstracija validacijskih gresaka
!============================================================================
PrimjerNeispravniPodaci PROCEDURE()
Spec    HZZOSpecClass
bResult BOOL
  CODE
  LogWrite('  Spec.Init()')
  Spec.Init()

  !--- Racun s namjernim greskama ---
  LogWrite('  Punjenje racuna s NAMJERNIM GRESKAMA...')
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex          = 1
  Spec.RacunQ.SifraIsporucitelja  = '123456780'        ! Kriva kontrolna znamenka!
  Spec.RacunQ.NazivIsporucitelja  = ''                  ! Prazan - obavezan!
  Spec.RacunQ.DatumObracuna       = '31.13.2023'        ! Neispravan datum (mjesec 13)!
  Spec.RacunQ.VrstaPomagala       = '6'                 ! Nedozvoljena vrsta!
  Spec.RacunQ.DatumNarudzbe       = '15.01.2023'
  Spec.RacunQ.UkIznosPomagala     = '17.77'
  Spec.RacunQ.IznosSudjelovanja   = 'abc'               ! Neispravan iznos!
  Spec.RacunQ.IznosObveznoSPDV    = '11.15'
  Spec.RacunQ.IznosPDVObvezno     = '0.53'
  Spec.RacunQ.MBO                 = ''                  ! Nema MBO, OIB ni INO!
  Spec.RacunQ.OIB                 = ''
  Spec.RacunQ.UkIznosFaktHZZO     = '0.00'
  Spec.RacunQ.BrojOsobnogRacuna   = '25/2023'
  Spec.RacunQ.AktivnostObvezno    = '10055'
  Spec.RacunQ.DatumIzdavanja      = '02.01.2023'
  Spec.RacunQ.Valuta              = 'USD'               ! Kriva valuta!
  ADD(Spec.RacunQ)

  !--- Stavka s greskama ---
  LogWrite('  Punjenje stavke s NAMJERNIM GRESKAMA...')
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex         = 1
  Spec.StavkaQ.DatumObracuna      = '02.01.2023'
  Spec.StavkaQ.SifraPomagala      = '123'               ! Kriva duljina sifre!
  Spec.StavkaQ.Kolicina           = '50'                ! Nema decimala!
  Spec.StavkaQ.UkupniIznos        = '15.12'
  ADD(Spec.StavkaQ)

  !--- Validacija - ocekujemo greske ---
  LogWrite('  Pokretanje Spec.Validate() - ocekujemo greske...')
  bResult = Spec.Validate()
  LogWrite('  Validacija zavrsena. Broj gresaka: ' & Spec.GetErrorCount())
  PrikaziGreske(Spec)

  LogWrite('  Spec.Kill()')
  Spec.Kill()

!============================================================================
! PrimjerReport - Generiranje PDF racuna za osnovno i dopunsko ZO
! Koristi iste demo podatke kao HZZOReport.CLW
! Generira: .\racun_osnovno.pdf i .\racun_dopunsko.pdf
!============================================================================
PrimjerReport PROCEDURE()
Spec       HZZOSpecClass
  CODE
  LogWrite('  Spec.Init()')
  Spec.Init()

  !--- RacunQ: HZZO spec polja ---
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex              = 1
  Spec.RacunQ.SifraIsporucitelja      = '200326791'
  Spec.RacunQ.NazivIsporucitelja      = 'Karl Dietz Kijevo d.o.o.'
  Spec.RacunQ.DatumObracuna           = '09.01.2026'
  Spec.RacunQ.VrstaPomagala           = '1'
  Spec.RacunQ.DatumNarudzbe           = '05.01.2026'
  Spec.RacunQ.BrojRacDopunsko         = '7059'
  Spec.RacunQ.BrojPolice              = '10010474'
  Spec.RacunQ.UkIznosPomagala         = '244.71'
  Spec.RacunQ.IznosSudjelovanja       = '48.94'
  Spec.RacunQ.IznosDopunskoSPDV       = '48.94'
  Spec.RacunQ.IznosPDVDopunsko        = '2.33'
  Spec.RacunQ.IznosObveznoSPDV        = '195.77'
  Spec.RacunQ.IznosPDVObvezno         = '9.32'
  Spec.RacunQ.MBO                     = '108656533'
  Spec.RacunQ.UkIznosFaktHZZO         = '195.77'
  Spec.RacunQ.UkIznosFaktDop          = '48.94'
  Spec.RacunQ.BrojOsobnogRacuna       = '7006'
  Spec.RacunQ.AktivnostObvezno        = '0200100'
  Spec.RacunQ.IdentifikatorEPotvrde   = '36e415e8-3e3c-435c-912b-077f0a0afd86'
  Spec.RacunQ.DatumIzdavanja          = '09.01.2026'
  Spec.RacunQ.UkIznosRazCijene        = '0.00'
  Spec.RacunQ.Valuta                  = 'EUR'
  ! Report-only polja:
  Spec.RacunQ.SifraMaloprodajneLokacije = '500154120'
  Spec.RacunQ.AdresaIsporucitelja       = 'Knin Sinjska cesta 6a'
  Spec.RacunQ.ZiroRacun                 = 'HR0223600001102278846'
  Spec.RacunQ.MaticniBroj               = '01220845'
  Spec.RacunQ.OIBIsporucitelja          = '87198948864'
  Spec.RacunQ.PozivNaBroj               = '40002-2026'
  Spec.RacunQ.MjestoIzdavanja           = 'Knin'
  Spec.RacunQ.HZZOPodrucniUred          = 'HZZO PU Sibenik (083)'
  Spec.RacunQ.HZZOMjesto                = 'Sibenik'
  Spec.RacunQ.HZZOUlicaBroj             = 'Fra. Jerolima Milete 12'
  Spec.RacunQ.HZZOOIB                   = '02958272670'
  ADD(Spec.RacunQ)

  !--- StavkaQ ---
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex     = 1
  Spec.StavkaQ.DatumObracuna  = '09.01.2026'
  Spec.StavkaQ.SifraPomagala  = '0209031126005'
  Spec.StavkaQ.Kolicina       = '10.00'
  Spec.StavkaQ.UkupniIznos    = '244.71'
  Spec.StavkaQ.IznosRazCijene = '0.00'
  ! Report-only polja:
  Spec.StavkaQ.NazivPomagala  = 'Silikonska obloga za rane s dodatkom srebra iznad 75'
  Spec.StavkaQ.JedCijenaEur   = '23.3056'
  Spec.StavkaQ.StopaPDV       = '5.00'
  Spec.StavkaQ.JedRazlikaEur  = '0.0000'
  ADD(Spec.StavkaQ)

  !--- Generiraj PDF za osnovno ZO ---
  LogWrite('  Generiranje racun_osnovno.pdf (pVrsta=1)...')
  Spec.Report(1, 1, '.\racun_osnovno.pdf')
  LogWrite('  racun_osnovno.pdf - gotovo')

  !--- Generiraj PDF za dopunsko ZO ---
  LogWrite('  Generiranje racun_dopunsko.pdf (pVrsta=2)...')
  Spec.Report(1, 2, '.\racun_dopunsko.pdf')
  LogWrite('  racun_dopunsko.pdf - gotovo')

  LogWrite('  Spec.Kill()')
  Spec.Kill()

!============================================================================
! PrimjerReportSviRacuni - Generiranje svih racuna u jedan PDF (ReportAll)
!
! Demo s dva racuna:
!   Racun 1: TipOsiguranja = 'D1' (ima dopunsko) -> 2 stranice: osnovno + dopunsko
!   Racun 2: TipOsiguranja = 'P1' (nema dopunsko) -> 1 stranica: samo osnovno
!
! Rezultat: .\racuni_svi.pdf (3 stranice ukupno)
!============================================================================
PrimjerReportSviRacuni PROCEDURE()
Spec       HZZOSpecClass
  CODE
  LogWrite('  Spec.Init()')
  Spec.Init()

  !--- Racun 1: pacijent ima dopunsko osiguranje (D1) ---
  !    -> generira se stranica za osnovno + stranica za dopunsko
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex              = 1
  Spec.RacunQ.SifraIsporucitelja      = '200326791'
  Spec.RacunQ.NazivIsporucitelja      = 'Karl Dietz Kijevo d.o.o.'
  Spec.RacunQ.DatumObracuna           = '09.01.2026'
  Spec.RacunQ.VrstaPomagala           = '1'
  Spec.RacunQ.DatumNarudzbe           = '05.01.2026'
  Spec.RacunQ.BrojRacDopunsko         = '7059'
  Spec.RacunQ.BrojPolice              = '10010474'
  Spec.RacunQ.UkIznosPomagala         = '244.71'
  Spec.RacunQ.IznosSudjelovanja       = '48.94'
  Spec.RacunQ.IznosDopunskoSPDV       = '48.94'
  Spec.RacunQ.IznosPDVDopunsko        = '2.33'
  Spec.RacunQ.IznosObveznoSPDV        = '195.77'
  Spec.RacunQ.IznosPDVObvezno         = '9.32'
  Spec.RacunQ.MBO                     = '108656533'
  Spec.RacunQ.UkIznosFaktHZZO         = '195.77'
  Spec.RacunQ.UkIznosFaktDop          = '48.94'
  Spec.RacunQ.BrojOsobnogRacuna       = '7006'
  Spec.RacunQ.AktivnostObvezno        = '0200100'
  Spec.RacunQ.IdentifikatorEPotvrde   = '36e415e8-3e3c-435c-912b-077f0a0afd86'
  Spec.RacunQ.DatumIzdavanja          = '09.01.2026'
  Spec.RacunQ.UkIznosRazCijene        = '0.00'
  Spec.RacunQ.Valuta                  = 'EUR'
  Spec.RacunQ.SifraMaloprodajneLokacije = '500154120'
  Spec.RacunQ.AdresaIsporucitelja       = 'Knin Sinjska cesta 6a'
  Spec.RacunQ.ZiroRacun                 = 'HR0223600001102278846'
  Spec.RacunQ.MaticniBroj               = '01220845'
  Spec.RacunQ.OIBIsporucitelja          = '87198948864'
  Spec.RacunQ.PozivNaBroj               = '40002-2026'
  Spec.RacunQ.MjestoIzdavanja           = 'Knin'
  Spec.RacunQ.HZZOPodrucniUred          = 'HZZO PU Sibenik (083)'
  Spec.RacunQ.HZZOMjesto                = 'Sibenik'
  Spec.RacunQ.HZZOUlicaBroj             = 'Fra. Jerolima Milete 12'
  Spec.RacunQ.HZZOOIB                   = '02958272670'
  Spec.RacunQ.TipOsiguranja             = HZZO:TipD1  ! ima dopunsko -> osnovno + dopunsko stranica
  ADD(Spec.RacunQ)

  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex     = 1
  Spec.StavkaQ.DatumObracuna  = '09.01.2026'
  Spec.StavkaQ.SifraPomagala  = '0209031126005'
  Spec.StavkaQ.Kolicina       = '10.00'
  Spec.StavkaQ.UkupniIznos    = '244.71'
  Spec.StavkaQ.IznosRazCijene = '0.00'
  Spec.StavkaQ.NazivPomagala  = 'Silikonska obloga za rane s dodatkom srebra iznad 75'
  Spec.StavkaQ.JedCijenaEur   = '23.3056'
  Spec.StavkaQ.StopaPDV       = '5.00'
  Spec.StavkaQ.JedRazlikaEur  = '0.0000'
  ADD(Spec.StavkaQ)

  !--- Racun 2: pacijent nema dopunsko osiguranje (P1) ---
  !    -> generira se samo stranica za osnovno
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex              = 2
  Spec.RacunQ.SifraIsporucitelja      = '200326791'
  Spec.RacunQ.NazivIsporucitelja      = 'Karl Dietz Kijevo d.o.o.'
  Spec.RacunQ.DatumObracuna           = '10.01.2026'
  Spec.RacunQ.VrstaPomagala           = '1'
  Spec.RacunQ.DatumNarudzbe           = '08.01.2026'
  Spec.RacunQ.BrojRacDopunsko         = ''
  Spec.RacunQ.BrojPolice              = ''
  Spec.RacunQ.UkIznosPomagala         = '85.00'
  Spec.RacunQ.IznosSudjelovanja       = '17.00'
  Spec.RacunQ.IznosDopunskoSPDV       = '0.00'
  Spec.RacunQ.IznosPDVDopunsko        = '0.00'
  Spec.RacunQ.IznosObveznoSPDV        = '68.00'
  Spec.RacunQ.IznosPDVObvezno         = '3.24'
  Spec.RacunQ.MBO                     = '987654325'
  Spec.RacunQ.UkIznosFaktHZZO         = '68.00'
  Spec.RacunQ.UkIznosFaktDop          = '0.00'
  Spec.RacunQ.BrojOsobnogRacuna       = '7007'
  Spec.RacunQ.AktivnostObvezno        = '0200100'
  Spec.RacunQ.IdentifikatorEPotvrde   = 'aa112233-bbcc-4455-ddee-ff6677889900'
  Spec.RacunQ.DatumIzdavanja          = '10.01.2026'
  Spec.RacunQ.UkIznosRazCijene        = '0.00'
  Spec.RacunQ.Valuta                  = 'EUR'
  Spec.RacunQ.SifraMaloprodajneLokacije = '500154120'
  Spec.RacunQ.AdresaIsporucitelja       = 'Knin Sinjska cesta 6a'
  Spec.RacunQ.ZiroRacun                 = 'HR0223600001102278846'
  Spec.RacunQ.MaticniBroj               = '01220845'
  Spec.RacunQ.OIBIsporucitelja          = '87198948864'
  Spec.RacunQ.PozivNaBroj               = '40003-2026'
  Spec.RacunQ.MjestoIzdavanja           = 'Knin'
  Spec.RacunQ.HZZOPodrucniUred          = 'HZZO PU Sibenik (083)'
  Spec.RacunQ.HZZOMjesto                = 'Sibenik'
  Spec.RacunQ.HZZOUlicaBroj             = 'Fra. Jerolima Milete 12'
  Spec.RacunQ.HZZOOIB                   = '02958272670'
  Spec.RacunQ.TipOsiguranja             = HZZO:TipP1  ! nema dopunsko -> samo osnovno stranica
  ADD(Spec.RacunQ)

  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex     = 2
  Spec.StavkaQ.DatumObracuna  = '10.01.2026'
  Spec.StavkaQ.SifraPomagala  = '0104120101001'
  Spec.StavkaQ.Kolicina       = '1.00'
  Spec.StavkaQ.UkupniIznos    = '85.00'
  Spec.StavkaQ.IznosRazCijene = '0.00'
  Spec.StavkaQ.NazivPomagala  = 'Proteza natkoljenicna standardna'
  Spec.StavkaQ.JedCijenaEur   = '85.0000'
  Spec.StavkaQ.StopaPDV       = '5.00'
  Spec.StavkaQ.JedRazlikaEur  = '0.0000'
  ADD(Spec.StavkaQ)

  !--- Generiraj sve racune u jedan PDF ---
  ! Racun 1 (D1): stranica 1=osnovno, stranica 2=dopunsko
  ! Racun 2 (P1): stranica 3=osnovno
  ! Ukupno: 3 stranice u jednom PDF-u
  LogWrite('  Generiranje .\racuni_svi.pdf (3 stranice: os1, dop1, os2)...')
  Spec.ReportAll('.\racuni_svi.pdf')
  LogWrite('  racuni_svi.pdf - gotovo')

  LogWrite('  Spec.Kill()')
  Spec.Kill()

!============================================================================
! PrikaziGreske - Ispisuje sve greske iz ErrorQ u log i MESSAGE
!============================================================================
PrikaziGreske PROCEDURE(HZZOSpecClass pSpec)
I      LONG
sMsg   STRING(2000)
sLine  STRING(300)
  CODE
  sMsg = 'Popis gresaka:' & '<13,10>' & '<13,10>'
  LogWrite('  --- Popis gresaka (' & RECORDS(pSpec.ErrorQ) & ') ---')
  LOOP I = 1 TO RECORDS(pSpec.ErrorQ)
    GET(pSpec.ErrorQ, I)
    sLine = 'Slog ' & CLIP(pSpec.ErrorQ.TipSloga)      |
      & ' | Racun:'  & pSpec.ErrorQ.RacunIndex          |
      & ' | Stavka:' & pSpec.ErrorQ.StavkaIndex         |
      & ' | Polje '  & pSpec.ErrorQ.RedniBrPolja        |
      & ' ('         & CLIP(pSpec.ErrorQ.NazivPolja) & ')' |
      & ' -> '       & CLIP(pSpec.ErrorQ.Poruka)
    LogWrite('  [' & I & '] ' & CLIP(sLine))
    sMsg = CLIP(sMsg)                                  |
      & 'Slog ' & CLIP(pSpec.ErrorQ.TipSloga)          |
      & ' | Racun:' & pSpec.ErrorQ.RacunIndex           |
      & ' | Stavka:' & pSpec.ErrorQ.StavkaIndex         |
      & ' | Polje ' & pSpec.ErrorQ.RedniBrPolja         |
      & ' (' & CLIP(pSpec.ErrorQ.NazivPolja) & ')'      |
      & '<13,10>'                                       |
      & '  -> ' & CLIP(pSpec.ErrorQ.Poruka)             |
      & '<13,10>'
    IF LEN(CLIP(sMsg)) > 1500
      sMsg = CLIP(sMsg) & '... (jos ' & (RECORDS(pSpec.ErrorQ) - I) & ' gresaka)'
      BREAK
    END
  END
  LogWrite('  --- Kraj popisa gresaka ---')
  MESSAGE(sMsg,'Greske validacije')

!============================================================================
! LogOpen - Otvori log datoteku za pisanje
!============================================================================
LogOpen PROCEDURE(STRING pFileName)
csName  CSTRING(261)
  CODE
  csName   = CLIP(pFileName)
  hLogFile = log_CreateFile(csName, 40000000h, 0, 0, 2, 080h, 0)

!============================================================================
! LogWrite - Zapisi liniju u log datoteku
!============================================================================
LogWrite PROCEDURE(STRING pMsg)
sData    STRING(2002)
nLen     LONG
nWritten LONG
  CODE
  IF hLogFile = 0 OR hLogFile = -1 THEN RETURN.
  sData = CLIP(pMsg) & '<13,10>'
  nLen  = LEN(CLIP(pMsg)) + 2
  log_WriteFile(hLogFile, sData, nLen, nWritten, 0)

!============================================================================
! PrimjerCalcRacun - Verifikacija HZZOCalcClass.CalcRacun
!
! Test case iz primjera slike (Karl Dietz, silikonska obloga):
!   Stavka: 10 kom x 23.3056 EUR/kom bez PDV = 233.06 EUR bez PDV
!   PDV 5% = 11.65 EUR → ukupno 244.71 EUR s PDV
!
! Ocekivani rezultati (P1, bez dopunskog):
!   UkIznosPomagala   = '244.71'
!   IznosSudjelovanja = '48.94'   (20% od 244.71)
!   IznosObveznoSPDV  = '195.77'  (244.71 - 48.94)
!   IznosPDVObvezno   = '9.32'    (PDV na 195.77 @ 5%)
!   IznosDopunskoSPDV = ''        (P1 = nema dopunskog)
!   UkIznosFaktHZZO   = '195.77'
!
! Ocekivani rezultati (D1, s dopunskim) - isti racun:
!   IznosSudjelovanja = '0.00'
!   IznosDopunskoSPDV = '48.94'
!   IznosPDVDopunsko  = '2.33'
!   IznosObveznoSPDV  = '195.77'  (nepromijenjeno)
!============================================================================
PrimjerCalcRacun PROCEDURE()
Calc     HZZOCalcClass
Spec     HZZOSpecClass
bOK      BYTE
  CODE
  Calc.Init()
  Spec.Init()

  LogWrite('  Konstante: Min=' & CLIP(FORMAT(Calc.MinParticipacija, @N8.2)) |
         & ' Max=' & CLIP(FORMAT(Calc.MaxParticipacija, @N8.2)) |
         & ' Stopa=' & CLIP(FORMAT(Calc.StopaParticipacije * 100, @N6.2)) & '%' |
         & ' MaxIznosFact=' & CLIP(FORMAT(Calc.MaxIznosFact, @N10.2)))

  ! -----------------------------------------------------------------------
  ! CASE 1: P1 (bez dopunskog) - primjer iz slike
  ! -----------------------------------------------------------------------
  LogWrite('')
  LogWrite('  [CASE 1] P1 - bez dopunskog, 10x23.3056 EUR bez PDV, 5% PDV')

  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex          = 1
  Spec.RacunQ.SifraIsporucitelja  = '200326791'
  Spec.RacunQ.NazivIsporucitelja  = 'Karl Dietz Kijevo d.o.o.'
  Spec.RacunQ.DatumObracuna       = '09.01.2026'
  Spec.RacunQ.VrstaPomagala       = '1'
  Spec.RacunQ.DatumNarudzbe       = '05.01.2026'
  Spec.RacunQ.BrojOsobnogRacuna   = '7006'
  Spec.RacunQ.AktivnostObvezno    = '4002026'
  Spec.RacunQ.DatumIzdavanja      = '09.01.2026'
  Spec.RacunQ.Valuta              = 'EUR'
  Spec.RacunQ.MBO                 = '108656533'
  Spec.RacunQ.TipOsiguranja       = HZZO:TipP1
  ADD(Spec.RacunQ)

  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex     = 1
  Spec.StavkaQ.DatumObracuna  = '09.01.2026'
  Spec.StavkaQ.SifraPomagala  = '0209031126005'
  Spec.StavkaQ.Kolicina       = '10.00'
  Spec.StavkaQ.UkupniIznos    = '244.71'   ! 10 x 23.3056 x 1.05 = 244.71
  Spec.StavkaQ.IznosRazCijene = '0.00'
  Spec.StavkaQ.StopaPDV       = '5.00'
  ADD(Spec.StavkaQ)

  bOK = Calc.CalcRacun(Spec.RacunQ, Spec.StavkaQ, 1)
  LogWrite('  CalcRacun vratio: ' & CHOOSE(bOK=1,'1 (OK)','0 (GRESKA)'))

  GET(Spec.RacunQ, 1)
  LogWrite('  UkIznosPomagala   = ''' & CLIP(Spec.RacunQ.UkIznosPomagala)   & ''' ocekivano: ''244.71''')
  LogWrite('  IznosSudjelovanja = ''' & CLIP(Spec.RacunQ.IznosSudjelovanja) & ''' ocekivano: ''48.94''')
  LogWrite('  IznosObveznoSPDV  = ''' & CLIP(Spec.RacunQ.IznosObveznoSPDV)  & ''' ocekivano: ''195.77''')
  LogWrite('  IznosPDVObvezno   = ''' & CLIP(Spec.RacunQ.IznosPDVObvezno)   & ''' ocekivano: ''9.32''')
  LogWrite('  IznosDopunskoSPDV = ''' & CLIP(Spec.RacunQ.IznosDopunskoSPDV) & ''' ocekivano: '''' (prazno)')
  LogWrite('  IznosPDVDopunsko  = ''' & CLIP(Spec.RacunQ.IznosPDVDopunsko)  & ''' ocekivano: '''' (prazno)')
  LogWrite('  UkIznosFaktHZZO   = ''' & CLIP(Spec.RacunQ.UkIznosFaktHZZO)   & ''' ocekivano: ''195.77''')
  LogWrite('  UkIznosFaktDop    = ''' & CLIP(Spec.RacunQ.UkIznosFaktDop)     & ''' ocekivano: '''' (prazno)')

  ! -----------------------------------------------------------------------
  ! CASE 2: D1 (s dopunskim) - isti iznosi, drugi tip
  ! -----------------------------------------------------------------------
  LogWrite('')
  LogWrite('  [CASE 2] D1 - s dopunskim, isti racun')

  Spec.ClearAll()
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex          = 1
  Spec.RacunQ.SifraIsporucitelja  = '200326791'
  Spec.RacunQ.NazivIsporucitelja  = 'Karl Dietz Kijevo d.o.o.'
  Spec.RacunQ.DatumObracuna       = '09.01.2026'
  Spec.RacunQ.VrstaPomagala       = '1'
  Spec.RacunQ.DatumNarudzbe       = '05.01.2026'
  Spec.RacunQ.BrojOsobnogRacuna   = '7059'
  Spec.RacunQ.BrojRacDopunsko     = '7059-DOP'
  Spec.RacunQ.BrojPolice          = '87198948'
  Spec.RacunQ.AktivnostObvezno    = '4002026'
  Spec.RacunQ.DatumIzdavanja      = '09.01.2026'
  Spec.RacunQ.Valuta              = 'EUR'
  Spec.RacunQ.MBO                 = '108656533'
  Spec.RacunQ.TipOsiguranja       = HZZO:TipD1
  ADD(Spec.RacunQ)

  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex     = 1
  Spec.StavkaQ.DatumObracuna  = '09.01.2026'
  Spec.StavkaQ.SifraPomagala  = '0209031126005'
  Spec.StavkaQ.Kolicina       = '10.00'
  Spec.StavkaQ.UkupniIznos    = '244.71'
  Spec.StavkaQ.IznosRazCijene = '0.00'
  Spec.StavkaQ.StopaPDV       = '5.00'
  ADD(Spec.StavkaQ)

  bOK = Calc.CalcRacun(Spec.RacunQ, Spec.StavkaQ, 1)
  LogWrite('  CalcRacun vratio: ' & CHOOSE(bOK=1,'1 (OK)','0 (GRESKA)'))

  GET(Spec.RacunQ, 1)
  LogWrite('  UkIznosPomagala   = ''' & CLIP(Spec.RacunQ.UkIznosPomagala)   & ''' ocekivano: ''244.71''')
  LogWrite('  IznosSudjelovanja = ''' & CLIP(Spec.RacunQ.IznosSudjelovanja) & ''' ocekivano: ''0.00''')
  LogWrite('  IznosObveznoSPDV  = ''' & CLIP(Spec.RacunQ.IznosObveznoSPDV)  & ''' ocekivano: ''195.77''')
  LogWrite('  IznosPDVObvezno   = ''' & CLIP(Spec.RacunQ.IznosPDVObvezno)   & ''' ocekivano: ''9.32''')
  LogWrite('  IznosDopunskoSPDV = ''' & CLIP(Spec.RacunQ.IznosDopunskoSPDV) & ''' ocekivano: ''48.94''')
  LogWrite('  IznosPDVDopunsko  = ''' & CLIP(Spec.RacunQ.IznosPDVDopunsko)  & ''' ocekivano: ''2.33''')
  LogWrite('  UkIznosFaktHZZO   = ''' & CLIP(Spec.RacunQ.UkIznosFaktHZZO)   & ''' ocekivano: ''195.77''')
  LogWrite('  UkIznosFaktDop    = ''' & CLIP(Spec.RacunQ.UkIznosFaktDop)     & ''' ocekivano: ''48.94''')

  ! -----------------------------------------------------------------------
  ! CASE 3: Iznos ispod praga (30.00 EUR) → primjenjuje se MinParticipacija
  ! 30.00 x 20% = 6.00 < 8.83 → participacija = 8.83
  ! IznosObvezno = 30.00 - 8.83 = 21.17
  ! -----------------------------------------------------------------------
  LogWrite('')
  LogWrite('  [CASE 3] P1 - iznos 30.00 EUR (ispod MinIznosFact=44.15) → min participacija')

  Spec.ClearAll()
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex     = 1
  Spec.RacunQ.TipOsiguranja  = HZZO:TipP1
  ADD(Spec.RacunQ)

  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex    = 1
  Spec.StavkaQ.UkupniIznos   = '30.00'
  Spec.StavkaQ.IznosRazCijene = '0.00'
  Spec.StavkaQ.StopaPDV      = '5.00'
  ADD(Spec.StavkaQ)

  bOK = Calc.CalcRacun(Spec.RacunQ, Spec.StavkaQ, 1)
  GET(Spec.RacunQ, 1)
  LogWrite('  IznosSudjelovanja = ''' & CLIP(Spec.RacunQ.IznosSudjelovanja) & ''' ocekivano: ''8.83''')
  LogWrite('  IznosObveznoSPDV  = ''' & CLIP(Spec.RacunQ.IznosObveznoSPDV)  & ''' ocekivano: ''21.17''')

  ! -----------------------------------------------------------------------
  ! CASE 4: P0 (izuzet) → sudjelovanje = 0, obvezno = puna baza
  ! -----------------------------------------------------------------------
  LogWrite('')
  LogWrite('  [CASE 4] P0 - izuzet od sudjelovanja, iznos 244.71')

  Spec.ClearAll()
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex     = 1
  Spec.RacunQ.TipOsiguranja  = HZZO:TipP0
  ADD(Spec.RacunQ)

  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex    = 1
  Spec.StavkaQ.UkupniIznos   = '244.71'
  Spec.StavkaQ.IznosRazCijene = '0.00'
  Spec.StavkaQ.StopaPDV      = '5.00'
  ADD(Spec.StavkaQ)

  bOK = Calc.CalcRacun(Spec.RacunQ, Spec.StavkaQ, 1)
  GET(Spec.RacunQ, 1)
  LogWrite('  IznosSudjelovanja = ''' & CLIP(Spec.RacunQ.IznosSudjelovanja) & ''' ocekivano: ''0.00''')
  LogWrite('  IznosObveznoSPDV  = ''' & CLIP(Spec.RacunQ.IznosObveznoSPDV)  & ''' ocekivano: ''244.71''')
  LogWrite('  IznosDopunskoSPDV = ''' & CLIP(Spec.RacunQ.IznosDopunskoSPDV) & ''' ocekivano: '''' (prazno)')

  Calc.Kill()
  Spec.Kill()

!============================================================================
! LogClose - Zatvori log datoteku
!============================================================================
LogClose PROCEDURE()
  CODE
  IF hLogFile <> 0 AND hLogFile <> -1
    log_CloseHandle(hLogFile)
  END
  hLogFile = 0
