!============================================================================
! HZZOSpec.INC - HZZO Specifikacija osobnog racuna pomagala
! Bazirana na dokumentu OS_POM_25.docx
! Slog racuna (60) + Stavke pomagala (61)
!============================================================================
  OMIT('_EndOfInclude_',_HZZOSpecDefined_)
_HZZOSpecDefined_ EQUATE(1)

HZZO:Delimiter        EQUATE(':')
HZZO:MaxFieldsRacun   EQUATE(32)
HZZO:MaxFieldsStavka  EQUATE(12)

!--- Queue tip za vodeci slog racuna (record 60) - 32 polja ---
HZZORacunQType        QUEUE,TYPE
RacunIndex              LONG                  ! Interni indeks racuna (1,2,3...)
SifraIsporucitelja      STRING(9)             ! Polje 2:  N9, obavezno, K Prilog3
NazivIsporucitelja      STRING(45)            ! Polje 3:  AN(max 45), obavezno
BrojOvjerenePotvrde     STRING(14)            ! Polje 4:  N(max3)/N(max10), uvjetno
DatumObracuna           STRING(10)            ! Polje 5:  DD.MM.YYYY, obavezno
VrstaPomagala           STRING(1)             ! Polje 6:  N1 (1,2,3,4,5,7,8), obavezno
DatumNarudzbe           STRING(10)            ! Polje 7:  DD.MM.YYYY, obavezno
BrojRacDopunsko         STRING(22)            ! Polje 8:  ANS(max 22), uvjetno
BrojPolice              STRING(8)             ! Polje 9:  N8, uvjetno
UkIznosPomagala         STRING(12)            ! Polje 10: N(max9).N2, obavezno
IznosSudjelovanja       STRING(12)            ! Polje 11: N(max9).N2, obavezno
IznosDopunskoSPDV       STRING(12)            ! Polje 12: N(max9).N2, uvjetno
IznosPDVDopunsko        STRING(12)            ! Polje 13: N(max9).N2, uvjetno
IznosObveznoSPDV        STRING(12)            ! Polje 14: N(max9).N2, obavezno
IznosPDVObvezno         STRING(12)            ! Polje 15: N(max9).N2, obavezno
NeKoristiSe1            STRING(8)             ! Polje 16: N8, nije obavezno
NeKoristiSe2            STRING(3)             ! Polje 17: N3, nije obavezno
MBO                     STRING(9)             ! Polje 18: N9, uvjetno*, K Prilog5
BrojBolesnickogLista    STRING(20)            ! Polje 19: N(max3)/N(max8) ili AN(20), INO
Drzava                  STRING(3)             ! Polje 20: A3, INO
SifraProizvodjaca       STRING(10)            ! Polje 21: N10, ne (prazno)
UkIznosFaktHZZO         STRING(12)            ! Polje 22: N(max9).N2, obavezno
UkIznosFaktDop          STRING(12)            ! Polje 23: N(max9).N2, uvjetno
BrojOsobnogRacuna       STRING(22)            ! Polje 24: ANS(max 22), obavezno
AktivnostObvezno        STRING(7)             ! Polje 25: N7, obavezno
AktivnostDopunsko       STRING(5)             ! Polje 26: N5, nije obavezno
BrojPotvrdeDoktora      STRING(14)            ! Polje 27: N14, uvjetno, K Prilog8
IdentifikatorEPotvrde   STRING(100)           ! Polje 28: ANS(max 100), uvjetno
DatumIzdavanja          STRING(10)            ! Polje 29: DD.MM.YYYY, obavezno
UkIznosRazCijene        STRING(12)            ! Polje 30: N(max9).N2, nije obavezno
OIB                     STRING(11)            ! Polje 31: N11, uvjetno*, K ISO7064
Valuta                  STRING(3)             ! Polje 32: A3, obavezno (EUR)
! --- Polja za report (nisu u HZZO export formatu - dodana na kraju) ---
SifraMaloprodajneLokacije STRING(10)          ! Sifra maloprodajne lokacije isporucitelja
AdresaIsporucitelja       STRING(80)          ! Grad, ulica i broj isporucitelja
ZiroRacun                 STRING(34)          ! IBAN ziro racun isporucitelja
MaticniBroj               STRING(8)           ! Maticni broj isporucitelja
OIBIsporucitelja          STRING(11)          ! OIB isporucitelja
PozivNaBroj               STRING(22)          ! Poziv na broj placanja
MjestoIzdavanja           STRING(50)          ! Mjesto izdavanja racuna
HZZOPodrucniUred          STRING(60)          ! Naziv HZZO PU (npr. 'HZZO PU Sibenik (083)')
HZZOMjesto                STRING(40)          ! Grad HZZO podrucnog ureda
HZZOUlicaBroj             STRING(50)          ! Ulica i broj HZZO PU
HZZOOIB                   STRING(11)          ! OIB HZZO PU (npr. '02958272670')
                        END

