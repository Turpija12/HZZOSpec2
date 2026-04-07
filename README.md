# HZZOSpec2 - HZZO Specifikacija osobnog racuna pomagala

Clarion klasa za generiranje datoteka prema HZZO specifikaciji za osobne racune ortopedskih pomagala (dokument OS_POM_25.docx).

## Datoteke

| Datoteka | Opis |
|----------|------|
| `HZZOSpec.INC` | Definicije queue tipova (RacunQ, StavkaQ, ErrorQ) i deklaracija klase `HZZOSpecClass` |
| `HZZOSpec.CLW` | Implementacija svih metoda klase |
| `HZZOCalc.INC` | Deklaracija klase `HZZOCalcClass` + equateovi `HZZO:TipD1/P1/P0` |
| `HZZOCalc.CLW` | Implementacija kalkulatora: participacija, HZZO/dopunsko split, PDV raspad |
| `HZZOReport.CLW` | Demo PROGRAM za generiranje PDF racuna (osnovno i dopunsko osiguranje) |
| `HZZOSpec_Primjer.CLW` | Referentni primjer koristenja |
| `testCLarionApp/HZZOSpecTest2/HZZOSpecTest2.clw` | Testna aplikacija: 5 testova s file logom |
| `OS_POM_25.docx` | Izvorni HZZO dokument specifikacije |
| `primjer/` | Referentni primjeri: slike racuna (OS i DOP), Doznake.pdf, primjer report koda |

## Struktura podataka

### Slog racuna (record 60) - `HZZORacunQType`

32 polja prema specifikaciji. Kljucna polja:

| Polje | Naziv | Format | Obavezno |
|-------|-------|--------|----------|
| 2 | SifraIsporucitelja | N9 | Da (K - Prilog 3) |
| 3 | NazivIsporucitelja | AN(max 45) | Da |
| 4 | BrojOvjerenePotvrde | N(max3)/N(max10) | Uvjetno |
| 5 | DatumObracuna | DD.MM.YYYY | Da |
| 6 | VrstaPomagala | 1,2,3,4,5,7,8 | Da |
| 7 | DatumNarudzbe | DD.MM.YYYY | Da |
| 10 | UkIznosPomagala | N(max9).N2 | Da |
| 14 | IznosObveznoSPDV | N(max9).N2 | Da |
| 18 | MBO | N9 | Uvjetno (K - Prilog 5) |
| 24 | BrojOsobnogRacuna | ANS(max 22) | Da |
| 25 | AktivnostObvezno | N7 | Da |
| 27 | BrojPotvrdeDoktora | N14 | Uvjetno (K - Prilog 8) |
| 28 | IdentifikatorEPotvrde | ANS(max 100) | Uvjetno |
| 29 | DatumIzdavanja | DD.MM.YYYY | Da |
| 31 | OIB | N11 | Uvjetno (K - ISO 7064) |
| 32 | Valuta | A3 (EUR) | Da |

### Stavke pomagala (record 61) - `HZZOStavkaQType`

12 polja prema specifikaciji. Kljucna polja:

| Polje | Naziv | Format | Obavezno |
|-------|-------|--------|----------|
| 2 | BrojOvjerenePotvrde | N(max3)/N(max10) | Uvjetno |
| 3 | DatumObracuna | DD.MM.YYYY | Da |
| 4 | SifraPomagala | 7/12/13 znakova | Da |
| 5 | Kolicina | N(max5).N2 | Da |
| 6 | UkupniIznos | N(max9).N2 | Da |
| 8 | BrojPotvrdeDoktora | N14 | Uvjetno (K - Prilog 8) |

### Queue gresaka - `HZZOErrorQType`

| Polje | Tip | Opis |
|-------|-----|------|
| RacunIndex | LONG | Indeks racuna (0 = globalno) |
| StavkaIndex | LONG | Indeks stavke (0 = racun-level) |
| TipSloga | STRING(2) | '60' ili '61' |
| RedniBrPolja | BYTE | Redni broj polja prema specifikaciji |
| NazivPolja | STRING(40) | Naziv polja |
| Poruka | STRING(200) | Opis greske |

## API klase

### Javne metode

