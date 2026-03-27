!============================================================================
! HZZOReport.CLW - HZZO osobni racun pomagala - PDF report generator
!
! Standalone PROGRAM - primjer generiranja PDF racuna iz HZZOSpecClass queue-ova.
!
! Zahtjevi za cwproj:
!   <Compile Include="HZZOReport.CLW" />
!   <Compile Include="HZZOSpec.CLW"   />
!
! Koristenje:
!   1. Popuni Spec.RacunQ i Spec.StavkaQ (ukljucujuci report-only polja)
!   2. Pozovi HZZOReport(pRacunIndex, pVrsta, pPdfPath)
!      pRacunIndex : LONG  - RacunIndex zapisa koji se ispisuje
!      pVrsta      : BYTE  - 1=osnovno zdravstveno osiguranje
!                            2=dopunsko zdravstveno osiguranje
!      pPdfPath    : STRING - putanja do output PDF ('' = print preview)
!
! Razlika OS vs DOP:
!   Osnovno  - 5 financijskih redaka, labela 'RACUN za obvezno ...'
!              skriveni: 'Br. police dop. zdr. osig. HZZO' + 6. redak
!   Dopunsko - 6 financijskih redaka, labela 'RACUN za dopunsko ...'
!              prikazana polica + f6='Iznos PDV-a u tocki 5.'
!
! Napomena o HZZO export formatu:
!   Nova report-only polja (SifraMaloprodajneLokacije, AdresaIsporucitelja,
!   ZiroRacun, MaticniBroj, OIBIsporucitelja, PozivNaBroj, MjestoIzdavanja,
!   HZZOPodrucniUred, HZZOMjesto, HZZOUlicaBroj, HZZOOIB) te stavka polja
!   (NazivPomagala, JedCijenaEur, StopaPDV, JedRazlikaEur) NISU dio HZZO
!   specifikacije izvoza - Export() i Validate() ih ignoriraju.
!============================================================================

                    PROGRAM

                    INCLUDE('HZZOSpec.INC'),ONCE

                    MAP
HZZOReport            PROCEDURE(LONG pRacunIndex, BYTE pVrsta, STRING pPdfPath)
                    END

!--- Globalna instanca klase - korisnik puni queue-ove, zatim poziva HZZOReport ---
Spec                HZZOSpecClass

                    CODE
                    Spec.Init()

!============================================================================
! Demo podaci - odgovaraju primjeru iz:
!   primjer/RacunZaOsnovnoOsiguranje.jpg
!   primjer/RacunZaDopunskoOsiguranje.jpg
!============================================================================

                    !--- RacunQ ---
                    CLEAR(Spec.RacunQ)
                    Spec.RacunQ.RacunIndex              = 1
                    ! HZZO spec polja (32):
                    Spec.RacunQ.SifraIsporucitelja      = '200326791'
                    Spec.RacunQ.NazivIsporucitelja      = 'Karl Dietz Kijevo d.o.o.'
                    Spec.RacunQ.BrojOvjerenePotvrde     = ''
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
                    Spec.RacunQ.OIB                     = ''
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

                    !--- Generiraj oba PDF-a ---
                    HZZOReport(1, 1, 'racun_osnovno.pdf')   ! Osnovno zdravstveno osiguranje
                    HZZOReport(1, 2, 'racun_dopunsko.pdf')  ! Dopunsko zdravstveno osiguranje

                    Spec.Kill()

!============================================================================
! HZZOReport - generira jedan PDF racun (jedna stranica)
!
! Parametri:
!   pRacunIndex  LONG    RacunIndex zapisa u Spec.RacunQ
!   pVrsta       BYTE    1=osnovno, 2=dopunsko zdravstveno osiguranje
!   pPdfPath     STRING  putanja do PDF datoteke ('' = pokazi print preview)
!
! Napomena o PDF generiranju (Clarion 11):
!   - SYSTEM{PROP:PrintMode} = 3 -> PDF mod (zahtijeva PDF driver)
!   - Za print preview: SYSTEM{PROP:PrintMode} = 1 (default printer/preview)
!   - Putanja PDF-a ovisi o konfiguraciji PDF drivera ili Clarion 11 built-in
!     PDF exportu. Prilagodite prema vasoj Clarion instalaciji.
!============================================================================
HZZOReport          PROCEDURE(LONG pRacunIndex, BYTE pVrsta, STRING pPdfPath)

