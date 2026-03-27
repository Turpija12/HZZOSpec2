

                     MEMBER('fpomagala_ip.clw')            ! This is a MEMBER module


   INCLUDE('ABWMFPAR.INC'),ONCE
   INCLUDE('abprI2pdf.inc'),ONCE
   INCLUDE('abrppsel.inc'),ONCE

                     MAP
                     END


!!! <summary>
!!! Generated from procedure template - Report
!!! </summary>
Rac_2026 PROCEDURE(BYTE pSvi)

udpt            UltimateDebugProcedureTracker
RejectRecord         LONG                                  ! 
l:ccZahtjev_Id       LONG                                  ! zahtjev doznake
l:PdfFileName        STRING(255)                           ! 
l:MBO_Pacijenta      STRING(45)                            ! 
l:Identifikator_zahtjeva STRING(80)                        ! 
l:BrojPronajdenihZahtjeva BYTE                             ! 
l:DatumIzdavanjaPomagala STRING(255)                       ! 
l:Uk_Razlika_UK      DECIMAL(11,2)                         ! 
l:JedRazlika         DECIMAL(15,4)                         ! 
l:Uk_Razlika         DECIMAL(10,2)                         ! 
l:f6_Iznos           DECIMAL(11,2)                         ! 
l:UK_IznosRazlikeUCijeni DECIMAL(11,2)                     ! 
l:Stopa1             STRING(10)                            ! 
l:Osnovica1          DECIMAL(10,2)                         ! 
l:Iznospp1           DECIMAL(9,2)                          ! 
l:Stopa2             STRING(10)                            ! 
l:Osnovica2          DECIMAL(9,2)                          ! 
l:Iznospp2           DECIMAL(9,2)                          ! 
l:FiskalFuter        STRING(500)                           ! 
l:ImaLiUslugeUStavkama BYTE                                ! 
l:Rtf_Futer          STRING(2000)                          ! 
l:IdDOKument         LONG                                  ! 
l:DatumNarudjbe      STRING(50)                            ! 
l:Mjesto_Izdavanja   STRING(30)                            ! 
l:MjestoIDatumIzdavanjaRacuna STRING(80)                   ! 
l:sveOK              BYTE                                  ! 
l:RacunZa            STRING(80)                            ! 
l:Oib                STRING(40)                            ! 
l:PodrucniUred       STRING(80)                            ! 
l:Mjesto             STRING(50)                            ! 
l:Ulica_I_Broj       STRING(40)                            ! 
l:RacunBroj          STRING(50)                            ! 
l:SifraMaloprodajneLokacije STRING(40)                     ! 
l:Naziv              STRING(80)                            ! 
l:Adresa             STRING(80)                            ! 
l:Ziro               STRING(50)                            ! 
l:BrojPotvrdeRacuna  STRING(50)                            ! 
l:BrojPolice         STRING(50)                            ! 
l:MaticniBroj_Oib    STRING(80)                            ! 
l:PozivNaBroj        STRING(50)                            ! 
LocalRequest         LONG                                  ! 
OriginalRequest      LONG                                  ! 
LocalResponse        LONG                                  ! 
FilesOpened          LONG                                  ! 
WindowOpened         LONG                                  ! 
RecordsToProcess     LONG,AUTO                             ! 
RecordsProcessed     LONG,AUTO                             ! 
RecordsPerCycle      LONG,AUTO                             ! 
RecordsThisCycle     LONG,AUTO                             ! 
PercentProgress      BYTE                                  ! 
RecordStatus         BYTE,AUTO                             ! 
WindowInitialized    LONG                                  ! 
ForceRefresh         LONG                                  ! 
l:IdPartner          LONG                                  ! 
l:Br                 LONG                                  ! 
l:Sifra_S            STRING(20)                            ! 
l:Naziv_S            STRING(80)                            ! 
l:Kol_S              REAL                                  ! 
l:StopaPDVa          REAL                                  ! 
l:Cijena_S           DECIMAL(14,4)                         ! 
l:Iznos_S            DECIMAL(9,2)                          ! 
l:Ukupno_S           DECIMAL(10,2)                         ! 
l:cijenaUK           DECIMAL(11,2)                         ! 
l:UkIznosZaPomagala  DECIMAL(14,2)                         ! 
l:IznosSudjelovanja  DECIMAL(14,2)                         ! 
l:IznosNaTeretObaveznogZdravstvenogOsig DECIMAL(14,2)      ! 
l:IznosPDVaObaveznogOsig DECIMAL(14,2)                     ! 
l:f1                 STRING(60)                            ! 
l:f2                 STRING(60)                            ! 
l:f3                 STRING(60)                            ! 
l:f4                 STRING(60)                            ! 
l:f5                 STRING(60)                            ! 
l:f6                 STRING(60)                            ! 
Process:View         VIEW(STAVKE)
                     END
PrintSkipDetails     BOOL,AUTO
SkipPreview          BYTE
PreviewQueueIndex    LONG
LocalOutputFileQueue PrintPreviewFileQueue
PrintPreviewQueue    PrintPreviewFileQueue
ShowOutputProgress   BYTE(1)
Progress:Thermometer BYTE
Report               REPORT,AT(11,115,189,148),PRE(RPT),PAPER(PAPER:A4),FONT('Arial',10,,FONT:regular,CHARSET:EASTEUROPE), |
  MM
                       HEADER,AT(11,12,189,103),USE(?Header)
                         STRING('Hrvatski zavod za zdravstveno osiguranje'),AT(26,7,68),USE(?STRING1),FONT(,,,,239)
                         STRING(@s40),AT(26,15,63,5),USE(l:Oib),FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                         STRING(@s80),AT(26,21,63,5),USE(l:PodrucniUred),FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                         STRING(@s50),AT(26,28,63,5),USE(l:Mjesto),FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                         STRING(@s40),AT(26,35,63,5),USE(l:Ulica_I_Broj),FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                         LINE,AT(0,41,189,0),USE(?LINE1)
                         TEXT,AT(130,15,46,13),USE(l:RacunZa),FONT(,,,,CHARSET:EASTEUROPE)
                         STRING(@s50),AT(111,1,76,5),USE(l:RacunBroj),FONT(,,,FONT:bold,CHARSET:EASTEUROPE),RIGHT(2)
                         LINE,AT(0,0,189,0),USE(?LINE1:2)
                         LINE,AT(0,0,0,103),USE(?LINE2)
                         LINE,AT(189,0,0,103),USE(?LINE2:2)
                         LINE,AT(0,103,189,0),USE(?LINE1:3)
                         STRING('I. IZDAVANJE POMAGALA, DIJELA POMAGALA'),AT(2,48,84,5),USE(?STRING2:2),FONT(,,,FONT:bold, |
  CHARSET:EASTEUROPE)
                         STRING('(Ispunjava ugovorni isporuèitelj)'),AT(87,48,42,5),USE(?STRING2:3),FONT(,8,,FONT:regular, |
  CHARSET:EASTEUROPE)
                         STRING(@s40),AT(47,58,53),USE(l:SifraMaloprodajneLokacije),FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                         STRING(@s80),AT(19,68,53),USE(l:Naziv),FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                         STRING('Šifra maloprodajne lokacije:'),AT(2,58,43,5),USE(?STRING2:4),FONT(,,,FONT:regular, |
  239)
                         STRING('Naziv:'),AT(2,68,15,5),USE(?STRING2:5),FONT(,,,FONT:regular,239)
                         STRING('Adresa (mjesto, ulica i broj):'),AT(2,78,46,5),USE(?STRING2:6),FONT(,,,FONT:regular, |
  239)
                         STRING(@s50),AT(30,91,77,5),USE(l:Ziro),FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                         STRING('Broj žiro-raèun:'),AT(2,91,27,5),USE(?STRING2:7),FONT(,,,FONT:regular,239)
                         STRING(@s50),AT(71,53,115,5),USE(l:BrojPotvrdeRacuna),FONT(,,,FONT:bold,239),RIGHT(2)
                         STRING('Broj potvrde / raèuna:'),AT(146,48,35,5),USE(?STRING2:8),FONT(,,,FONT:regular,CHARSET:EASTEUROPE)
                         TEXT,AT(47,78,66,12),USE(l:Adresa),FONT(,,,FONT:bold,CHARSET:EASTEUROPE)
                         STRING(@s50),AT(136,68,51,5),USE(l:BrojPolice),FONT(,,,FONT:bold,239),CENTER
                         STRING('Br. police dop. zdr. osig. HZZO'),AT(135,61,52,5),USE(?SDOP),FONT(,,,FONT:regular, |
  239)
                         STRING(@s80),AT(136,79,51,5),USE(l:MaticniBroj_Oib),FONT(,,,FONT:bold,239),CENTER(1)
                         STRING('Matièni broj i OIB isporuèitelja:'),AT(136,74,50,5),USE(?STRING2:10),FONT(,,,FONT:regular, |
  CHARSET:EASTEUROPE)
                         STRING(@s50),AT(136,93,51,5),USE(l:PozivNaBroj),FONT(,,,FONT:bold,239),CENTER
                         STRING('Poziv na broj:'),AT(149,88,26,5),USE(?STRING2:11),FONT(,,,FONT:regular,239)
                         STRING(@s40),AT(136,84,,4),USE(l:MBO_Pacijenta),FONT(,10)
                       END