!--- Queue tip za stavke racuna (record 61) - 12 polja ---
HZZOStavkaQType         QUEUE,TYPE
RacunIndex              LONG                  ! Interni indeks - veza na racun
BrojOvjerenePotvrde     STRING(14)            ! Polje 2:  N(max3)/N(max10), uvjetno
DatumObracuna           STRING(10)            ! Polje 3:  DD.MM.YYYY, obavezno
SifraPomagala           STRING(13)            ! Polje 4:  A4N2AN1/A12/A13, obavezno
Kolicina                STRING(8)             ! Polje 5:  N(max5).N2, obavezno
UkupniIznos             STRING(12)            ! Polje 6:  N(max9).N2, obavezno
SifraProizvodjaca       STRING(10)            ! Polje 7:  N10, nije obavezno
BrojPotvrdeDoktora      STRING(14)            ! Polje 8:  N14, uvjetno, K Prilog8
SifraVelicineObloge     STRING(4)             ! Polje 9:  N4, uvjetno (obloge)
IdentifikacijaPomagala  STRING(30)            ! Polje 10: ANS(max 30), nije obavezno
IdentifikatorEPotvrde   STRING(100)           ! Polje 11: ANS(max 100), uvjetno
IznosRazCijene          STRING(12)            ! Polje 12: N(max9).N2, nije obavezno
! --- Polja za report (nisu u HZZO export formatu - dodana na kraju) ---
NazivPomagala             STRING(100)         ! Naziv pomagala za tablicu u reportu
JedCijenaEur              STRING(12)          ! Jedinicna cijena EUR s PDV-om (N.NNNN)
StopaPDV                  STRING(5)           ! Stopa PDV-a (N.NN, npr. '5.00')
JedRazlikaEur             STRING(12)          ! Jedinicna razlika u cijeni EUR s PDV-om (N.NNNN)
                        END

!--- Queue tip za greske ---
HZZOErrorQType          QUEUE,TYPE
RacunIndex                LONG                ! Indeks racuna (0=globalno)
StavkaIndex               LONG                ! Indeks stavke (0=racun-level)
TipSloga                  STRING(2)           ! '60' ili '61'
RedniBrPolja              BYTE                ! Redni broj polja iz specifikacije
NazivPolja                STRING(40)          ! Naziv polja
Poruka                    STRING(200)         ! Opis greske
                        END

!============================================================================
! HZZOSpecClass - Klasa za rad s HZZO specifikacijom osobnog racuna pomagala
!============================================================================
HZZOSpecClass           CLASS,TYPE,MODULE('HZZOSpec.CLW'),LINK('HZZOSpec.CLW')
! --- Javni podaci ---
RacunQ                    &HZZORacunQType     ! Queue racuna (korisnik puni)
StavkaQ                   &HZZOStavkaQType    ! Queue stavki (korisnik puni)
ErrorQ                    &HZZOErrorQType     ! Queue gresaka (rezultat validacije)

! --- Javne metode ---
Init                      PROCEDURE()
Kill                      PROCEDURE()
ClearAll                  PROCEDURE()
Validate                  PROCEDURE(),BOOL               ! TRUE=ispravno, FALSE=greske
Export                    PROCEDURE(STRING pFileName),BOOL ! TRUE=uspjeh
GenerateFileName          PROCEDURE(STRING pSifraPodSluzbe,STRING pSifraIsporucitelja,|
                            LONG pRedniBroj,LONG pGodina),STRING
GetErrorCount             PROCEDURE(),LONG
DateToStr                 PROCEDURE(LONG pDate),STRING
Report                    PROCEDURE(LONG pRacunIndex, BYTE pVrsta, STRING pPdfPath)

! --- Privatne metode ---
ValidateRacun             PROCEDURE(LONG pRacunPtr),BOOL,PRIVATE
ValidateStavka            PROCEDURE(LONG pRacunPtr,LONG pStavkaPtr),BOOL,PRIVATE
ValidateDate              PROCEDURE(STRING pDate),BOOL,PRIVATE
ValidateAmount            PROCEDURE(STRING pAmount),BOOL,PRIVATE
ValidateNumeric           PROCEDURE(STRING pValue,LONG pMaxLen),BOOL,PRIVATE
ContainsColon             PROCEDURE(STRING pValue),BOOL,PRIVATE
CheckDigitSifraIsporucitelja PROCEDURE(STRING pSifra),BOOL,PRIVATE
CheckDigitMBO             PROCEDURE(STRING pMBO),BOOL,PRIVATE
CheckDigitPotvrdaDoktora  PROCEDURE(STRING pBroj),BOOL,PRIVATE
CheckDigitOIB             PROCEDURE(STRING pOIB),BOOL,PRIVATE
FormatRacunLine           PROCEDURE(LONG pRacunPtr),STRING,PRIVATE
FormatStavkaLine          PROCEDURE(LONG pStavkaPtr),STRING,PRIVATE
AddError                  PROCEDURE(LONG pRacunIdx,LONG pStavkaIdx,STRING pTipSloga,|
                            BYTE pRbrPolja,STRING pNazivPolja,STRING pPoruka),PRIVATE
                        END

_EndOfInclude_