!--- Header varijable ---
l:RacunZa           STRING(80)          ! npr. 'RACUN za obvezno zdravstveno osiguranje'
l:RacunBroj         STRING(60)          ! npr. 'Racun broj: 7006'
l:Oib               STRING(40)          ! npr. 'OIB: 02958272670'
l:PodrucniUred      STRING(80)          ! npr. 'Podrucni ured: HZZO PU Sibenik (083)'
l:HZZOMjesto        STRING(60)          ! npr. 'Mjesto: Sibenik'
l:HZZOUlicaBroj     STRING(60)          ! npr. 'Ulica i broj: Fra. Jerolima Milete 12'
l:SifraMalLok       STRING(10)          ! sifra maloprodajne lokacije
l:Naziv_Isp         STRING(80)          ! naziv isporucitelja
l:Adresa_Isp        STRING(80)          ! adresa isporucitelja
l:Ziro              STRING(50)          ! IBAN ziro racun
l:BrojPotvrde       STRING(110)         ! UUID potvrde/racuna
l:BrojPolice        STRING(50)          ! broj police dopunskog osiguranja
l:MaticniBrojOib    STRING(30)          ! maticni broj + space + OIB isporucitelja
l:MBOPacijenta      STRING(30)          ! 'MBO Pacijenta: nnnnnnnnn'
l:PozivNaBroj       STRING(30)          ! poziv na broj

!--- Tablica stavki - varijable ---
l:Br                LONG                ! redni broj stavke u tablici
l:Sifra             STRING(13)          ! sifra pomagala
l:NazivS            STRING(100)         ! naziv pomagala
l:Kolicina          DECIMAL(7,2)        ! kolicina
l:JedCijena         DECIMAL(14,4)       ! jedinicna cijena EUR s PDV
l:StopaPDVa         DECIMAL(5,2)        ! stopa PDV-a
l:Iznos             DECIMAL(11,2)       ! ukupni iznos stavke s PDV
l:JedRazlika        DECIMAL(15,4)       ! jedinicna razlika u cijeni
l:UkRazlika         DECIMAL(11,2)       ! ukupna razlika (JedRazlika * Kolicina)
l:UkupnoIznos       DECIMAL(11,2)       ! zbroj iznosa svih stavki (za UKUPNO)
l:UkupnoRazlika     DECIMAL(11,2)       ! zbroj razlika svih stavki (za UKUPNO)

!--- PDV tablica (max 2 stope) ---
l:Stopa1            STRING(5)           ! stopa PDV-a 1 (npr. '5.00')
l:Osnovica1         DECIMAL(11,2)       ! osnovica bez PDV-a za stopu 1
l:PDVIznos1         DECIMAL(11,2)       ! PDV iznos za stopu 1
l:Stopa2            STRING(5)           ! stopa PDV-a 2 (npr. '25.00')
l:Osnovica2         DECIMAL(11,2)       ! osnovica bez PDV-a za stopu 2
l:PDVIznos2         DECIMAL(11,2)       ! PDV iznos za stopu 2
l:StopaDec          DECIMAL(5,2)        ! pomocna: stopa PDV-a kao decimal
l:OsnovicaI         DECIMAL(11,4)       ! pomocna: osnovica za jednu stavku
l:PDVIznosI         DECIMAL(11,4)       ! pomocna: PDV iznos za jednu stavku

!--- Financijski zbroji (iz RacunQ) ---
l:UkIznosPomagala   DECIMAL(11,2)       ! 1. Ukupan iznos (s PDV-om)
l:IznosSudjelovanja DECIMAL(11,2)       ! 2. Iznos sudjelovanja
l:IznosObvezno      DECIMAL(11,2)       ! 3. Iznos na teret obveznog ZO
l:IznosRazlike      DECIMAL(11,2)       ! 4. Iznos razlike u cijeni
l:IznosPDV5         DECIMAL(11,2)       ! 5. PDV obveznog (OS) ili dopunski iznos (DOP)
l:f6_Iznos          DECIMAL(11,2)       ! 6. PDV dopunskog - samo za DOP