Detail                 DETAIL,AT(0,0,189,10),USE(?Detail)
                         STRING(@n-14),AT(1,2,6),USE(l:Br),RIGHT
                         STRING(@s20),AT(9,2,29,5),USE(l:Sifra_S),CENTER
                         STRING(@n-14.2),AT(168,2,19,5),USE(l:Uk_Razlika),RIGHT(1)
                         STRING(@n-13.4),AT(92,2,20,5),USE(l:Cijena_S),RIGHT
                         STRING(@n10.2),AT(75,2,16,5),USE(l:Kol_S),RIGHT
                         TEXT,AT(39,1,37,9),USE(l:Naziv_S),FONT(,8)
                         STRING(@n-13.2),AT(127,2,20,5),USE(l:Iznos_S),RIGHT(1)
                         STRING(@n-15.4),AT(147,2,20,5),USE(l:JedRazlika),RIGHT
                         STRING(@n5.2),AT(115,2,10,5),USE(l:StopaPDVa),RIGHT
                       END
detailF                DETAIL,AT(0,0,189,85),USE(?DETAILF)
                         STRING(@s60),AT(64,10,89),USE(l:f1),FONT(,,,,CHARSET:EASTEUROPE),LEFT
                         STRING(@s60),AT(64,17,89,5),USE(l:f2),FONT(,,,,CHARSET:EASTEUROPE),LEFT
                         STRING(@s60),AT(64,24,89,5),USE(l:f3),FONT(,,,,CHARSET:EASTEUROPE),LEFT
                         STRING(@s60),AT(64,37,89,5),USE(l:f5),FONT(,,,,CHARSET:EASTEUROPE),LEFT
                         BOX,AT(98,0,91,7),USE(?BOX1),COLOR(COLOR:Black),FILL(COLOR:White),LINEWIDTH(0)
                         STRING('UKUPNO:'),AT(103,1,20,4),USE(?STRING5),FONT(,,,FONT:bold)
                         STRING(@n-14.2),AT(121,1,,4),USE(l:Ukupno_S),FONT(,,,FONT:bold),RIGHT(1)
                         STRING(@n-19.2),AT(159,10,28,5),USE(l:UkIznosZaPomagala),FONT(,,,FONT:bold),RIGHT(1)
                         STRING(@n-19.2),AT(159,17,28,5),USE(l:IznosSudjelovanja),FONT(,,,FONT:bold),RIGHT(1)
                         STRING(@n-19.2),AT(159,24,28,5),USE(l:IznosNaTeretObaveznogZdravstvenogOsig),FONT(,,,FONT:bold), |
  RIGHT(1)
                         STRING(@n-19.2),AT(159,37,28,5),USE(l:IznosPDVaObaveznogOsig),FONT(,,,FONT:bold),RIGHT(1)
                         STRING(@s50),AT(10,49,84),USE(l:DatumNarudjbe),FONT(,,,,CHARSET:EASTEUROPE),LEFT(1)
                         STRING(@s80),AT(10,59,94,5),USE(l:MjestoIDatumIzdavanjaRacuna),FONT(,,,,CHARSET:EASTEUROPE), |
  LEFT(1)
                         LINE,AT(14,73,51,0),USE(?LINE4)
                         LINE,AT(114,73,59,0),USE(?LINE4:2)
                         STRING('Potpis odgovorne osobe'),AT(20,75),USE(?STRING6)
                         STRING('Ime, prezime i potpis odgovorne osobe'),AT(114,75),USE(?STRING7)
                         STRING('M.P.'),AT(87,73),USE(?STRING8)
                         LINE,AT(0,0,189,0),USE(?LINE1:6)
                         BOX,AT(0,12,63,23),USE(?BOX2),COLOR(COLOR:Black),FILL(COLOR:White),LINEWIDTH(0)
                         LINE,AT(0,19,62,0),USE(?LINE5)
                         STRING('Stopa %'),AT(2,13),USE(?STRING4)
                         STRING('Osnovica'),AT(22,13,18,5),USE(?STRING4:2)
                         STRING('Iznos'),AT(46,13,12,4),USE(?STRING4:3)
                         STRING(@s10),AT(2,21,12,5),USE(l:Stopa1),LEFT
                         STRING(@n-14.2),AT(16,21,22,5),USE(l:Osnovica1),RIGHT
                         STRING(@n-13.2),AT(39,21,22,5),USE(l:Iznospp1),FONT(,,,FONT:regular),RIGHT
                         STRING(@s10),AT(2,28,12,5),USE(l:Stopa2),FONT(,,,FONT:regular),LEFT
                         STRING(@n-13.2b),AT(16,28,22,5),USE(l:Osnovica2),RIGHT
                         STRING(@n-13.2b),AT(39,28,22,5),USE(l:Iznospp2),FONT(,,,FONT:regular),RIGHT
                         STRING(@s40),AT(110,67,76),USE(GLO:Direktor2),CENTER
                         STRING(@s60),AT(64,30,89,5),USE(l:f4),FONT(,,,,CHARSET:EASTEUROPE),LEFT
                         STRING(@n-15.2),AT(159,30,28,5),USE(l:UK_IznosRazlikeUCijeni),FONT(,,,FONT:bold),RIGHT(1)
                         STRING(@n-15.2),AT(158,1,28,4),USE(l:Uk_Razlika_UK),FONT(,,,FONT:bold),RIGHT(1)
                         STRING(@s60),AT(64,42,89,5),USE(l:f6),FONT(,,,,CHARSET:EASTEUROPE),LEFT
                         STRING(@N-15.2B),AT(159,42,28,5),USE(l:f6_Iznos),FONT(,,,FONT:bold),RIGHT(1)
                         STRING(@s255),AT(10,54,84,5),USE(l:DatumIzdavanjaPomagala),FONT(,,,,CHARSET:EASTEUROPE),LEFT(1)
                         STRING(@s40),AT(14,66,52,5),USE(GLO:Direktor),CENTER
                       END
detailh                DETAIL,AT(0,0,189,10),USE(?DETAILH)
                         LINE,AT(0,0,189,0),USE(?LINE1:4)
                         LINE,AT(0,10,189,0),USE(?LINE1:5)
                         LINE,AT(0,0,0,10),USE(?LINE3)
                         LINE,AT(189,0,0,10),USE(?LINE3:2)
                         STRING('R.'),AT(2,1,5,4),USE(?STRING3)
                         STRING('br.'),AT(1,5,5,4),USE(?STRING3:2)
                         STRING('Šifra pomagala'),AT(10,2,24,6),USE(?STRING3:3),FONT(,8,,,239)
                         STRING('Naziv pomagala'),AT(40,2,26,6),USE(?STRING3:4),FONT(,8,,,239)
                         STRING('Kolièina'),AT(82,2,11,4),USE(?STRING3:5),FONT(,8,,,CHARSET:EASTEUROPE)
                         STRING('Jedinièna cijena'),AT(94,1,18,2),USE(?STRING3:6),FONT(,6,,,CHARSET:EASTEUROPE),CENTER
                         STRING('u EUR s PDV-om'),AT(128,5,21,4),USE(?STRING3:8),FONT(,7,,,239),CENTER
                         STRING('Ukupni iznos'),AT(130,1,19,4),USE(?STRING3:9),FONT(,8,,,239)
                         LINE,AT(8,0,0,10),USE(?LINE3:3)
                         LINE,AT(38,0,0,10),USE(?LINE3:4)
                         LINE,AT(80,0,0,10),USE(?LINE3:5)
                         LINE,AT(127,0,0,10),USE(?LINE3:6)
                         LINE,AT(93,0,0,10),USE(?LINE3:7)
                         STRING('U EUR bez PDV-a'),AT(94,3,18,2),USE(?STRING3:7),FONT(,6,,,239),CENTER
                         STRING('s Osnovne liste'),AT(94,5,18,2),USE(?STRING3:10),FONT(,6,,,239),CENTER
                         LINE,AT(150,0,0,10),USE(?LINE3:8)
                         LINE,AT(168,0,0,10),USE(?LINE3:9)
                         STRING('Jedinièna '),AT(153,1,12,2),USE(?STRING3:11),FONT(,6,,,CHARSET:EASTEUROPE)
                         STRING('razlika u cijeni'),AT(152,3,15,2),USE(?STRING3:12),FONT(,6,,,239)
                         STRING('u EUR s PDV-om'),AT(151,6,15,2),USE(?STRING3:13),FONT(,6,,,239)
                         STRING('Ukupni iznos'),AT(169,1,19,2),USE(?STRING3:14),FONT(,6,,,239),CENTER
                         STRING('pomagala'),AT(94,7,18,2),USE(?STRING3:15),FONT(,6,,,239),CENTER
                         LINE,AT(113,0,0,10),USE(?LINE3:10)
                         STRING('Stopa'),AT(115,1,11,3),USE(?STRING3:17),FONT(,8,,,239)
                         STRING('PDV-a'),AT(115,5,11,3),USE(?STRING3:18),FONT(,8,,,239)
                         STRING('razlike u EUR'),AT(169,4,19,2),USE(?STRING3:16),FONT(,6,,,239),CENTER
                         STRING('s PDV-om'),AT(169,7,19,2),USE(?STRING3:19),FONT(,6,,,239),CENTER
                       END
                       FOOTER,AT(6,264,201,29),USE(?Footer)
                         STRING(@s255),AT(1,1,185,4),USE(l:FiskalFuter),FONT(,8,,,CHARSET:EASTEUROPE),CENTER(1)
                         IMAGE,AT(1,5,197,19),USE(?IMAGE1)
                         STRING('Ovaj raèun je izdan na raèunalu u skladu s èlankom 4. Zakona o raèunovodstvu, t' & |
  'e je punovaljan bez potpisa i peèata.'),AT(15,24,,4),USE(?STRIsss),FONT(,8,,FONT:bold)
                         TEXT,AT(1,6,198,17),USE(l:Rtf_Futer),RTF(TEXT:Field)
                       END
                       FORM,AT(25,25,156,242),USE(?Form)
                       END
                     END
 OMIT('112233!!!!!')
