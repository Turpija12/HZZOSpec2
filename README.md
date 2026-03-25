# HZZOSpec2 - HZZO Specifikacija osobnog racuna pomagala

Clarion klasa za generiranje datoteka prema HZZO specifikaciji za osobne racune ortopedskih pomagala (dokument OS_POM_25.docx).

## Datoteke

| Datoteka | Opis |
|----------|------|
| `HZZOSpec.INC` | Definicije queue tipova (RacunQ, StavkaQ, ErrorQ) i deklaracija klase `HZZOSpecClass` |
| `HZZOSpec.CLW` | Implementacija svih metoda klase |
| `HZZOSpec_Primjer.CLW` | Referentni primjer koristenja |
| `testCLarionApp/HZZOSpecTest2/HZZOSpecTest2.clw` | Testna aplikacija: 3 testa (1 racun, vise racuna, neispravni podaci) s file logom |
| `OS_POM_25.docx` | Izvorni HZZO dokument specifikacije |

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
```

### Pristup queue-ovima

Queue-ovi su javni, korisnik ih direktno puni:

```
Spec.RacunQ    ! &HZZORacunQType  - racuni
Spec.StavkaQ   ! &HZZOStavkaQType - stavke
Spec.ErrorQ    ! &HZZOErrorQType  - greske (readonly - puni klasa)
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