!--- Labele financijskog sazetka ---
l:f1                STRING(80)          ! '1. Ukupan iznos (s PDV-om):'
l:f2                STRING(80)          ! '2. Iznos sudjelovanja:'
l:f3                STRING(80)          ! '3. Iznos na teret obveznog zdravstvenog osiguranja:'
l:f4                STRING(80)          ! '4. Iznos razlike u cijeni'
l:f5                STRING(80)          ! '5. ...' (razlikuje se OS vs DOP)
l:f6                STRING(80)          ! '6. ...' (samo DOP, prazno za OS)

!--- Datumi ---
l:DatumNarudzbeStr  STRING(60)          ! 'Datum narudzbe: DD.MM.YYYY'
l:DatumIzdavanjaStr STRING(60)          ! 'Datum izdavanja pomagala: DD.MM.YYYY'
l:MjestoIDatum      STRING(90)          ! 'Mjesto i datum izdavanja racuna: Grad, DD.MM.YYYY'

!--- Petlja ---
ii#                 LONG                ! iterator

!===========================================================================
! REPORT struktura (A4, millimetri, Arial 10pt)
! Koordinate su identidne primjeru iz PrimjerReportaUClarionu.clw
!===========================================================================
Report              REPORT,AT(11,115,189,149),PRE(RPT),|
                      PAPER(PAPER:A4),|
                      FONT('Arial',10,,FONT:regular,CHARSET:EASTEUROPE),MM

!==========================================================================
! HEADER - zaglavlje (ispisuje se automatski na vrhu svake stranice)
! AT(x,y,w,h) = AT(11,12,189,103) - relativno na stranicu
!==========================================================================
                      HEADER,AT(11,12,189,103),USE(?Header)

!--- Obrub headera ---
                        LINE,AT(0,0,189,0),USE(?HdrTop)
                        LINE,AT(0,103,189,0),USE(?HdrBot)
                        LINE,AT(0,0,0,103),USE(?HdrLeft)
                        LINE,AT(189,0,0,103),USE(?HdrRight)

!--- HZZO zaglavlje (lijevo gore) ---
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

!--- Razdjelna linija (ispod HZZO adrese) ---
                        LINE,AT(0,40,189,0),USE(?HdrSep)

!--- Tip i broj racuna (desno gore) ---
                        STRING(@s60),AT(111,1,76,5),USE(l:RacunBroj),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE),RIGHT(2)
                        TEXT,AT(130,8,56,15),USE(l:RacunZa),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)

!--- Sekcija I: isporucitelj ---
                        STRING('I. IZDAVANJE POMAGALA, DIJELA POMAGALA'),|
                          AT(2,45,84,5),USE(?SekcijaI),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('(Ispunjava ugovorni isporucitelj)'),|
                          AT(87,45,42,5),USE(?SekcijaISub),|
                          FONT(,8,,FONT:regular,CHARSET:EASTEUROPE)

!--- Lijevo: sifra, naziv, adresa, ziro ---
                        STRING('Sifra maloprodajne lokacije:'),|
                          AT(2,55,44,5),USE(?LblSifraLok),|
                          FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                        STRING(@s10),AT(47,55,53,5),USE(l:SifraMalLok),|
                          FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                        STRING('Naziv:'),|
                          AT(2,64,15,5),USE(?LblNaziv),|
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

!--- Desno: broj potvrde, polica (samo DOP), maticni+OIB, MBO, poziv ---
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

!==========================================================================
! detailh - zaglavlje tablice stavki (ispisuje se s PRINT(RPT:detailh))
!==========================================================================
detailh               DETAIL,AT(0,0,189,10),USE(?DETAILH)

                        LINE,AT(0,0,189,0),USE(?DHTop)
                        LINE,AT(0,10,189,0),USE(?DHBot)
                        LINE,AT(0,0,0,10),USE(?DHLeft)
                        LINE,AT(189,0,0,10),USE(?DHRight)

!--- Vertikalne linije stupaca ---
                        LINE,AT(8,0,0,10),USE(?DHCol1)    ! R.br.
                        LINE,AT(38,0,0,10),USE(?DHCol2)   ! Sifra
                        LINE,AT(80,0,0,10),USE(?DHCol3)   ! Naziv
                        LINE,AT(93,0,0,10),USE(?DHCol4)   ! Kolicina
                        LINE,AT(113,0,0,10),USE(?DHCol5)  ! Jed.cijena
                        LINE,AT(127,0,0,10),USE(?DHCol6)  ! Stopa PDV
                        LINE,AT(150,0,0,10),USE(?DHCol7)  ! Ukupni iznos
                        LINE,AT(168,0,0,10),USE(?DHCol8)  ! Jed.razlika