ProgressWindow WINDOW('Progress...'),AT(,,142,59),CENTER,TIMER(1),GRAY,DOUBLE
       PROGRESS,USE(Progress:Thermometer),AT(15,15,111,12),RANGE(0,100)
       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
       BUTTON('Cancel'),AT(45,42,50,15),USE(?Progress:Cancel)
     END
!  112233!!!!!

ProgressWindow          WINDOW('Export ...'),AT(,,142,59),CENTER,GRAY,TIMER(1),DOUBLE
                            PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                            STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                            STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                            BUTTON('Cancel'),AT(45,42,50,15),USE(?Progress:Cancel)
                        END

sRTF            StringTheory
LocalTargetSelector  ReportTargetSelectorClass             ! TargetSelector for the Report Processors
LocalReportTarget    &IReportGenerator                     ! ReportTarget for the Report Processors
LocalAttribute       ReportAttributeManager                ! Attribute manager for the Report Processors
LocalWMFParser       WMFDocumentParser                     ! WMFParser for the Report Processors
PDFReporter          CLASS(I2PDFReportGenerator)           ! PDF
Setup                  PROCEDURE(),DERIVED
                     END

  CODE
  PUSHBIND
          udpt.Init(UD,'Rac_2026','fpomagala_ip171.clw','fpomagala_ip.EXE','03/24/2026 @ 03:10PM')    
               
        sRTF.LoadFile(CLIP(GLO:APP_Path) &'\FR.rtf')
        sRTF.Trim()
        l:Rtf_Futer=sRTF.GetValue()
     !    MESSAGE('l:Rtf_Futer = '&clip(l:Rtf_Futer) &'  sRTF.GetValue()='&sRTF.GetValue())
  ud.Debug('Rac_2026')
  LocalRequest    = GlobalRequest
  OriginalRequest = GlobalRequest
  LocalResponse   = RequestCancelled
  ForceRefresh    = False
  CLEAR(GlobalRequest)
  CLEAR(GlobalResponse)
  SkipPreview = False
  ShowOutputProgress = False
        if pSvi=TRUE
            SkipPreview=TRUE
        END        
  IF KEYCODE() = MouseRight
    SETKEYCODE(0)
  END
  DO PrepareProcedure
  if pSvi=TRUE
  LocalTargetSelector.AddItem(PDFReporter.IReportGenerator)
  LocalReportTarget &= PDFReporter.IReportGenerator
  END
  ACCEPT
    CASE EVENT()
    OF EVENT:GainFocus
      ForceRefresh = True
      IF NOT WindowInitialized
        DO InitializeWindow
        WindowInitialized = True
      ELSE
        DO RefreshWindow
      END
    OF EVENT:OpenWindow
         
         UD.Debug('rac_2026 EVENT:OpenWindow ')
         IF 1=2
         DO GetFirstRecord
         IF LocalResponse = RequestCancelled
           POST(EVENT:CloseWindow)
           CYCLE
         END
         END
         DO Prvi
         UD.Debug('rac_2026  GOTOVO EVENT:OpenWindow ')
       SYSTEM{PROP:PrintMode} = 3
       OPEN(Report)
       Report{PROPPRINT:Extend}=True
       Report{Prop:Preview} = PrintPreviewQueue.Filename
       LocalAttribute.Init(Report)
       Do SetStaticControlsAttributes
      !Report$?Image1{PROP:Text} = 'w:\4d\wand\LOGO\KDK_Memo_Dno.jpg'
      DO KojiFuter
      IF NOT WindowInitialized
        DO InitializeWindow
        WindowInitialized = True
      END
      SELECT(1)
    OF EVENT:Timer
       !Set the MRP to RecordsPerCycle
       IF Process:View{PROP:IPRequestCount}=0
          Process:View{PROP:IPRequestCount}=RecordsPerCycle
       END
       LOOP RecordsPerCycle TIMES
         !   DO StaPrintati
            ud.Debug('rac_2026  Prije Lup Timer')
            if pSvi=true    
                 DO lup
            ELSE
               do PrintRacun
            END
            LocalResponse = RequestCompleted
            BREAK
         Do SetDynamicControlsAttributes
         PrintSkipDetails = FALSE
         IF 1=2 THEN
           PrintSkipDetails = TRUE
           PRINT(RPT:Detail)
         END
         IF 1=2 THEN
           PrintSkipDetails = TRUE
           PRINT(RPT:detailF)
         END
         IF 1=2 THEN
           PrintSkipDetails = TRUE
           PRINT(RPT:detailh)
         END
         
         LOOP
           DO GetNextRecord
           DO ValidateRecord
           CASE RecordStatus
             OF Record:OutOfRange
               LocalResponse = RequestCancelled
               BREAK
             OF Record:OK
               BREAK
           END
         END
         IF LocalResponse = RequestCancelled
            LocalResponse = RequestCompleted
            BREAK
         END
         LocalResponse = RequestCancelled
       END
       IF LocalResponse = RequestCompleted
         POST(Event:CloseWindow)
       END
    OF Event:Rejected
      BEEP
      DISPLAY(?)
      SELECT(?)
    END
    CASE FIELD()
    OF ?Progress:Cancel
      CASE EVENT()
      OF EVENT:Accepted
        DO SyncWindow
         LocalResponse = RequestCancelled
         POST(EVENT:CloseWindow)
      END
    END
  END
  IF SEND(STAVKE,'QUICKSCAN=off').
  IF LocalResponse = RequestCompleted
    ENDPAGE(Report)
    IF NOT SkipPreview THEN
       ReportPreview(PrintPreviewQueue)
    ELSE
       GlobalResponse = RequestCompleted
    END
    IF GlobalResponse = RequestCompleted
       IF NOT LocalReportTarget &= NULL THEN
          IF RECORDS(PrintPreviewQueue) THEN
             IF LocalReportTarget.SupportResultQueue()=True THEN
                LocalReportTarget.SetResultQueue(LocalOutputFileQueue)
             END
             ! The false parameter indicates that the AskProperties must ask for a name
             ! only if the target name is blank
             IF LocalReportTarget.AskProperties(False)=Level:Benign THEN
                LocalWMFParser.Init(PrintPreviewQueue, LocalReportTarget)
                IF LocalWMFParser.GenerateReport(ShowOutputProgress)=Level:Benign THEN
                   IF LocalReportTarget.SupportResultQueue()=True THEN
                      Do ProcessOutputFileQueue
                   END
                END
             END
          END
       ELSE
          FREE(LocalOutputFileQueue)
          LOOP PreviewQueueIndex=1 TO RECORDS(PrintPreviewQueue)
               GET(PrintPreviewQueue,PreviewQueueIndex)
               IF NOT ERRORCODE() THEN
                  LocalOutputFileQueue.FileName = PrintPreviewQueue.FileName
                  ADD(LocalOutputFileQueue)
               END
          END
          Do ProcessOutputFileQueue
          FREE(LocalOutputFileQueue)
          Report{PROP:FlushPreview} = True
       END
    END
  END
  CLOSE(Report)
  FREE(PrintPreviewQueue)
  DO ProcedureReturn
!---------------------------------------------------------------------------
!-----------------------------------------------------------------------------
ValidateRecord       ROUTINE
!|
!| This routine is used to provide for complex record filtering and range limiting. This
!| routine is only generated if you've included your own code in the EMBED points provided in
!| this routine.
!|
  RecordStatus = Record:OutOfRange
  IF LocalResponse = RequestCancelled THEN EXIT.
  RecordStatus = Record:OK
  EXIT
GetNextRecord ROUTINE
!|
!| This routine is used to retrieve the next record from the VIEW.
!|
!| After the record has been retrieved, the PROGRESS control on the
!| Progress window is updated.
!|
  NEXT(Process:View)
  IF ERRORCODE()
     IF ERRORCODE() <> BadRecErr
       StandardWarning(Warn:RecordFetchError,'STAVKE')
     END
     LocalResponse = RequestCancelled
     EXIT
  ELSE
     LocalResponse = RequestCompleted
  END
  RecordsProcessed += 1
  RecordsThisCycle += 1
  IF PercentProgress < 100
     PercentProgress = (RecordsProcessed / RecordsToProcess)*100
     IF PercentProgress > 100
        PercentProgress = 100
     END
     IF PercentProgress <> Progress:Thermometer THEN
        Progress:Thermometer = PercentProgress
        ?Progress:PctText{Prop:Text} = FORMAT(PercentProgress,@N3) & '% Completed'
        DISPLAY()
     END
  END
