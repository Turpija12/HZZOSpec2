!============================================================================
! HZZOSpec_Primjer.CLW - Primjer koristenja HZZOSpecClass klase
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

  MAP
    PrimjerIspravniPodaci  PROCEDURE()
    PrimjerNeispravniPodaci PROCEDURE()
    PrikaziGreske          PROCEDURE(HZZOSpecClass pSpec)
  END

Spec   HZZOSpecClass                ! Instanca klase
I      LONG

  CODE
  MESSAGE('=== HZZO Spec Primjer ===','Pocetak')

  ! --- Primjer 1: Ispravni podaci ---
  PrimjerIspravniPodaci()

  ! --- Primjer 2: Neispravni podaci (demonstracija validacijskih gresaka) ---
  PrimjerNeispravniPodaci()

  MESSAGE('Gotovo!','Kraj')

!============================================================================
! PrimjerIspravniPodaci - Demonstracija s ispravnim podacima iz specifikacije
! Podaci preuzeti iz Priloga 7 dokumenta OS_POM_25.docx
!============================================================================
PrimjerIspravniPodaci PROCEDURE()
Spec       HZZOSpecClass
sFileName  STRING(30)
sFullPath  STRING(260)
bResult    BOOL
  CODE
  Spec.Init()

  !--- Punjenje racuna (vodeci slog 60) ---
  ! Podaci iz primjera u specifikaciji (Prilog 7)
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex          = 1
  Spec.RacunQ.SifraIsporucitelja  = '200326791'
  Spec.RacunQ.NazivIsporucitelja  = 'Ustanova 1'
  Spec.RacunQ.BrojOvjerenePotvrde = ''                    ! Prazno - koristi se ePotvrda
  Spec.RacunQ.DatumObracuna       = '02.01.2023'
  Spec.RacunQ.VrstaPomagala       = '7'                   ! Za secernu bolest
  Spec.RacunQ.DatumNarudzbe       = '02.01.2023'
  Spec.RacunQ.BrojRacDopunsko     = '25/2023-D'           ! Racun za dopunsko osig.
  Spec.RacunQ.BrojPolice          = '10042090'
  Spec.RacunQ.UkIznosPomagala     = '17.77'
  Spec.RacunQ.IznosSudjelovanja   = '0.00'
  Spec.RacunQ.IznosDopunskoSPDV   = '6.62'
  Spec.RacunQ.IznosPDVDopunsko    = '0.32'
  Spec.RacunQ.IznosObveznoSPDV    = '11.15'
  Spec.RacunQ.IznosPDVObvezno     = '0.53'
  Spec.RacunQ.NeKoristiSe1        = ''                    ! Prazno
  Spec.RacunQ.NeKoristiSe2        = ''                    ! Prazno
  Spec.RacunQ.MBO                 = '123456789'           ! Maticni broj osiguranika
  Spec.RacunQ.BrojBolesnickogLista = ''
  Spec.RacunQ.Drzava              = ''
  Spec.RacunQ.SifraProizvodjaca   = ''                    ! Prazno - ide u stavke
  Spec.RacunQ.UkIznosFaktHZZO     = '0.00'
  Spec.RacunQ.UkIznosFaktDop      = '0.00'
  Spec.RacunQ.BrojOsobnogRacuna   = '25/2023'
  Spec.RacunQ.AktivnostObvezno    = '10055'
  Spec.RacunQ.AktivnostDopunsko   = '11201'
  Spec.RacunQ.BrojPotvrdeDoktora  = ''
  Spec.RacunQ.IdentifikatorEPotvrde = '7773017bf16f2155b-xebe68d184545c21027cf1'
  Spec.RacunQ.DatumIzdavanja      = '02.01.2023'
  Spec.RacunQ.UkIznosRazCijene    = '0.00'
  Spec.RacunQ.OIB                 = ''
  Spec.RacunQ.Valuta              = 'EUR'
  ADD(Spec.RacunQ)

  !--- Punjenje stavke 1 (slog 61) ---
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex          = 1                    ! Veza na racun iznad
  Spec.StavkaQ.BrojOvjerenePotvrde = ''
  Spec.StavkaQ.DatumObracuna       = '02.01.2023'
  Spec.StavkaQ.SifraPomagala       = '0324120807006'      ! 13-znamenkasta sifra
  Spec.StavkaQ.Kolicina            = '50.00'
  Spec.StavkaQ.UkupniIznos         = '15.12'
  Spec.StavkaQ.SifraProizvodjaca   = '10250'
  Spec.StavkaQ.BrojPotvrdeDoktora  = ''
  Spec.StavkaQ.SifraVelicineObloge = ''
  Spec.StavkaQ.IdentifikacijaPomagala = ''
  Spec.StavkaQ.IdentifikatorEPotvrde  = '7773017bf16f2155b-xebe68d184545c21027cf1'
  Spec.StavkaQ.IznosRazCijene      = '0.00'
  ADD(Spec.StavkaQ)

  !--- Punjenje stavke 2 (slog 61) ---
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex          = 1                    ! Isti racun
  Spec.StavkaQ.BrojOvjerenePotvrde = ''
  Spec.StavkaQ.DatumObracuna       = '02.01.2023'
  Spec.StavkaQ.SifraPomagala       = '0321120808003'      ! 13-znamenkasta sifra
  Spec.StavkaQ.Kolicina            = '50.00'
  Spec.StavkaQ.UkupniIznos         = '2.65'
  Spec.StavkaQ.SifraProizvodjaca   = '10250'
  Spec.StavkaQ.BrojPotvrdeDoktora  = ''
  Spec.StavkaQ.SifraVelicineObloge = ''
  Spec.StavkaQ.IdentifikacijaPomagala = ''
  Spec.StavkaQ.IdentifikatorEPotvrde  = '7773017bf16f2155b-xebe68d184545c21027cf1'
  Spec.StavkaQ.IznosRazCijene      = '0.00'
  ADD(Spec.StavkaQ)

  !--- Samo validacija (bez exporta) ---
  bResult = Spec.Validate()
  IF bResult
    MESSAGE('Validacija uspjesna! Nema gresaka.','Validacija')
  ELSE
    MESSAGE('Validacija neuspjesna! Broj gresaka: ' & Spec.GetErrorCount(),'Validacija')
    PrikaziGreske(Spec)
  END

  !--- Generiranje naziva datoteke ---
  ! Parametri: sifra podrucne sluzbe, sifra isporucitelja, redni broj, godina
  sFileName = Spec.GenerateFileName('060','200326791', 1, 2023)
  ! Rezultat: 060200326791001.O23
  MESSAGE('Generirani naziv datoteke: ' & sFileName,'Naziv datoteke')

  !--- Export u datoteku ---
  sFullPath = '.\' & sFileName
  bResult = Spec.Export(sFullPath)
  IF bResult
    MESSAGE('Export uspjesan!' & '<13,10>' & 'Datoteka: ' & CLIP(sFullPath),'Export')
  ELSE
    MESSAGE('Export neuspjesan! Broj gresaka: ' & Spec.GetErrorCount(),'Export')
    PrikaziGreske(Spec)
  END

  Spec.Kill()

