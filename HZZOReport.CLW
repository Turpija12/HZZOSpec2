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
!   2. Pozovi Spec.Report(pRacunIndex, pVrsta, pPdfPath)
!      pRacunIndex : LONG  - RacunIndex zapisa koji se ispisuje
!      pVrsta      : BYTE  - 1=osnovno zdravstveno osiguranje
!                            2=dopunsko zdravstveno osiguranje
!      pPdfPath    : STRING - putanja do PDF datoteke ('' = print preview)
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
                    END

!--- Globalna instanca klase - korisnik puni queue-ove, zatim poziva Spec.Report ---
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
                    Spec.Report(1, 1, 'racun_osnovno.pdf')  ! Osnovno zdravstveno osiguranje
                    Spec.Report(1, 2, 'racun_dopunsko.pdf') ! Dopunsko zdravstveno osiguranje

                    Spec.Kill()