GetFirstRecord ROUTINE
!|
!| This routine open the view, set the range and the filter and also
!| is used to retrieve the first record from the VIEW.
!| 
!| After the record has been retrieved, the PROGRESS control on the
!| Progress window is updated.
!|
  SET(STA:DOKUMENTI)
  Process:View{Prop:Filter} = 'STA:DOKUMENT = l:IdDOKument'
  OPEN(Process:View)
  IF ERRORCODE()
     StandardWarning(Warn:ViewOpenError)
  END
  IF CLIP(Process:View{PROP:Order}) THEN
     SET(Process:View)
  END
  LOOP
     DO GetNextRecord
     DO ValidateRecord
     CASE RecordStatus
        OF Record:Ok
           BREAK
        OF Record:OutOfRange
           LocalResponse = RequestCancelled
           BREAK
     END
  END
ProcessOutputFileQueue          ROUTINE
SetStaticControlsAttributes     ROUTINE
SetDynamicControlsAttributes    ROUTINE
PrepareProcedure ROUTINE
  IF DOKUMENT::Used = 0
    CheckOpen(DOKUMENT,1)
  END
  DOKUMENT::Used += 1
  IF DOKUMENTAlias::Used = 0
    CheckOpen(DOKUMENTAlias,1)
  END
  DOKUMENTAlias::Used += 1
  IF PARTNERI::Used = 0
    CheckOpen(PARTNERI,1)
  END
  PARTNERI::Used += 1
  IF Parametri::Used = 0
    CheckOpen(Parametri,0)
  END
  Parametri::Used += 1
  IF Registri::Used = 0
    CheckOpen(Registri,1)
  END
  Registri::Used += 1
  IF STAVKE::Used = 0
    CheckOpen(STAVKE,1)
  END
  STAVKE::Used += 1
  IF STRUKTURAFIRME::Used = 0
    CheckOpen(STRUKTURAFIRME,1)
  END
  STRUKTURAFIRME::Used += 1
  IF czCezihOdgovori::Used = 0
    CheckOpen(czCezihOdgovori,1)
  END
  czCezihOdgovori::Used += 1
  IF czPropisivaci_Zahtjev::Used = 0
    CheckOpen(czPropisivaci_Zahtjev,1)
  END
  czPropisivaci_Zahtjev::Used += 1
  IF czUstanove::Used = 0
    CheckOpen(czUstanove,1)
  END
  czUstanove::Used += 1
  IF czZahtjev::Used = 0
    CheckOpen(czZahtjev,1)
  END
  czZahtjev::Used += 1
  IF fOperater::Used = 0
    CheckOpen(fOperater,1)
  END
  fOperater::Used += 1
  IF mDOKUMENT::Used = 0
    CheckOpen(mDOKUMENT,1,22h)
  END
  mDOKUMENT::Used += 1
  FilesOpened = TRUE
  DO BindFields
    RecordsToProcess = 500
    RecordsPerCycle = 25
    RecordsProcessed = 0
    PercentProgress = 0
    RecordsToProcess=RECORDS(qDOK)    
    RecordsPerCycle = 1
    !    IF pSvi=1 THEN
    !    !        l:sveOK=TRUE
    !    !    ELSE
    !            DO InitLoc
    !    !    END
    !    
    !    
    !    
    !    
    !    IF l:sveOK=FALSE THEN
    !        DO ProcedureReturn
    !    END
    !    
  ! if 1=2
  OPEN(ProgressWindow)
  WindowOpened=True
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ! .
  Do DefineListboxStyle
  if 1=2
  ProgressWindow{Prop:Text} = 'Generating Report'
  ?Progress:PctText{Prop:Text} = '0% Completed'
  ?Progress:UserString{Prop:Text}=''
    END      
  ?Progress:PctText{Prop:Text} = '0% Completed'
  ?Progress:UserString{Prop:Text}=''
  SEND(STAVKE,'QUICKSCAN=on')

!---------------------------------------------------------------------------
BindFields ROUTINE
  BIND(DOK:RECORD)
  BIND('DOK:NAPOMENA',DOK:NAPOMENA)
  BIND(DOK1:RECORD)
  BIND('DOK1:NAPOMENA',DOK1:NAPOMENA)
  BIND(PAR:RECORD)
  BIND('PAR:NAPOMENA',PAR:NAPOMENA)
  BIND(Param:RECORD)
  BIND(Reg:RECORD)
  BIND('Reg:NAPOMENA',Reg:NAPOMENA)
  BIND(STA:RECORD)
  BIND('STA:NAZIV',STA:NAZIV)
  BIND('STA:OPIS',STA:OPIS)
  BIND(STR:RECORD)
  BIND(czOdg:RECORD)
  BIND(PZH:RECORD)
  BIND(czU:RECORD)
  BIND(czZ:RECORD)
  BIND(fOpe:RECORD)
  BIND(mDOK:RECORD)
  BIND('mDOK:NAPOMENA',mDOK:NAPOMENA)
  BIND('l:IdDOKument',l:IdDOKument)                        ! Added by: Report
!---------------------------------------------------------------------------
UnBindFields ROUTINE
!---------------------------------------------------------------------------
ProcedureReturn ROUTINE
!|
!| This routine provides a common procedure exit point for all template
!| generated procedures.
!|
!| First, all of the files opened by this procedure are closed.
!|
!| Next, if it was opened by this procedure, the window is closed.
!|
!| Next, GlobalResponse is assigned a value to signal the calling procedure
!| what happened in this procedure.
!|
!| Next, we replace the BINDings that were in place when the procedure initialized
!| (and saved with PUSHBIND) using POPBIND.
!|
!| Finally, we return to the calling procedure.
!|
  IF FilesOpened
    CLOSE(Process:View)
    DOKUMENT::Used -= 1
    IF DOKUMENT::Used = 0 THEN CLOSE(DOKUMENT).
    DOKUMENTAlias::Used -= 1
    IF DOKUMENTAlias::Used = 0 THEN CLOSE(DOKUMENTAlias).
    PARTNERI::Used -= 1
    IF PARTNERI::Used = 0 THEN CLOSE(PARTNERI).
    Parametri::Used -= 1
    IF Parametri::Used = 0 THEN CLOSE(Parametri).
    Registri::Used -= 1
    IF Registri::Used = 0 THEN CLOSE(Registri).
    STAVKE::Used -= 1
    IF STAVKE::Used = 0 THEN CLOSE(STAVKE).
    STRUKTURAFIRME::Used -= 1
    IF STRUKTURAFIRME::Used = 0 THEN CLOSE(STRUKTURAFIRME).
    czCezihOdgovori::Used -= 1
    IF czCezihOdgovori::Used = 0 THEN CLOSE(czCezihOdgovori).
    czPropisivaci_Zahtjev::Used -= 1
    IF czPropisivaci_Zahtjev::Used = 0 THEN CLOSE(czPropisivaci_Zahtjev).
    czUstanove::Used -= 1
    IF czUstanove::Used = 0 THEN CLOSE(czUstanove).
    czZahtjev::Used -= 1
    IF czZahtjev::Used = 0 THEN CLOSE(czZahtjev).
    fOperater::Used -= 1
    IF fOperater::Used = 0 THEN CLOSE(fOperater).
    mDOKUMENT::Used -= 1
    IF mDOKUMENT::Used = 0 THEN CLOSE(mDOKUMENT).
  END
  IF WindowOpened
    CLOSE(ProgressWindow)
  END
  Do UnBindFields
             
    
  IF BAND(Keystate(),KeyStateUD:Shift) 
        UD.ShowProcedureInfo('Rac_2026',UD.SetApplicationName('fpomagala_ip','EXE'),'None','01/05/2026 @ 06:35PM','03/24/2026 @ 03:10PM','03/27/2026 @ 08:36PM')  
    
  END
  IF LocalResponse
    GlobalResponse = LocalResponse
  ELSE
    GlobalResponse = RequestCancelled
  END
  POPBIND
  RETURN
!---------------------------------------------------------------------------
InitializeWindow ROUTINE
!|
!| This routine is used to prepare any control templates for use. It should be called once
!| per procedure.
!|
  DO RefreshWindow
!---------------------------------------------------------------------------
RefreshWindow ROUTINE
!|
!| This routine is used to keep all displays and control templates current.
!|
  IF ProgressWindow{Prop:AcceptAll} THEN EXIT.
  Do LookupRelated
  DISPLAY()
  ForceRefresh = False
!---------------------------------------------------------------------------
SyncWindow ROUTINE
!|
!| This routine is used to insure that any records pointed to in control
!| templates are fetched before any procedures are called via buttons or menu
!| options.
!|
  Do LookupRelated
!---------------------------------------------------------------------------
LookupRelated  ROUTINE
!|
!| This routine fetch all related records.
!| It's called from SyncWindow and RefreshWindow
!|
!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It's called after the window open
!|
!---------------------------------------------------------------------------
fiskal                                  ROUTINE

   ! CHOOSE(CLIP(mDOK:JIR)<>'','JIR: '&CLIP(mDOK:JIR)&', ','')&CHOOSE(CLIP(mDOK:ZKI)<>'','ZKI: '&CLIP(mDOK:ZKI)&',\line ','')&'Oznaka operatera: '&FORMAT(mDOK:Kreirao,@n04)&', Vrijeme izdavanja raèuna: '&FORMAT(mDOK:VrijemeIzdavanja,@t07b)&', Interna oznaka: '&mDOK:Broj&', Naèin plaæanja: '&CHOOSE(Registar('NPL',mDOK:SredstvoPlacanja)<>'', CHOOSE(INLIST(CHR(REG:Datum),'G','K','C','T','O'), 'Novèanice','Kartica','Èek','Transakcijski raèun','Ostalo'), 'Ostalo')