!--- Tekst zaglavlja ---
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

!==========================================================================
! Detail - jedan redak tablice stavki (ispisuje se s PRINT(RPT:Detail))
!==========================================================================
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

!==========================================================================
! detailF - financijski footer racuna (ispisuje se s PRINT(RPT:detailF))
!==========================================================================
detailF               DETAIL,AT(0,0,189,85),USE(?DETAILF)

                        LINE,AT(0,0,189,0),USE(?DFTop)

!--- UKUPNO box (desno gore) ---
                        BOX,AT(98,0,91,7),USE(?UkupnoBox),|
                          COLOR(COLOR:Black),FILL(COLOR:White),LINEWIDTH(0)
                        STRING('UKUPNO:'),AT(103,1,20,4),USE(?UkupnoLbl),|
                          FONT(,,,FONT:bold)
                        STRING(@n-14.2),AT(121,1,28,4),USE(l:UkupnoIznos),|
                          FONT(,,,FONT:bold),RIGHT
                        STRING(@n-15.2),AT(158,1,28,4),USE(l:UkupnoRazlika),|
                          FONT(,,,FONT:bold),RIGHT

!--- Labele financijskog sazetka (f1-f6) ---
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

!--- Iznosi financijskog sazetka ---
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

!--- PDV tablica (lijevo dolje) ---
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

!--- Datumi ---
                        STRING(@s80),AT(10,47,100,5),USE(l:DatumNarudzbeStr),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s80),AT(10,53,100,5),USE(l:DatumIzdavanjaStr),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT
                        STRING(@s90),AT(10,59,110,5),USE(l:MjestoIDatum),|
                          FONT(,,,,CHARSET:EASTEUROPE),LEFT

!--- Potpisi ---
                        LINE,AT(14,73,51,0),USE(?PotpisL1)
                        LINE,AT(114,73,59,0),USE(?PotpisL2)
                        STRING('Potpis odgovorne osobe'),AT(20,75,45,4),|
                          USE(?LblPotpis1),FONT(,8)
                        STRING('M.P.'),AT(83,70,12,5),USE(?LblMP),FONT(,8)
                        STRING('Ime, prezime i potpis odgovorne osobe'),|
                          AT(114,75,70,4),USE(?LblPotpis2),FONT(,8)

                      END  !detailF

!==========================================================================
! FOOTER - podnozje stranice (ispisuje se automatski)
!==========================================================================
                      FOOTER,AT(6,264,201,29),USE(?Footer)
                        LINE,AT(0,0,201,0),USE(?FtrTop)
                        STRING(@s200),AT(1,4,197,4),USE(l:MjestoIDatum),|
                          FONT(,8,,,CHARSET:EASTEUROPE),CENTER
                        STRING('Ovaj racun je izdan na racunalu i punovaljan je bez potpisa i pecata.'),|
                          AT(10,22,175,4),USE(?FtrLegal),|
                          FONT(,8,,FONT:bold,CHARSET:EASTEUROPE)
                      END  !FOOTER

                    END  !Report