```
Init()                                          ! Inicijalizacija (alokacija queue-ova)
Kill()                                          ! Oslobadjanje resursa
ClearAll()                                      ! Brisanje svih podataka
Validate() -> BOOL                              ! TRUE=sve ispravno, FALSE=greske u ErrorQ
Export(STRING pFileName) -> BOOL                 ! Validira + pise datoteku
GenerateFileName(STRING, STRING, LONG, LONG) -> STRING  ! Generira naziv prema spec
GetErrorCount() -> LONG                         ! Broj gresaka u ErrorQ
DateToStr(LONG pDate) -> STRING                  ! Clarion datum -> 'DD.MM.YYYY' (0 -> '00.00.0000')
StrToDate(STRING pDatumVrijeme) -> LONG          ! 'DD.MM.YYYY - HH:MM' -> Clarion datum (0=greska)
StrToTime(STRING pDatumVrijeme) -> LONG          ! 'DD.MM.YYYY - HH:MM' -> Clarion vrijeme (centisekunde)
Report(LONG pRacunIndex, BYTE pVrsta, STRING pPdfPath)  ! Generira PDF racun
                                                !   pVrsta=1: osnovno ZO, pVrsta=2: dopunsko ZO
                                                !   pPdfPath='': print preview
```

### Pristup queue-ovima

Queue-ovi su javni, korisnik ih direktno puni:

```
Spec.RacunQ    ! &HZZORacunQType  - racuni
Spec.StavkaQ   ! &HZZOStavkaQType - stavke
Spec.ErrorQ    ! &HZZOErrorQType  - greske (readonly - puni klasa)
```

## Kalkulator iznosa (HZZOCalcClass)

`HZZOCalcClass` automatski izracunava sva financijska polja u `RacunQ` na temelju iznosa stavki i tipa osiguranja pacijenta. Koristi se zajedno s `HZZOSpecClass`.

### Tipovi osiguranja (TipOsiguranja)

| Equate | Vrijednost | Opis |
|--------|-----------|------|
| `HZZO:TipD1` | `'D1'` | Ima dopunsko HZZO osiguranje — pacijent placa 0€ |
| `HZZO:TipP1` | `'P1'` | Nema dopunsko — pacijent placa participaciju |
| `HZZO:TipP0` | `'P0'` | Izuzet od sudjelovanja (djeca, RVI...) |

### Pravila izracuna

```
participacija = MAX(8.83, MIN(bazaHZZO × 20%, 530.88))

bazaHZZO = UkIznosPomagala - UkIznosRazCijene

D1: IznosSudjelovanja = 0,            IznosDopunskoSPDV = participacija
P1: IznosSudjelovanja = participacija, IznosDopunskoSPDV = ''
P0: IznosSudjelovanja = 0,            IznosDopunskoSPDV = ''

IznosObveznoSPDV = bazaHZZO - participacija   (isti za sve tipove)
```

PDV raspad: proporcionalni po omjeru `TotalBezPDV / TotalSPDV` — ispravno radi za vise PDV stopa (5% i 25%) na istom racunu.

### Konfigurilne konstante (2025/2026)

| Konstanta | Default | Opis |
|-----------|---------|------|
| `MinParticipacija` | 8.83 | = 2% proracunske osnovice |
| `MaxParticipacija` | 530.88 | = 120.26% proracunske osnovice |
| `StopaParticipacije` | 0.2000 | 20% — standardna stopa za ortopedska pomagala |
| `MaxIznosFact` | 2654.40 | = 530.88 × 5 — gornja granica HZZO priznatog troska |

### API HZZOCalcClass

```
Init()
Kill()
SetKonstante(DECIMAL pMin, DECIMAL pMax, DECIMAL pStopa)   ! ako se promijeni proracunska osnovica
CalcRacun(&HZZORacunQType, &HZZOStavkaQType, LONG pRacunIdx) -> BYTE  ! 1=OK, 0=greska
```

### Calc-input polja

- `RacunQ.TipOsiguranja STRING(2)` — mora biti postavljeno prije poziva CalcRacun
- `StavkaQ.StopaPDV STRING(5)` — mora biti postavljeno za svaku stavku (npr. `'5.00'` ili `'25.00'`)

### Primjer koristenja

```clarion
INCLUDE('HZZOCalc.INC'),ONCE   ! ukljucuje i HZZOSpec.INC automatski

Calc   HZZOCalcClass
Spec   HZZOSpecClass

  Calc.Init()
  Spec.Init()

  ! Punimo RacunQ i StavkaQ (stavke s iznosima s PDV)
  Spec.RacunQ.TipOsiguranja = HZZO:TipP1    ! P1=nema dopunskog
  ! ... ostala obavezna polja ...
  ADD(Spec.RacunQ)

  Spec.StavkaQ.UkupniIznos    = '244.71'    ! iznos S PDV-om
  Spec.StavkaQ.IznosRazCijene = '0.00'
  Spec.StavkaQ.StopaPDV       = '5.00'
  ADD(Spec.StavkaQ)

  ! Kalkulator automatski puni sva iznos-polja u RacunQ
  Calc.CalcRacun(Spec.RacunQ, Spec.StavkaQ, 1)

  ! Sada su postavljeni: UkIznosPomagala=244.71, IznosSudjelovanja=48.94,
  !                      IznosObveznoSPDV=195.77, IznosPDVObvezno=9.32, itd.
  Spec.Export('060200326791001.O25')
```