InitLOC                                 ROUTINE

    l:sveOK = TRUE

    
    !InitLOC             ROUTINE
 !   ud.debug('RAC: InitLOC 1 mDOK:DOKUMENT '&mDOK:DOKUMENT &' mDOK:PARTNER='&mDOK:PARTNER)
    
     cOpc.Init(Parametri,Param:OPCIJE,Param:SET,Param:SEKCIJA,Param:OPCIJA,Param:VRIJEDNOST,GO:Godina)
    cStrukturaFirme.Init(STRUKTURAFIRME,STR:STF:RAZINE, STR:STF:IDS, STR:STF:ID,STR:STF:RAZINA,STR:STF:SIFRA,STR:STF:NAZIV,STR:STF:ULICA, STR:STF:KUCNIBROJ,STR:STF:KUCNIBROJDODATAK,STR:STF:BROJPOSTE,STR:STF:NASELJE,STR:STF:OPCINA)
    l:Ukupno_S=0
    l:UK_IznosRazlikeUCijeni=0
    
    l:Uk_Razlika_UK=0
    l:JedRazlika=0
    l:Uk_Razlika=0
    l:UK_IznosRazlikeUCijeni=0
    !l:Stopa1=0
    l:Osnovica1=0
    l:Iznospp1=0
    l:Stopa2=0
    l:Osnovica2=0
    l:Iznospp2=0
    l:cijenaUK=0
    l:UkIznosZaPomagala=0
    l:IznosSudjelovanja=0
    l:IznosNaTeretObaveznogZdravstvenogOsig=0
    l:IznosPDVaObaveznogOsig=0
    !---
    Clear(l:Stopa1)
    Clear(l:Stopa2)
    Clear(l:Iznospp1)
    Clear(l:Iznospp2)
    Clear(l:Osnovica1)
    Clear(l:Osnovica2)
    
!----
!    IF GO:PrikaziRTF_Sakrij_Logo=true
!        Report$?Image1{PROP:hide}=TRUE
!        ud.debug('Sakrivam logo')
!    ELSE
!         Report$?Image1{PROP:Text} = CLIP(GLO:PutanjaDoFuterLoga)
!        Report$?l:Rtf_Futer{PROP:Hide}=TRUE
!        ud.debug('Sakrivam RTF')
!    END

    l:PdfFileName=clip(GLO:ExportFilename)&'.pdf'
    !----
    l:IdPartner=DOK:PARTNER
    DO Load_Partneri
    l:Oib='OIB: ' &CLIP(PAR:OIB)
    l:PodrucniUred ='Podruèni ured: ' &CLIP(PAR:NAZIV)
    !---- Get mjesto iz registri
    Reg:BAZA='GRD'
    Reg:SIFRA=PAR:OBLAST
    GET(Registri,Reg:SIFRE)
    IF ERRORCODE()
        CezihExportLog('logiraj',log_status:Greska,'Rac: InitLOC: GET(Registri,Reg:SIFRE) '&ERROR(),' Raèun='&BrojRacuna(DOK:DOKUMENT))                                    
        
     !   MESSAGE('Rac: InitLOC: GET(Registri,Reg:SIFRE) '&ERROR(),'Fatal error!!!')
        l:sveOK=FALSE
    END
    l:Mjesto='Mjesto: ' &CLIP(Reg:NAZIV)
    l:Ulica_I_Broj='Ulica i broj: ' &CLIP(PAR:ADRESA1)
    !CHOOSE(Registar('NPL',mDOK:SredstvoPlacanja)<>'', CHOOSE(INLIST(CHR(REG:Datum),'G','K','C','T','O'), 'Novèanice','Kartica','Èek','Transakcijski raèun','Ostalo'), 'Ostalo')
    l:FiskalFuter='Oznaka operatera:' &FORMAT(DOK:KREIRAO,@n04) &',' &' Vrijeme izdavanja raèuna: ' &FORMAT(DOK:VRIJEMEIZDAVANJA,@t7) &', Interna oznaka: ' &DOK:BROJ &', Naèin plaæanja: ' |
        & CHOOSE(Registar('NPL',DOK:SredstvoPlacanja)<>'', CHOOSE(INLIST(CHR(REG:Datum),'G','K','C','T','O'), 'Novèanice','Kartica','Èek','Transakcijski raèun','Ostalo'), 'Ostalo')


    IF GLO:VrstaIspisa='OS1' THEN
        l:RacunZa='RAÈUN za obvezno zdravstveno osiguranje'
        l:RacunBroj='Raèun broj: ' &clip(BrojRacuna(DOK:DOKUMENT)) !&'O'
        ud.debug('GLO:VrstaIspisa=OS l:RacunBroj='&l:RacunBroj)
        Report$?SDOP{PROP:Hide}=TRUE
        Report$?l:f6{PROP:Hide}=TRUE
        Report$?l:f6_Iznos{PROP:Hide}=TRUE
    ELSif GLO:VrstaIspisa='DOP1' THEN
        IF qDOK.D1[1:2]='P1' OR qDOK.D1[1:2]='P0'
            CezihExportLog('logiraj',log_status:Greska,'Greška prilikom exporta ','U sluèaju kada je dimenzija1='&qDOK.D1 &' ne ispisuje se raèun za dopunsko osiguranje! Raèun='&BrojRacuna(DOK:DOKUMENT))                            
           ! MESSAGE('U sluèaju kada je dimenzija1='&mDOK:D1 &' ne ispisuje se raèun za dopunsko osiguranje!','Upozorenje!!!',ICON:Exclamation)            
            DO procedurereturn
        END
        Report$?SDOP{PROP:Hide}=FALSE
        Report$?l:f6{PROP:Hide}=FALSE
        Report$?l:f6_Iznos{PROP:Hide}=FALSE
        l:RacunZa='RAÈUN za dopunsko zdravstveno osiguranje'
        !l:RacunBroj='Raèun broj: ' &clip(BrojRacuna(DOK:DOKUMENT))! &'D'
        if CLIP(DOK:OPIS2)=''
            CezihExportLog('logiraj',log_status:Greska,'Greška prilikom exporta ','U sluèaju kada je dimenzija1='&qDOK.D1&' Id dopunskog raèuna mora biti upisan!| OsnId='&dok:BROJ)                            
        END
        
        l:RacunBroj='Raèun broj: ' &DOK:OPIS2
        ud.debug('GLO:VrstaIspisa=DOP l:RacunBroj='&l:RacunBroj)
    ELSE
        CezihExportLog('logiraj',log_status:Greska,'Greška prilikom Ispisa ','Rac: InitLOC:GLO:VrstaIspisa '&ERROR() &' GLO:VrstaIspisa='&GLO:VrstaIspisa &' Raèun='&BrojRacuna(DOK:DOKUMENT))                                    
       ! MESSAGE('Rac: InitLOC:GLO:VrstaIspisa '&ERROR() &' GLO:VrstaIspisa='&GLO:VrstaIspisa,'Fatal error!!!')
        l:sveOK=FALSE
    END
 !   ud.debug('GetPCS_Skladista ')
    
    !l:SifraMaloprodajneLokacije = Get_SifraOrgJed(GLO:OperaterId)!cOpc.GetPCS_Skladista(DOK:ORGJED1)
    l:SifraMaloprodajneLokacije = cOpc.GetPCS_Skladista(DOK:ORGJED1)
 !   ud.debug('GetNaziv_Poduzeca ')
    
   
    
    !----
    l:Naziv=cStrukturaFirme.GetNaziv_Poduzeca()
    !----
    ud.debug('xx='&cOpc.GetStrukturaFirmeID_Skladista(DOK:ORGJED1) &' '&DOK:ORGJED1 &' --'&cStrukturaFirme.GetNaselje_Skladista(cOpc.GetStrukturaFirmeID_Skladista(DOK:ORGJED1)))
    l:Adresa= clip(cStrukturaFirme.GetOpcina_Skladista(cOpc.GetStrukturaFirmeID_Skladista(DOK:ORGJED1))) |
        &' ' &clip(cStrukturaFirme.GetUlica_Skladista(cOpc.GetStrukturaFirmeID_Skladista(DOK:ORGJED1))) &' ' |
        &' ' &CHOOSE(clip(cStrukturaFirme.GetKucniBroj_Skladista(cOpc.GetStrukturaFirmeID_Skladista(DOK:ORGJED1)))='',' bb', clip(cStrukturaFirme.GetKucniBroj_Skladista(cOpc.GetStrukturaFirmeID_Skladista(DOK:ORGJED1))) )     &' ' |
        &' ' &clip(cStrukturaFirme.GetKucniBrojDodatak_Skladista(cOpc.GetStrukturaFirmeID_Skladista(DOK:ORGJED1)))
    !----
    l:Ziro = cOpc.GetZiro_Poduzeca()

    l:BrojPotvrdeRacuna=CLIP(DOK:OPIS) & CLIP(DOK:OPIS1)
    l:MaticniBroj_Oib= CLIP(cOpc.GetMaticniBroj_Poduzeca()) &' ' &CLIP(cOpc.GetOIB_Poduzeca())
    l:PozivNaBroj=CLIP(DOK:BROJ) &'-' &CLIP(GO:Godina)
    !----