!============================================================================
! PrimjerNeispravniPodaci - Demonstracija validacijskih gresaka
!============================================================================
PrimjerNeispravniPodaci PROCEDURE()
Spec    HZZOSpecClass
bResult BOOL
  CODE
  Spec.Init()

  !--- Racun s namjernim greskama ---
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex          = 1
  Spec.RacunQ.SifraIsporucitelja  = '123456780'        ! Kriva kontrolna znamenka!
  Spec.RacunQ.NazivIsporucitelja  = ''                  ! Prazan - obavezan!
  Spec.RacunQ.DatumObracuna       = '31.13.2023'        ! Neispravan datum (mjesec 13)!
  Spec.RacunQ.VrstaPomagala       = '6'                 ! Nedozvoljena vrsta (6 ne postoji)!
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
  Spec.RacunQ.Valuta              = 'USD'               ! Kriva valuta - mora biti EUR!
  ADD(Spec.RacunQ)

  !--- Stavka s greskama ---
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex         = 1
  Spec.StavkaQ.DatumObracuna      = '02.01.2023'
  Spec.StavkaQ.SifraPomagala      = '123'               ! Kriva duljina sifre!
  Spec.StavkaQ.Kolicina           = '50'                ! Nema decimala - treba 50.00!
  Spec.StavkaQ.UkupniIznos        = '15.12'
  ADD(Spec.StavkaQ)

  !--- Validacija - ocekujemo greske ---
  bResult = Spec.Validate()
  MESSAGE('Neispravni podaci - Broj gresaka: ' & Spec.GetErrorCount(),'Test neispravnih')
  PrikaziGreske(Spec)

  Spec.Kill()

!============================================================================
! PrikaziGreske - Prikazuje sve greske iz ErrorQ
!============================================================================
PrikaziGreske PROCEDURE(HZZOSpecClass pSpec)
I      LONG
sMsg   STRING(2000)
sLine  STRING(300)
  CODE
  sMsg = 'Popis gresaka:' & '<13,10>' & '<13,10>'
  LOOP I = 1 TO RECORDS(pSpec.ErrorQ)
    GET(pSpec.ErrorQ, I)
    sLine = 'Slog ' & CLIP(pSpec.ErrorQ.TipSloga)      |
      & ' | Racun:' & pSpec.ErrorQ.RacunIndex           |
      & ' | Stavka:' & pSpec.ErrorQ.StavkaIndex          |
      & ' | Polje ' & pSpec.ErrorQ.RedniBrPolja          |
      & ' (' & CLIP(pSpec.ErrorQ.NazivPolja) & ')'       |
      & '<13,10>'                                        |
      & '  -> ' & CLIP(pSpec.ErrorQ.Poruka)              |
      & CHOOSE(CLIP(pSpec.ErrorQ.VrijednostPolja)<>'', |
          ' [vrijednost: ''' & CLIP(pSpec.ErrorQ.VrijednostPolja) & ''']', '') |
      & '<13,10>'
    sMsg = CLIP(sMsg) & CLIP(sLine) & '<13,10>'
    ! Izlaz ako je prevelik za prikaz
    IF LEN(CLIP(sMsg)) > 1500
      sMsg = CLIP(sMsg) & '... (jos ' & (RECORDS(pSpec.ErrorQ) - I) & ' gresaka)'
      BREAK
    END
  END
  MESSAGE(sMsg,'Greske validacije')