## PDF report (Spec.Report)

Metoda `Report` generira PDF racun (jednu stranicu A4) za osnovno ili dopunsko zdravstveno osiguranje. Layout odgovara uzorcima u `primjer/RacunZaOsnovnoOsiguranje.jpg` i `primjer/RacunZaDopunskoOsiguranje.jpg`.

### Report-only polja u `HZZORacunQType`

Ova polja nisu dio HZZO export formata (Export/Validate ih ignoriraju) — koriste se isključivo za ispis:

| Polje | Tip | Opis |
|-------|-----|------|
| SifraMaloprodajneLokacije | STRING(10) | Sifra mjesta isporuke isporucitelja |
| AdresaIsporucitelja | STRING(80) | Grad, ulica i broj isporucitelja |
| ZiroRacun | STRING(34) | IBAN ziro racun isporucitelja |
| MaticniBroj | STRING(8) | Maticni broj isporucitelja |
| OIBIsporucitelja | STRING(11) | OIB isporucitelja |
| PozivNaBroj | STRING(22) | Poziv na broj placanja |
| MjestoIzdavanja | STRING(50) | Mjesto izdavanja racuna |
| HZZOPodrucniUred | STRING(60) | Naziv HZZO podrucnog ureda (npr. 'HZZO PU Sibenik (083)') |
| HZZOMjesto | STRING(40) | Grad HZZO podrucnog ureda |
| HZZOUlicaBroj | STRING(50) | Ulica i broj HZZO PU |
| HZZOOIB | STRING(11) | OIB HZZO PU |

### Report-only polja u `HZZOStavkaQType`

| Polje | Tip | Opis |
|-------|-----|------|
| NazivPomagala | STRING(100) | Naziv pomagala za tablicu u reportu |
| JedCijenaEur | STRING(12) | Jedinicna cijena EUR s PDV-om (N.NNNN) |
| StopaPDV | STRING(5) | Stopa PDV-a (N.NN, npr. '5.00' ili '25.00') |
| JedRazlikaEur | STRING(12) | Jedinicna razlika u cijeni EUR s PDV-om (N.NNNN) |

### Razlika OS vs DOP

- **pVrsta=1** (osnovno): 5 financijskih redaka, sakrivena "Br. police" labela
- **pVrsta=2** (dopunsko): 6 financijskih redaka, vidljiva polica, redak 5 = "Iznos na teret dopunskog ZO", redak 6 = "Iznos PDV-a u tocki 5."

### PDF generiranje

```clarion
! Pripremi report-only polja
Spec.RacunQ.NazivIsporucitelja = 'Moja ljekarna'
Spec.RacunQ.AdresaIsporucitelja = 'Zagreb, Ilica 1'
Spec.RacunQ.ZiroRacun          = 'HR1234567890123456789'
! ... ostala polja ...
Spec.StavkaQ.NazivPomagala     = 'Naziv pomagala'
Spec.StavkaQ.JedCijenaEur      = '10.5000'
Spec.StavkaQ.StopaPDV          = '5.00'
Spec.StavkaQ.JedRazlikaEur     = '0.0000'

! Generiraj PDF
Spec.Report(1, 1, 'racun_osnovno.pdf')   ! osnovno ZO
Spec.Report(1, 2, 'racun_dopunsko.pdf')  ! dopunsko ZO
Spec.Report(1, 1, '')                    ! print preview
```

## Validacije

Klasa provodi sljedece validacije:

### Format
- Sva obavezna polja moraju biti popunjena
- Datumi u formatu DD.MM.YYYY (s provjerom ispravnosti kalendara)
- Iznosi u formatu N(max9).N2 (npr. "17.77", "0.00")
- Numericki podaci odgovarajuce duljine
- Nijedan podatak ne smije sadrzavati dvotocku (delimiter)