!==========================================================================
! CODE - logika procedure
!==========================================================================
                    CODE

                    !--- 1. Dohvati racun iz queue-a po RacunIndex ---
                    LOOP ii# = 1 TO RECORDS(Spec.RacunQ)
                      GET(Spec.RacunQ, ii#)
                      IF Spec.RacunQ.RacunIndex = pRacunIndex THEN BREAK.
                    END
                    ! Ako nije pronasao - vrati se
                    IF Spec.RacunQ.RacunIndex <> pRacunIndex THEN EXIT.

                    !--- 2. Header varijable ---
                    IF pVrsta = 1
                      l:RacunZa   = 'RACUN za obvezno zdravstveno osiguranje'
                      l:RacunBroj = 'Racun broj: ' & CLIP(Spec.RacunQ.BrojOsobnogRacuna)
                    ELSE
                      l:RacunZa   = 'RACUN za dopunsko zdravstveno osiguranje'
                      IF CLIP(Spec.RacunQ.BrojRacDopunsko) <> ''
                        l:RacunBroj = 'Racun broj: ' & CLIP(Spec.RacunQ.BrojRacDopunsko)
                      ELSE
                        l:RacunBroj = 'Racun broj: ' & CLIP(Spec.RacunQ.BrojOsobnogRacuna)
                      END
                    END

                    l:Oib          = 'OIB: ' & CLIP(Spec.RacunQ.HZZOOIB)
                    l:PodrucniUred = 'Podrucni ured: ' & CLIP(Spec.RacunQ.HZZOPodrucniUred)
                    l:HZZOMjesto   = 'Mjesto: ' & CLIP(Spec.RacunQ.HZZOMjesto)
                    l:HZZOUlicaBroj= 'Ulica i broj: ' & CLIP(Spec.RacunQ.HZZOUlicaBroj)
                    l:SifraMalLok  = CLIP(Spec.RacunQ.SifraMaloprodajneLokacije)
                    l:Naziv_Isp    = CLIP(Spec.RacunQ.NazivIsporucitelja)
                    l:Adresa_Isp   = CLIP(Spec.RacunQ.AdresaIsporucitelja)
                    l:Ziro         = CLIP(Spec.RacunQ.ZiroRacun)
                    l:BrojPotvrde  = CLIP(Spec.RacunQ.IdentifikatorEPotvrde)
                    l:BrojPolice   = CLIP(Spec.RacunQ.BrojPolice)
                    l:MaticniBrojOib = CLIP(Spec.RacunQ.MaticniBroj) & ' ' & |
                                       CLIP(Spec.RacunQ.OIBIsporucitelja)
                    l:MBOPacijenta = 'MBO Pacijenta: ' & CLIP(Spec.RacunQ.MBO)
                    l:PozivNaBroj  = CLIP(Spec.RacunQ.PozivNaBroj)

                    !--- 3. Datumi ---
                    l:DatumNarudzbeStr  = 'Datum narudzbe: ' & |
                                          CLIP(Spec.RacunQ.DatumNarudzbe)
                    l:DatumIzdavanjaStr = 'Datum izdavanja pomagala: ' & |
                                          CLIP(Spec.RacunQ.DatumObracuna)
                    l:MjestoIDatum      = 'Mjesto i datum izdavanja racuna: ' & |
                                          CLIP(Spec.RacunQ.MjestoIzdavanja) & ', ' & |
                                          CLIP(Spec.RacunQ.DatumIzdavanja)

                    !--- 4. Labele financijskog sazetka (razlikuju se OS vs DOP) ---
                    l:f1 = '1. Ukupan iznos (s PDV-om):'
                    l:f2 = '2. Iznos sudjelovanja:'
                    l:f3 = '3. Iznos na teret obveznog zdravstvenog osiguranja:'
                    l:f4 = '4. Iznos razlike u cijeni'
                    IF pVrsta = 1  !Osnovno
                      l:f5 = '5. Iznos obracunatog PDV-a u tocki 3.'
                      l:f6 = ''
                    ELSE           !Dopunsko
                      l:f5 = '5. Iznos na teret dopunskog zdravstvenog osiguranja'
                      l:f6 = '6. Iznos obracunatog PDV-a u tocki 5.'
                    END

                    !--- 5. Financijski iznosi iz RacunQ (STRING -> DECIMAL konverzija) ---
                    l:UkIznosPomagala   = Spec.RacunQ.UkIznosPomagala
                    l:IznosSudjelovanja = Spec.RacunQ.IznosSudjelovanja
                    l:IznosObvezno      = Spec.RacunQ.IznosObveznoSPDV
                    l:IznosRazlike      = Spec.RacunQ.UkIznosRazCijene
                    IF pVrsta = 1  !Osnovno: prikazi PDV obveznog
                      l:IznosPDV5 = Spec.RacunQ.IznosPDVObvezno
                      l:f6_Iznos  = 0
                    ELSE           !Dopunsko: prikazi dopunski iznos + PDV u 6. retku
                      l:IznosPDV5 = Spec.RacunQ.IznosDopunskoSPDV
                      l:f6_Iznos  = Spec.RacunQ.IznosPDVDopunsko
                    END

                    !--- 6. Otvori report ---
                    ! Za PDF: SYSTEM{PROP:PrintMode} = 3 (zahtijeva PDF driver)
                    ! Za preview: izostavi sljedecu liniju (default = printer/preview)
                    IF CLIP(pPdfPath) <> ''
                      SYSTEM{PROP:PrintMode} = 3
                    END
                    OPEN(Report)
                    IF CLIP(pPdfPath) <> ''
                      Report{PROP:OutputFile} = CLIP(pPdfPath)
                    END
                    Report{PROP:Extend} = TRUE

                    !--- 7. Sakrij/prikazi elemente ovisno o vrsti ---
                    IF pVrsta = 1  !Osnovno: sakrij polica label + vrijednost + 6. redak
                      Report$?SDOP{PROP:Hide}         = TRUE
                      Report$?l:BrojPolice{PROP:Hide} = TRUE
                      Report$?l:f6{PROP:Hide}         = TRUE
                      Report$?l:f6_Iznos{PROP:Hide}   = TRUE
                    ELSE           !Dopunsko: prikazi sve
                      Report$?SDOP{PROP:Hide}         = FALSE
                      Report$?l:BrojPolice{PROP:Hide} = FALSE
                      Report$?l:f6{PROP:Hide}          = FALSE
                      Report$?l:f6_Iznos{PROP:Hide}    = FALSE
                    END

                    !--- 8. Ispiši zaglavlje tablice ---
                    PRINT(RPT:detailh)

                    !--- 9. Petlja kroz stavke ovog racuna ---
                    l:Br            = 0
                    l:UkupnoIznos   = 0
                    l:UkupnoRazlika = 0
                    CLEAR(l:Stopa1)
                    CLEAR(l:Stopa2)
                    l:Osnovica1 = 0  ;  l:PDVIznos1 = 0
                    l:Osnovica2 = 0  ;  l:PDVIznos2 = 0

                    LOOP ii# = 1 TO RECORDS(Spec.StavkaQ)
                      GET(Spec.StavkaQ, ii#)
                      IF Spec.StavkaQ.RacunIndex <> pRacunIndex THEN CYCLE.

                      !--- Popuni display varijable ---
                      l:Br         += 1
                      l:Sifra       = CLIP(Spec.StavkaQ.SifraPomagala)
                      l:NazivS      = CLIP(Spec.StavkaQ.NazivPomagala)
                      l:Kolicina    = Spec.StavkaQ.Kolicina     ! STRING -> DECIMAL
                      l:JedCijena   = Spec.StavkaQ.JedCijenaEur
                      l:StopaPDVa   = Spec.StavkaQ.StopaPDV
                      l:Iznos       = Spec.StavkaQ.UkupniIznos
                      l:JedRazlika  = Spec.StavkaQ.JedRazlikaEur
                      IF l:JedRazlika < 0 THEN l:JedRazlika = 0.
                      l:UkRazlika   = l:JedRazlika * l:Kolicina

                      l:UkupnoIznos   += l:Iznos
                      l:UkupnoRazlika += l:UkRazlika

                      !--- PDV grupiranje (max 2 razlicite stope) ---
                      ! Osnovica = Iznos / (1 + Stopa/100)
                      ! PDVIznos = Iznos - Osnovica
                      l:StopaDec = l:StopaPDVa
                      IF l:StopaDec > 0
                        l:OsnovicaI = l:Iznos / (1 + l:StopaDec / 100)
                        l:PDVIznosI = l:Iznos - l:OsnovicaI
                        IF CLIP(l:Stopa1) = ''
                          l:Stopa1    = CLIP(Spec.StavkaQ.StopaPDV)
                          l:Osnovica1 += l:OsnovicaI
                          l:PDVIznos1 += l:PDVIznosI
                        ELSIF CLIP(Spec.StavkaQ.StopaPDV) = CLIP(l:Stopa1)
                          l:Osnovica1 += l:OsnovicaI
                          l:PDVIznos1 += l:PDVIznosI
                        ELSIF CLIP(l:Stopa2) = ''
                          l:Stopa2    = CLIP(Spec.StavkaQ.StopaPDV)
                          l:Osnovica2 += l:OsnovicaI
                          l:PDVIznos2 += l:PDVIznosI
                        ELSIF CLIP(Spec.StavkaQ.StopaPDV) = CLIP(l:Stopa2)
                          l:Osnovica2 += l:OsnovicaI
                          l:PDVIznos2 += l:PDVIznosI
                        END
                      END

                      PRINT(RPT:Detail)
                    END  !LOOP stavke

                    !--- 10. Ispiši financijski footer i zatvori stranicu ---
                    PRINT(RPT:detailF)
                    ENDPAGE(Report)
                    CLOSE(Report)