!    DOK1:DOKUMENT = mDOK:DOKUMENT1
!    GET(DOKUMENTAlias,DOK1:DOKUMENTI)
!    IF ERRORCODE()
!        CezihExportLog('logiraj',log_status:Greska,'Greška prilikom Ispisa ','Rac: Rac: InitLOC: GET(DOKUMENTAlias,DOK1:DOKUMENTI)' &' Raèun='&BrojRacuna(mDOK:DOKUMENT))                                    
!        
!        !MESSAGE('Rac: InitLOC: GET(DOKUMENTAlias,DOK1:DOKUMENTI) '&ERROR(),'Fatal error!!!')
!        l:sveOK=FALSE
!        EXIT
!    END

    
    
    l:IdPartner=DOK1:PARTNER
    DO Load_Partneri
    l:BrojPolice = CLIP(PAR:WWW)
    do Identifikator_Zahtjeva
    do PronajdiFakturistu
    do AdresuIMjestoNaRacunuVuciSUstanove
    !----
    IF GLO:VrstaIspisa='OS1'
        l:f1='1. Ukupan iznos (s PDV-om):'
        l:f2='2. Iznos sudjelovanja:'
        l:f3='3. Iznos na teret obveznog zdravstvenog osiguranja:'
        l:f4='4. Iznos razlike u cijeni '
        l:f5='5. Iznos obraèunatog PDV-a u toèki 3.'
        l:f6=''
        
    ELSIF GLO:VrstaIspisa='DOP1'
        l:f1='1. Ukupan iznos (s PDV-om):'
        l:f2='2. Iznos sudjelovanja:'
        l:f3='3. Iznos na teret obveznog zdravstvenog osiguranja:'
        l:f4='4. Iznos razlike u cijeni '
        l:f5='5. Iznos na teret dopunskog zdravstvenog osiguranja'
        l:f6='6. Iznos obraèunatog PDV-a u toèki 5.'
    ELSE
        CezihExportLog('logiraj',log_status:Greska,'Rac: InitLOC nepozata vrsta ispisa '&GLO:VrstaIspisa,' Raèun='&BrojRacuna(DOK:DOKUMENT))                                    
        
       ! MESSAGE('rac: InitLOC nepozata vrsta ispisa '&GLO:VrstaIspisa)
        l:sveOK=FALSE
    END
    !----
  ud.Debug('rac_2026  InitLOC end')
KojiFuter                               ROUTINE
      !----
    IF GO:PrikaziRTF_Sakrij_Logo=true
        Report$?Image1{PROP:hide}=TRUE
      !  ud.debug('Sakrivam logo')
    ELSE
        Report$?Image1{PROP:Text} = CLIP(GLO:PutanjaDoFuterLoga)
      !  Report$?Image1{PROP:Stretch}=TRUE
        
        Report$?l:Rtf_Futer{PROP:Hide}=TRUE
      !  ud.debug('Sakrivam RTF')
    END
Load_Partneri                           ROUTINE
    PAR:PARTNER = l:IdPartner
    GET(PARTNERI,PAR:PARTNERI)
    IF ERRORCODE()
        CezihExportLog('logiraj',log_status:Greska,'Greška prilikom Ispisa ','RAC: Load_Partneri: Ne mogu uèitati partnera '&l:IdPartner &' - '&ERROR()  )                                    
        
       ! MESSAGE('RAC: Load_Partneri: Ne mogu uèitati partnera '&mDOK:PARTNER &' - '&ERROR(),'Fatal Error!!!')
        l:sveOK=FALSE
    ELSE
      !  ud.Debug('Load_Partneri: l:IdPartner='&l:IdPartner &'  mDOK:DOKUMENT='&mDOK:DOKUMENT)
    END

prvi                                    ROUTINE
    
    
    
    
    
    mSTA:DOKUMENT = mDOK:DOKUMENT
    mSTA:REDNIBROJ=0
    SET(mSTA:DOKUMENTI,mSTA:DOKUMENTI)
    Next(mSTAVKE)
    IF ERRORCODE() OR mSTA:DOKUMENT <> mDOK:DOKUMENT
      !  MESSAGE('Nisam pronašao stavke dokumenta !','Izlazim!!!')
        CezihExportLog('logiraj',log_status:Greska,'Greška prilikom Ispisa ','RAC: Nisam pronašao stavke dokumenta ' &' Raèun='&BrojRacuna(mDOK:DOKUMENT))                                    
        
           POST(EVENT:CloseWindow)
    END

