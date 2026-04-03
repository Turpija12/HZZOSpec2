# CLAUDE.md - HZZOSpec2

## Što je ovaj projekt?

Clarion klasa `HZZOSpecClass` za generiranje izvoznih datoteka prema **HZZO specifikaciji osobnog računa ortopedskih pomagala** (dokument `OS_POM_25.docx`).

Klasa prima podatke o računima i stavkama, validira ih prema spec-u i piše izlaznu datoteku formata `aaabbbbbbbbbcccc.Ozz` (colon-delimited, CRLF).

## Ključne datoteke

| Datoteka | Uloga |
|----------|-------|
| `HZZOSpec.INC` | Deklaracija klase i queue tipova — **ovo se includea u aplikaciju** |
| `HZZOSpec.CLW` | Implementacija svih metoda — **ovo se dodaje u cwproj** |
| `HZZOSpec_Primjer.CLW` | Referentni primjer korištenja |
| `testCLarionApp/HZZOSpecTest2/` | Testna aplikacija s 3 testa i file logom |
| `OS_POM_25.docx` | Izvorni HZZO dokument specifikacije |

## Kako koristiti u drugoj Clarion aplikaciji

1. Kopiraj `HZZOSpec.INC` i `HZZOSpec.CLW` u folder ciljne aplikacije
2. U cwproj dodaj: `<Compile Include="HZZOSpec.CLW" />`
3. U CLW koji koristi klasu: `INCLUDE('HZZOSpec.INC')`
4. Deklariraj instancu: `Spec  HZZOSpecClass`

## API klase

```clarion
Spec.Init()                                      ! Inicijalizacija (mora se pozvati prvo)
Spec.Kill()                                      ! Oslobađanje resursa (na kraju)
Spec.ClearAll()                                  ! Brisanje svih podataka iz queue-ova

Spec.Validate() -> BOOL                          ! Samo validacija; greške u Spec.ErrorQ
Spec.Export('putanja\datoteka.Ozz') -> BOOL      ! Validira + piše datoteku

Spec.GenerateFileName('060','200326791',1,2025)  ! Generira naziv: 0602003267910001.O25
Spec.GetErrorCount() -> LONG                     ! Broj grešaka u ErrorQ
Spec.DateToStr(TODAY()) -> STRING                ! Clarion LONG datum -> 'DD.MM.YYYY'
```

## Struktura podataka

Korisnik direktno puni queue-ove (sva polja su STRING):

```clarion
! --- Račun (slog 60, 32 polja) ---
Spec.RacunQ.RacunIndex           ! LONG - ključ veze s stavkama
Spec.RacunQ.SifraIsporucitelja   ! N9, kontrolna znamenka mod 11 (Prilog 3)
Spec.RacunQ.NazivIsporucitelja   ! AN max 45, obavezno
Spec.RacunQ.DatumObracuna        ! DD.MM.YYYY, obavezno
Spec.RacunQ.VrstaPomagala        ! '1','2','3','4','5','7' ili '8'
Spec.RacunQ.DatumNarudzbe        ! DD.MM.YYYY, obavezno
Spec.RacunQ.UkIznosPomagala      ! N.NN format, obavezno
Spec.RacunQ.IznosObveznoSPDV     ! N.NN format, obavezno
Spec.RacunQ.MBO                  ! N9, kontrolna znamenka mod 11 (Prilog 5) - ili OIB ili INO
Spec.RacunQ.OIB                  ! N11, ISO 7064 MOD 11,10 - ili MBO ili INO
Spec.RacunQ.BrojOsobnogRacuna    ! ANS max 22, obavezno
Spec.RacunQ.AktivnostObvezno     ! N7, obavezno (HZZO šifra aktivnosti OZO)
Spec.RacunQ.IdentifikatorEPotvrde ! ANS max 100 - ili BrojOvjerenePotvrde ili BrojPotvrdeDoktora
Spec.RacunQ.DatumIzdavanja       ! DD.MM.YYYY, obavezno
Spec.RacunQ.Valuta               ! mora biti 'EUR'
ADD(Spec.RacunQ)

! --- Stavka (slog 61, 12 polja) ---
Spec.StavkaQ.RacunIndex          ! LONG - veza na RacunQ.RacunIndex
Spec.StavkaQ.DatumObracuna       ! DD.MM.YYYY
Spec.StavkaQ.SifraPomagala       ! 7, 12 ili 13 znakova
Spec.StavkaQ.Kolicina            ! N.NN format
Spec.StavkaQ.UkupniIznos         ! N.NN format
ADD(Spec.StavkaQ)

! --- Greške (readonly, puni klasa) ---
Spec.ErrorQ.RacunIndex           ! LONG
Spec.ErrorQ.StavkaIndex          ! LONG
Spec.ErrorQ.TipSloga             ! '60' ili '61'
Spec.ErrorQ.RedniBrPolja         ! BYTE
Spec.ErrorQ.NazivPolja           ! STRING(40)
Spec.ErrorQ.Poruka               ! STRING(200)
```

