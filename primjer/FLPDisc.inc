        OMIT('_EndOfInclude_',_IFDef_FLPDisc_)
_IFDef_FLPDisc_                         EQUATE(1)


DiscountWSType:Discount                 EQUATE('Discount')
DiscountWSType:DiscountPercent          EQUATE('DiscountPercent')
DiscountWSType:FixedPrice               EQUATE('FixedPrice')

DiscountWSObjectType:Category           EQUATE('Category')
DiscountWSObjectType:Product            EQUATE('Product')

qPartneri           QUEUE,TYPE
WebID                                              LONG
PARTNER                                         LONG
CustomerID                                      LONG
PROIZVODJAC                                     LONG
SIFRA                                           STRING(20)
ROBA                                            LONG
GRUPA                                           STRING(10)
CustGroupId                                     STRING(10)
DATUMSTART                                      DATE
DATUMEND                DATE
POSTOTAK                                        real!DECIMAL(9,4)
CIJENA          real!DECIMAL(11,2)
WandID          LONG
RecordRequest           LONG
NacinObracunaCijenaNaWebu  LONG

            end

RabatiType          GROUP,TYPE
WebId                   LONG
PARTNER                                     LONG
CustomerId                                  LONG
PROIZVODJAC                                 LONG
SIFRA                                       string(200)
ROBA                                        LONG
GRUPA                                       string(200)
CustGroupId LONG ! veza na customer group
DATUMSTART                                  string(30)
DATUMEND                                    string(30)
POSTOTAK                                   real! DECIMAL(9,2)
CIJENA                                     real! DECIMAL(11,2)
WandID                  LONG
DATUMVRIJEMEKREIRANJA   STRING(30)


            end

PartnerType        GROUP,TYPE
WebId                   LONG
PARTNER                 LONG
CUSTOMERWEBID              LONG
CentralaCUSTOMERWEBID              LONG
BEZAKCIJE               LONG
GRUPA                   string(80)
RABAT                   real!DECIMAL(9,2) 
NacinObracunaCijenaNaWebu  LONG
                    end

RegistriType        GROUP,TYPE
WebId                   LONG
BAZA                    STRING(80)
SIFRA                   STRING(80)
CUSTROLA_WebID             LONG
WandID              LONG
                    end


WandRobaType        GROUP,TYPE
WebId                   LONG
roba                    LONG
SIFRA                   cSTRING(80)
ProductID               LONG
ProizvodjacID           LONG
VPCijena                real!decimal(11,2)
MPCijena                real!decimal(11,2)

                    end


!
!--------------------------------------------------------------------------------
FLPDisc    CLASS,TYPE,MODULE('FLPDisc.CLW'),LINK('FLPDisc.CLW',_ABCLinkMode_),DLL(_ABCDllMode_)

!Properties
!----------
InDebug         BYTE

MojOLE          LONG
Korisnicko_ime  STRING(100)
Lozinka         STRING(100)
WebServis_URL   STRING(255)

WebServis_Inicijaliziran        LONG
!UD                  &UltimateDebug

!Methods
!-------
Init                    PROCEDURE()
Kill                    PROCEDURE()
HelloWorld              PROCEDURE()
RaiseError              PROCEDURE(STRING pErrorMsg)
Construct               PROCEDURE()
Destruct        PROCEDURE()

Test_COM        PROCEDURE(STRING TestPoruka),STRING

Set_URL_Username_Password     PROCEDURE(STRING pURL,STRING pUser, STRING pPass),byte
Vrati_GlobalRequest     PROCEDURE(LONG pGlobalRequest),string

!Rabati_BrisiRabatnu    PROCEDURE(),long        

!----- Rabati  -----
Rabat_AddToList    PROCEDURE(RabatiType rabati),long        
!RabatiSend      PROCEDURE(),string        
Rabati_ClearList        PROCEDURE(),string

!----- Partneri -----
Partner_AddToList  PROCEDURE(PartnerType p),long        
!PartnerSend      PROCEDURE(),string        
Partner_ClearList        PROCEDURE(),string

!----- WandRobe -----
WandRoba_AddToList  PROCEDURE(WandRobaType wr),long             
!WandRobaSend      PROCEDURE(),string        
WandRoba_ClearList        PROCEDURE(),string

Rabati_AddAll    PROCEDURE(),string

RegistriUpdejt  PROCEDURE(LONG pGlobalRequest,RegistriType reg),long             


Vrati_pDiscountWSObjectType  PROCEDURE(LONG pRobaID, STRING pSifraGrupe),STRING
Vrati_DiscountWSType    PROCEDURE(REAL postotak, REAL cijena),STRING
Vrati_DiscountWSType_Value      PROCEDURE(REAL postotak, REAL cijena),REAL
!Vrati_AkcijaH_Id PROCEDURE( LONG pAkcijaL_ID),long


CustomerDefaultDiscount   PROCEDURE(LONG pGlobalRequest,LONG pCustomerDefaultDiscount_Id, LONG pCustomerWebID, STRING DiscountWSType, REAL pValue),long        
DiscOnCustGroup           PROCEDURE(LONG pGlobalRequest,LONG pDiscOnCustGroup_Id, DATE pDatumOd, DATE pDatumDo, LONG pCustGroupId, LONG pDefId, STRING DiscountWSType, STRING pDiscountWSObjectType, REAL pValue),long        
DiscForCatOnCust          PROCEDURE(LONG pGlobalRequest,LONG pDiscForCatOnCust_Id, DATE pDatumOd, DATE pDatumDo, LONG pCategory_Id, LONG pCustomer_Id, STRING DiscountWSType, REAL pValue),long        
DiscOrPriceOnCust       PROCEDURE(LONG pGlobalRequest,LONG pDiscOrPriceOnCust_Id, DATE pDatumOd, DATE pDatumDo, LONG pCustomer_Id,LONG pProduct_Id, STRING DiscountWSType, REAL pValue),long        
ActionHead      PROCEDURE(LONG pGlobalRequest,LONG pActionHead_Id, DATE pDatumOd, DATE pDatumDo, LONG pProduct_Id, STRING DiscountWSType, STRING pDiscountWSObjectType, REAL pValue),long            
!ActionStavke    PROCEDURE(LONG pGlobalRequest,LONG pActionStavke_Id, LONG pActionHead_Id, LONG pCustomer_Id, LONG pProduct_Id, STRING DiscountWSType, REAL pValue),long        

Test2           PROCEDURE()

Verzija         PROCEDURE(),STRING

Rabati          PROCEDURE(),LONG

decimal_to_ole procedure(real pIznos),string

SciWS_FullRefresh   procedure(),BYTE

                                        END
        _EndOfInclude_