lup                 ROUTINE
  !  ud.DebugQueue(qDok)
    ud.Debug('Rac_2025  LUP START')
   loop jj#=1 to records(qDOK)
        get(qDOK,jj#)
        if ERRORCODE()
            CezihExportLog('logiraj',log_status:Greska,'Greška prilikom exporta ','Exprt: Greška get(qDOK)-> '&error())
            l:Sveok=FALSE
   
            break
        END
        GO:Dokument=qDOK.qdokument
        do PrintRacun
         
    END
   ud.Debug('Rac_2025  LUP END')
PrintRacun          ROUTINE
    
         mDOK:DOKUMENT = GO:Dokument
        get(mDOKUMENT,mDOK:DOKUMENTI)
        if ERRORCODE()
            CezihExportLog('logiraj',log_status:Greska,'Greška prilikom exporta ','Greška prilikom pristupa dokumentu: '&mDOK:DOKUMENT &'-' &ERROR())
            l:Sveok=FALSE
           ! message('Greška prilikom pristupa dokumentu: '&mDOK:DOKUMENT &'-' &ERROR(),'GREŠKA PRILIKOM EXPORTA !!!' )
            exit!BREAK
        END        
        
        if psvi=TRUE
            if qDOK.D1[1:2]='P1' or qDOK.D1[1:2]='P0'
                GLO:VrstaIspisa  = 'OS1'
                do lup_2
            elsif qDOK.D1[1:2]='D1' 
                GLO:VrstaIspisa  = 'OS1'
                do lup_2
                GLO:VrstaIspisa  = 'DOP1'
                do lup_2
            ELSE
                CezihExportLog('logiraj',log_status:Greska,'Greška prilikom exporta 1','PrintRacun: pogrešna vrijednost  qDOK.D1: ' & qDOK.D1 &' dok:id='&mDOK:DOKUMENT &'-' &ERROR())
            END
        ELSE
             if qDOK.D1[1:2]='P1' or qDOK.D1[1:2]='P0'
                GLO:VrstaIspisa  = 'OS1'
                do lup_2
            elsif qDOK.D1[1:2]='D1'             
                GLO:VrstaIspisa  = 'DOP1'
                    do lup_2
            ELSE
                    CezihExportLog('logiraj',log_status:Greska,'Greška prilikom exporta 2 ','PrintRacun: pogrešna vrijednost  qDOK.D1: ' & qDOK.D1 &' dok:id='&mDOK:DOKUMENT &'-' &ERROR())
                END
            
        END
    
    do Progres
    
lup_2 ROUTINE    
    ud.Debug('--- lup Start---')
    !-- Get IFA OSN
    DOK:DOKUMENT = qDOK.Osn_Id
    get(DOKUMENT,DOK:DOKUMENTI)
    if ERRORCODE()
        CezihExportLog('logiraj',log_status:Greska,'Greška prilikom Ispisa ','lup_2: Greška prilikom dohvata dokumenta DOK:DOKUMENT = '&qDOK.Osn_Id   &' Raèun='&BrojRacuna(qDOK.Osn_Id))                                                
       !     message('Greška prilikom pristupa robi id= '&mSTA:ROBA &' - ' &ERROR())
        l:sveok=FALSE
        do procedurereturn
    END
    if DOK:DOKUMENT1<>0
        DOK1:DOKUMENT = DOK:DOKUMENT1
        get(DOKUMENTAlias,DOK1:DOKUMENTI)
        if ERRORCODE()
            CezihExportLog('logiraj',log_status:Greska,'Greška prilikom Ispisa ','lup_2: Greška prilikom dohvata dokumenta DOK:DOKUMENT1 = '&DOK:DOKUMENT1   &' Raèun='&BrojRacuna(DOK:DOKUMENT1))                                                
       !     message('Greška prilikom pristupa robi id= '&mSTA:ROBA &' - ' &ERROR())
            l:sveok=FALSE
            do procedurereturn
        END
    END
    
    
    !----
    DO InitLOC
    !----
    l:sveOK=TRUE
   ! Report$?Image1{PROP:Text} = 'd:\s1.jpg'
    !Report$?Image1{PROP:Text} = 'w:\4d\wand\LOGO\Memo_Dno_cb.jpg'

    DO Print_ZaglavljeStavke
    l:ImaLiUslugeUStavkama=FALSE
    l:Br=0
    !----
    l:Ukupno_S=0
    l:UK_IznosRazlikeUCijeni=0
    
    mSTA:DOKUMENT = mDOK:DOKUMENT
    mSTA:REDNIBROJ=0
    SET(mSTA:DOKUMENTI,mSTA:DOKUMENTI)
    loop
        Next(mSTAVKE)
        IF ERRORCODE() or mSTA:DOKUMENT <> mDOK:DOKUMENT THEN BREAK.
        !--
        Rob:ROBA = mSTA:ROBA
        get(Robe,Rob:ROBE)
        if ERRORCODE()
        CezihExportLog('logiraj',log_status:Greska,'Greška prilikom Ispisa ','RAC: Greška prilikom pristupa robi id= '&mSTA:ROBA   &' Raèun='&BrojRacuna(DOK:DOKUMENT))                                    
            
       !     message('Greška prilikom pristupa robi id= '&mSTA:ROBA &' - ' &ERROR())
            l:sveok=FALSE
            do procedurereturn
        END
              
        IF Rob:KATBROJ=clip(GLO:Kat_5) or Rob:KATBROJ=clip(GLO:Kat_25) or Rob:KATBROJ=clip(GLO:Kat_13) THEN  
            l:ImaLiUslugeUStavkama=TRUE
            CYCLE
        end
        
!        IF Rob:VRSTA=2   THEN
!           ! IF Rob:KATBROJ=GLO:Kat_5 OR Rob:KATBROJ=GLO:Kat_25 OR Rob:KATBROJ=GLO:Kat_13
!                l:ImaLiUslugeUStavkama=TRUE
!           ! END
!            CYCLE
!        . ! ZA SADA
        !----

        l:Br+=1
        do napunistavku
        do IzracunajPDV
        !----
        DO Print_Stavku
    END
    !---- futer 1
    !l:UkIznosZaPomagala =  Izracunaj_UkupanIznos(l:Ukupno_S)+l:UK_IznosRazlikeUCijeni
    l:UkIznosZaPomagala =  l:Ukupno_S+l:UK_IznosRazlikeUCijeni   !2023 11 06
    !---- futer 2
    IF qDOK.D1[1:2]='D1'
        IF GLO:VrstaIspisa='OS1'
            l:IznosSudjelovanja = Izracunaj_IznosNaTeretDopunskog()
           ! MESSAGE('l:IznosSudjelovanja='&l:IznosSudjelovanja)
        ELSIF  GLO:VrstaIspisa='DOP1'
            l:IznosSudjelovanja =0!Izracunaj_IznosNaTeretDopunskog()! Izracunaj_IznosNaTeretObaveznog()
        END
    ELSIF qDOK.D1[1:2]='P1'
        IF l:ImaLiUslugeUStavkama=FALSE AND mDOK:iznosfakture>50
        CezihExportLog('logiraj',log_status:Greska,'Greška prilikom Ispisa ','RAC: Niste unijeli uslugu participacije '  &' Raèun='&BrojRacuna(DOK:DOKUMENT))                                    
            
          !  message('Niste unijeli uslugu participacije!','UPOZORENJE!',ICON:Exclamation)
            DO PROCEDURERETURN
        END
        l:IznosSudjelovanja = Izracunaj_IznosSudjelovanja(l:Ukupno_S)
        SETTARGET(Report)
        ?SDOP{PROP:Hide}=TRUE
        SETTARGET
    ELSIF qDOK.D1[1:2]='P0'
        SETTARGET(Report)
        ?SDOP{PROP:Hide}=TRUE
        SETTARGET
        l:IznosSudjelovanja = 0
    ELSE
        
        MESSAGE('Greška u logici br 7!!')
        DO procedurereturn
        l:sveok=FALSE
    END
    !---- futer 3
    IF GLO:VrstaIspisa='OS1'
      l:IznosNaTeretObaveznogZdravstvenogOsig = Izracunaj_IznosNaTeretObaveznog()
    ELSIF GLO:VrstaIspisa='DOP1'
        l:IznosNaTeretObaveznogZdravstvenogOsig = Izracunaj_IznosNaTeretObaveznog() !Izracunaj_IznosNaTeretDopunskog()
        
    END
    !---- futer 6
    IF GLO:VrstaIspisa='OS1'
      l:IznosPDVaObaveznogOsig = Izracunaj_IznosPdvObaveznogOsig()
    ELSIF GLO:VrstaIspisa='DOP1'
        l:IznosPDVaObaveznogOsig = Izracunaj_IznosPdvDopOsig()
        l:f6_Iznos=l:IznosPDVaObaveznogOsig
       l:IznosPDVaObaveznogOsig= Izracunaj_IznosNaTeretDopunskog()
    END

  !  UD.Debug('l:IznosNaTeretObaveznogZdravstvenogOsig = '&l:IznosNaTeretObaveznogZdravstvenogOsig)

    l:DatumNarudjbe ='Datum narudžbe: ' &FORMAT(DOK:DATUMNARUDZBE,@d017.)
    l:DatumIzdavanjaPomagala= 'Datum izdavanja pomagala: ' &format(DOK:DATUM,@d017.)
    if GLO:AdresuIMjestoNaRacunuVuciSUstanove=0 then !ako Mjesto vuèe iz ustanove onda je veæ popunjeno i ne treba ga ovdje punit
        l:Mjesto_Izdavanja = CLIP(cStrukturaFirme.GetOpcina_Skladista(cOpc.GetStrukturaFirmeID_Skladista(DOK:ORGJED1)))
    END
    
    l:MjestoIDatumIzdavanjaRacuna ='Mjesto i datum izdavanja raèuna: ' & CLIP(l:Mjesto_Izdavanja) &', ' &FORMAT(DOK:DATUM,@d017.)

    DO Print_FuterStavke
    ud.Debug(' --- lup Start--- ')
    
    ENDPAGE(Report)

napunistavku                            ROUTINE

    l:Sifra_S= clip(VratiHZZOSifruArtikla())
    l:Naziv_S= VratiNazivArtikla()!choose(ROB:Naziv2<>'',rob:naziv2,rob:naziv)
    l:Kol_S = mSTA:KOLICINA2
    l:Cijena_S= Izracunaj_JedCijena()
    l:Iznos_S= Izracunaj_Iznos()
    l:cijenaUK+=l:Cijena_S
    l:Ukupno_S+=l:Iznos_S
    !--
  !  ud.Debug('l:Sifra_S '&clip(l:Sifra_S)  &' l:Cijena_S='&l:Cijena_S &' l:Iznos_S='&l:Iznos_S)
    
    l:JedRazlika=0
    l:Uk_Razlika=0
    l:JedRazlika=Izracunaj_JedinicnaRazlikaUCijeniSPdv()
    if l:JedRazlika < 0 !neka greška
        l:JedRazlika=0
    else    
        l:Uk_Razlika = l:JedRazlika * l:Kol_S 
    END  
    l:Uk_Razlika_UK += l:Uk_Razlika
    l:UK_IznosRazlikeUCijeni=l:Uk_Razlika_UK
    
Progres             ROUTINE
    
    RecordsProcessed += 1
  RecordsThisCycle += 1
  IF PercentProgress < 100
     PercentProgress = (RecordsProcessed / RecordsToProcess)*100
     IF PercentProgress > 100
        PercentProgress = 100
     END
     IF PercentProgress <> Progress:Thermometer THEN
        Progress:Thermometer = PercentProgress
            ?Progress:PctText{Prop:Text} = FORMAT(PercentProgress,@N3) & '% Completed'
            ?Progress:UserString{PROP:Text}=BrojRacuna(mDOK:DOKUMENT)
        DISPLAY()
        ELSE
            RecordsProcessed=100
            RecordsThisCycle=100
            RecordsProcessed=100
            Progress:Thermometer=2500
            DISPLAY()
        END
    END
    ud.Debug('[Progres] RecordsToProcess='&RecordsToProcess &'  RecordsProcessed='&RecordsProcessed  &' RecordsThisCycle='&RecordsThisCycle &' PercentProgress='&PercentProgress &' Progress:Thermometer='&Progress:Thermometer)
Identifikator_Zahtjeva      ROUTINE
    
     !--- Identifikator Doznake
     !   ud.Debug('year(mDOK:DATUMIZDAVANJA)='&year(mDOK:DATUMIZDAVANJA)   &'  mDOK:DOKUMENT='&mDOK:DOKUMENT)
        l:ccZahtjev_Id=0
        l:BrojPronajdenihZahtjeva=0
        l:Identifikator_zahtjeva=''
        czZ:GodinaRacuna=year(DOK:DATUM)
        czZ:BrojRacunaID=DOK:DOKUMENT
        set(czZ:K_GodinaBrojRacuna,czZ:K_GodinaBrojRacuna)
        LOOP
            next(czZahtjev)
            if ERRORCODE() then 
                ud.Debug('Error= '&error())
                break
            END
         !   ud.Debug('  a1 ')
            
            if czZ:GodinaRacuna<>year(DOK:DATUM) or czZ:BrojRacunaID<>DOK:DOKUMENT then break.  
            if czZ:GodinaRacuna<>year(DOK:DATUM) then cycle.
         !   ud.Debug('  a2 ')
            l:ccZahtjev_Id=czZ:ID
            l:Identifikator_zahtjeva =clip(czZ:IdentifikatorZahtjeva) 
            l:BrojPronajdenihZahtjeva+=1            
        END   
        
        if l:BrojPronajdenihZahtjeva=0 !nismo našli ništa
            l:Identifikator_zahtjeva=''
            l:ccZahtjev_Id=0
        ELSIF l:BrojPronajdenihZahtjeva=1
           
        ELSE !greška, ima više od jednog zahtjeva po raèunu
            l:Identifikator_zahtjeva=''
            l:ccZahtjev_Id=0
        END
    
    if clip(l:BrojPotvrdeRacuna)=''
        l:BrojPotvrdeRacuna=clip(l:Identifikator_zahtjeva)
    END
    l:MBO_Pacijenta='MBO Pacijenta: ' &clip(PAR:BROJ)
    !----
    !ud.Debug('l:BrojPronajdenihZahtjeva='&l:BrojPronajdenihZahtjeva &' l:Identifikator_zahtjeva='&clip(l:Identifikator_zahtjeva))
    
PronajdiFakturistu  ROUTINE
DATA
CODE
    if GLO:FakturistKoJeIsporucio=false then exit.  
    
    GLO:Direktor2=''
    if l:ccZahtjev_Id=0
        PZH:ID=GLO:OperaterId
        get(czPropisivaci_Zahtjev,PZH:K_ID)
        if errorcode()
            GLO:Direktor2=''
        ELSE
            GLO:Direktor2 = clip(PZH:Ime) &' ' &clip(PZH:Prezime)
        END
    ELSE
        czOdg:cZahtjev_Id=l:ccZahtjev_Id
        czOdg:Id=1999999999
        set(czOdg:K_cZahtjevID_Id,czOdg:K_cZahtjevID_Id)
        LOOP
            PREVIOUS(czCezihOdgovori)
            if ERRORCODE() or czOdg:cZahtjev_Id<>l:ccZahtjev_Id then break.
            if czOdg:ProceduraNaziv=CezOdg_ProceduraNaziv:czeq_Izdavanje or czOdg:ProceduraNaziv = CezOdg_ProceduraNaziv:czeq_IzdavanjeOdgovor
               PZH:ID=czOdg:Id_Operater
                get(czPropisivaci_Zahtjev,PZH:K_ID)
                if errorcode()
                    GLO:Direktor2=''
                ELSE
                    GLO:Direktor2 = clip(PZH:Ime) &' ' &clip(PZH:Prezime)
                END
                BREAK
            END
        END
    END
    
        !MESSAGE(' GLO:OperaterId='&GLO:OperaterId)
        
        
AdresuIMjestoNaRacunuVuciSUstanove  ROUTINE
    
    if GLO:AdresuIMjestoNaRacunuVuciSUstanove=0 then exit.
    
    if l:ccZahtjev_Id=0 then exit.
    fOpe:Operater=czZ:IDfoperater
    get(fOperater,fOpe:Operateri)
    if errorcode() then exit.
    PZH:ID = fOpe:IDPropisivac
    get(czPropisivaci_Zahtjev,PZH:K_ID)
    if errorcode() then exit.
    czU:ID=PZH:IDUstanove
    get(czUstanove,czU:K_ID)
    if errorcode() then exit.
    
   ! l:Mjesto='Mjesto: ' &CLIP(czU:Grad)
   ! l:Ulica_I_Broj='Ulica i broj: ' &CLIP(czU:Ulica) &' ' &clip(czU:Broj)
    l:Adresa = CLIP(czU:Grad) &' ' &CLIP(czU:Ulica) &' ' &clip(czU:Broj)
    l:Mjesto_Izdavanja = CLIP(czU:Grad)
Print_ZaglavljeStavke       ROUTINE
 
    DO ProvjeraZaglavlja

    IF qDOK.D1[1:2]='P1'
        SETTARGET(Report)
        ?SDOP{PROP:Hide}=TRUE
        SETTARGET
    END

    PrintSkipDetails = TRUE
    PRINT(RPT:detailh) 
Print_Stavku                   ROUTINE
 
           DO ProvjeraStavke
           PrintSkipDetails = TRUE
           PRINT(RPT:Detail) 
Print_FuterStavke                   ROUTINE

!         PrintSkipDetails = FALSE
!         IF 1=2 THEN
!           PrintSkipDetails = TRUE
!           PRINT(RPT:Detail)
!         END
!         IF 1=2 THEN
           PrintSkipDetails = TRUE
           PRINT(RPT:detailF)
!         END
!         IF 1=2 THEN
!           PrintSkipDetails = TRUE
!           PRINT(RPT:detailh)
!         END
!
!
!------------------------------------
StaPrintati                             ROUTINE
   ! IF omitted(1)=FALSE
        IF pSvi=1 THEN
            UD.Debug('Printan sve')
           DO PrintSVE
        ELSE
            UD.Debug('Printan sve, a opet 1')
            DO lup
        END
   ! ELSE
    !    UD.Debug('Printan 1')
    !    DO lup
   ! END

PrintSVE                                ROUTINE
    MESSAGE('PrintSVE rutina se ne koristi ')!''!exit !privremeno
    exit    
    !LOGOUT(5,dokument,STAVKE,PARTNERI)
    !if ERRORCODE()
    !    message('Greška logout '&error())
    !    EXIT
    !END
    ud.debug('NapuniQ - '&GO:D3 )
    set(mDOKUMENT)
    LOOP
        next(mDOKUMENT)
        if ERRORCODE() then break.
        if upper(clip(GO:D3))<> upper(clip(mDOK:D3)) then cycle.
        IF mDOK:D1[1:2]='D1'
            GLO:VrstaIspisa='OS1'
            DO lup
            GLO:VrstaIspisa='DOP1'
            DO lup
        ELSE
            GLO:VrstaIspisa='OS1'
            DO lup
        END
    END


ProvjeraStavke      ROUTINE
    
    IF l:Sifra_S=''
       CezihExportLog('logiraj',log_status:Greska,'Greška prilikom Ispisa ','Za stavku br. '&l:Br &' (' &CLIP(l:Naziv_S) &') nije unešena šifra pomagala! '  &' Raèun='&BrojRacuna(mDOK:DOKUMENT))                                    

      !  MESSAGE('Za stavku br. '&l:Br &' (' &CLIP(l:Naziv_S) &') nije unešena šifra pomagala! ','UPOZORENJE!!!',ICON:Exclamation)
        l:sveOK=FALSE
        !DO procedurereturn
    END
    IF l:Naziv_S=''
       CezihExportLog('logiraj',log_status:Greska,'Greška prilikom Ispisa ','Za stavku br. '&l:Br &' nije upisan naziv! ' &' Raèun='&BrojRacuna(mDOK:DOKUMENT))                                    
        l:sveOK=FALSE
     !   MESSAGE('Za stavku br. '&l:Br &' nije upisan naziv! ','UPOZORENJE!!!',ICON:Exclamation)
        !DO procedurereturn
    END

ProvjeraZaglavlja                          ROUTINE
    IF l:SifraMaloprodajneLokacije=''
      !  MESSAGE('Niste upisali šifru maloprodajne lokacije! ','UPOZORENJE!!!',ICON:Exclamation)
       CezihExportLog('logiraj',log_status:Greska,'Niste upisali šifru maloprodajne lokacije! '  &' Raèun='&BrojRacuna(mDOK:DOKUMENT))                                    
        l:sveOK=FALSE
        
      !  DO procedurereturn
    END
    IF l:MaticniBroj_Oib=''
       CezihExportLog('logiraj',log_status:Greska,'Niste upisali matièni broj / OIB ! ' &' Raèun='&BrojRacuna(mDOK:DOKUMENT))                                    
        l:sveOK=FALSE
        
     !   MESSAGE('Niste upisali matièni broj / OIB ! ','UPOZORENJE!!!',ICON:Exclamation)
        DO procedurereturn
    END
!    IF l:BrojPotvrdeRacuna=''
!        MESSAGE('Niste upisali Broj potvrde / Raèuna ! ','UPOZORENJE!!!',ICON:Exclamation)
!        DO procedurereturn
!    END
!------------------------------------
IzracunajPDV                               ROUTINE
DATA
l:UK_TMP    REAL
CODE
    
    !-- STA:Tarifa - 7 = 5% 
    !-- STA:Tarifa - 6 = 25%  
    
    ! l:JedRazlika dodatak s PDV
    l:UK_TMP=0    
    !-- 25%
    if mSTA:IZNOSPPP<>0 and mSTA:VPIZNOS<>0 and mSTA:TARIFA = 6
        l:StopaPDVa=25
        l:Stopa2='25%'       
        l:UK_TMP = mSTA:MPIZNOS + l:Uk_Razlika         
        l:Osnovica2 += ROUND(l:UK_TMP / 1.25,.01)
        l:Iznospp2 += l:UK_TMP - ROUND(l:UK_TMP / 1.25,.01)
        
    end
    !-- 5%
    if mSTA:IZNOSPPP<>0 and mSTA:VPIZNOS<>0 and mSTA:TARIFA = 7
        l:StopaPDVa=5
        l:Stopa1='5%'       
        l:UK_TMP = mSTA:MPIZNOS + l:Uk_Razlika         
        l:Osnovica1 += ROUND(l:UK_TMP / 1.05,.01)
        l:Iznospp1 += l:UK_TMP - ROUND(l:UK_TMP / 1.05,.01)
        
    end
    
    

   

PDFReporter.Setup PROCEDURE

  CODE
  PARENT.Setup
  SELF.SetFileName(l:PdfFileName)
  SELF.SetDocumentInfo('CW Report','fpomagala_ip','Rac_20230101','Rac_20230101','','')
  SELF.SetScanCopyMode(False)