## Poznati detalji i zamke

### CRLF — kritično
Sve CLW/INC datoteke moraju biti snimljene s **Windows (CRLF)** line endings.
Simptom LF-only datoteke: `(1,36916) : Error : Expected: PROGRAM PRAGMA`

### LEN() zamka
`LEN(STRING_VAR)` uvijek vraća DEKLARIRANE duljinu, ne sadržaj.
Uvijek koristiti `LEN(CLIP(var))` kad treba duljina sadržaja.

### HZZOSpec.CLW je MEMBER() modul
Ne smije imati `PROGRAM` — samo `MEMBER()` na vrhu.

### Export koristi Win32 API
`CreateFileA` / `WriteFile` / `CloseHandle` — ne Clarion FILE driver.

### Kontrolne znamenke
- SifraIsporucitelja: mod 11, težine 9,8,7,6,5,4,3,2
- MBO: mod 11, težine 7,6,5,4,3,2,7,6
- BrojPotvrdeDoktora: mod 11 (14 znamenki), težine 7,6,5,4,3,2,7,6,5,4,3,2,7
- OIB: ISO 7064 MOD 11,10

### DECIMAL kao parametar — nije podržano
`DECIMAL(p,s)` se **ne može koristiti kao tip VALUE parametra** u `PROCEDURE` deklaracijama.
- U `.INC` CLASS deklaraciji i kao lokalne varijable u `.CLW` — OK
- Kao parametar procedure/metode → koristiti `REAL`
- Greška: `Invalid data type for value parameter`

### Queue referenca u parametrima procedure
Za prolaz queue-a by reference u procedure parametrima koristiti `*QueueType`, ne `&QueueType`.
- `&QueueType` je za deklaraciju reference varijable (van procedure)
- `*QueueType pQ` je ispravna sintaksa za procedure parametar
- Greška: `Expected: <ID> ) * < CONST`

### Return type u CLW implementaciji
U `.CLW` implementaciji metode se **NE ponavlja return type** (`,STRING`, `,BYTE` itd.).
Return type se deklarira samo jednom — u `.INC` CLASS bloku.
- Ispravno: `MyClass.GetName PROCEDURE(LONG pId)`
- Pogrešno: `MyClass.GetName PROCEDURE(LONG pId),STRING`
- Greška: `Expected: <LINEBREAK> ;`

### PROP:OutputFile nije dostupan
`REPORT{PROP:OutputFile}` ne postoji u Clarion 11.1EE.
Za PDF ispis koristiti `SYSTEM{PROP:PrintMode} = 3` prije `OPEN(Report)`.

### Poznate ispravne test vrijednosti
- MBO `'123456782'` (KZ=2), MBO `'987654325'` (KZ=5)
- OIB `'12345678903'` (KZ=3)
- SifraIsporucitelja `'200326791'`

## Format izlazne datoteke
- Delimiter: dvotočka `:`
- Kraj retka: CR+LF
- Redoslijed: slog 60, pa stavke 61 za taj račun, sljedeći slog 60...
- Svaki redak završava trailing dvotočkom