### Kontrolne znamenke
- **Sifra isporucitelja** - mod 11 prema Prilogu 3
- **MBO** (maticni broj osigurane osobe) - mod 11 prema Prilogu 5
- **Broj potvrde doktora** - mod 11 (14 znamenki) prema Prilogu 8
- **OIB** - ISO 7064, MOD 11,10

### Poslovna pravila
- Vrsta pomagala mora biti 1, 2, 3, 4, 5, 7 ili 8
- Valuta mora biti EUR
- Datum obracuna >= datum narudzbe
- Datum narudzbe <= datum izdavanja
- Identifikacija osiguranika: MBO ili OIB ili INO podaci (polja 19+20)
- Identifikacija potvrde: barem jedan od - broj ovjerene potvrde, broj potvrde doktora, ePotvrda
- Svaki racun mora imati barem jednu stavku

## Format izlazne datoteke

- Delimiter: dvotocka `:` (ASCII 58)
- Kraj retka: CR/LF (ASCII 13+10)
- Struktura: slog 60, pa stavke 61 za taj racun, sljedeci slog 60...
- Svaki redak zavrsava trailing dvotockom
- Naziv datoteke: `aaabbbbbbbbbcccc.Ozz`
  - `aaa` = sifra podrucne sluzbe (3 znamenke)
  - `bbbbbbbbb` = sifra isporucitelja (9 znamenki)
  - `cccc` = redni broj datoteke u godini
  - `O` = konstanta za ortopedska pomagala
  - `zz` = godina (2 znamenke)

## Brzi primjer

```clarion
Spec  HZZOSpecClass

  CODE
  Spec.Init()

  ! Dodaj racun
  CLEAR(Spec.RacunQ)
  Spec.RacunQ.RacunIndex          = 1
  Spec.RacunQ.SifraIsporucitelja  = '200326791'
  Spec.RacunQ.NazivIsporucitelja  = 'Moja ljekarna'
  Spec.RacunQ.DatumObracuna       = '15.03.2025'
  Spec.RacunQ.VrstaPomagala       = '7'
  Spec.RacunQ.DatumNarudzbe       = '10.03.2025'
  Spec.RacunQ.UkIznosPomagala     = '156.00'
  Spec.RacunQ.IznosSudjelovanja   = '0.00'
  Spec.RacunQ.IznosObveznoSPDV    = '156.00'
  Spec.RacunQ.IznosPDVObvezno     = '7.43'
  Spec.RacunQ.MBO                 = '100000112'
  Spec.RacunQ.UkIznosFaktHZZO     = '0.00'
  Spec.RacunQ.BrojOsobnogRacuna   = '1/2025'
  Spec.RacunQ.AktivnostObvezno    = '10055'
  Spec.RacunQ.IdentifikatorEPotvrde = 'abc123-ePotvrda'
  Spec.RacunQ.DatumIzdavanja      = '15.03.2025'
  Spec.RacunQ.Valuta              = 'EUR'
  ADD(Spec.RacunQ)

  ! Dodaj stavku
  CLEAR(Spec.StavkaQ)
  Spec.StavkaQ.RacunIndex         = 1
  Spec.StavkaQ.DatumObracuna      = '15.03.2025'
  Spec.StavkaQ.SifraPomagala      = '032112080301'
  Spec.StavkaQ.Kolicina           = '150.00'
  Spec.StavkaQ.UkupniIznos        = '156.00'
  Spec.StavkaQ.IdentifikatorEPotvrde = 'abc123-ePotvrda'
  Spec.StavkaQ.IznosRazCijene     = '0.00'
  ADD(Spec.StavkaQ)

  ! Export
  IF NOT Spec.Export('060200326791001.O25')
    ! Ispis gresaka
    LOOP I# = 1 TO RECORDS(Spec.ErrorQ)
      GET(Spec.ErrorQ, I#)
      ! Spec.ErrorQ.Poruka sadrzi opis greske
    END
  END

  Spec.Kill()
```

## Napomene

- Svi podaci u queue-ovima su STRING tip - korisnik ih puni kao stringove
- Veza stavke -> racun ostvaruje se preko polja `RacunIndex` (LONG)
- `Export()` automatski poziva `Validate()` - nije potrebno zvati zasebno
- Za samo validaciju bez exporta, koristite `Validate()` direktno
- Greske se nalaze u `ErrorQ` nakon poziva `Validate()` ili `Export()`
- Klasa koristi Win32 API (WriteFile) za ispis u datoteku, CR/LF se dodaje eksplicitno
- Svi source fajlovi moraju biti snimljeni s **Windows (CRLF) line endings** - Clarion compiler ne podrzava Unix LF
