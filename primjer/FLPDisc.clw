                                        MEMBER()
        omit('***',_c55_)
_ABCDllMode_        EQUATE(0)
_ABCLinkMode_       EQUATE(1)
        ***
!
!--------------------------
!ClarionLive! Basic Class Template
!--------------------------

    INCLUDE('EQUATES.CLW')
    !INCLUDE('UltimateDebug.INC'),once
    INCLUDE('StringTheory.INC'),once
        INCLUDE('FLPDisc.INC'),ONCE






                                        MAP
                                        END


!-----------------------------------
FLPDisc.Init       PROCEDURE()
!-----------------------------------

    CODE
        SELF.InDebug = FALSE
        SELF.MojOLE = CREATE(0, CREATE:OLE)
        !SELF.MojOLE{PROP:Compatibility} = 20h
        !SELF.MojOLE{PROP:TRN}           = 1 
        SELF.MojOLE{PROP:Create} = 'FLPDISC.FDiscount'
        !MESSAGE('CREATE '&SELF.MojOLE &'  '&ERROR() )
        RETURN

!-----------------------------------            
FLPDisc.Verzija                         PROCEDURE()!,STRING
!-----------------------------------            
    code
        RETURN(SELF.MojOLE{'Verzija()'})
        
        
!-----------------------------------
!   Testiranje/Setiranje
!-----------------------------------
FLPDisc.Test_COM                        PROCEDURE(STRING TestPoruka)!,STRING
!-----------------------------------
l:Vraceno                                   STRING(50)
    code
        l:Vraceno=SELF.MojOLE{'TestCOM("' &CLIP(TestPoruka) &'")'}
        return(l:Vraceno)

        
!-----------------------------------                    
FLPDisc.Rabat_AddToList               PROCEDURE(RabatiType rabati)!,long        
!-----------------------------------
l:Vraceno                                   STRING(50)
l:GlobalRequest                             STRING(20)
    code
        
!        IF pGlobalRequest<> 1 ! ako nije InsertRecord
!           SELF.MojOLE{'r_PARTNER'} = rabati.PARTNER     
!        END
        SELF.MojOLE{'r_PARTNER'} = rabati.PARTNER 
        SELF.MojOLE{'r_CustomerId'}= rabati.CustomerId        
        SELF.MojOLE{'r_PROIZVODJAC'}= rabati.PROIZVODJAC        
        SELF.MojOLE{'r_SIFRA'}= '"' &clip(rabati.SIFRA) &'"'        
        SELF.MojOLE{'r_ROBA'}= rabati.ROBA        
        SELF.MojOLE{'r_GRUPA'}='"' &clip(rabati.GRUPA)  &'"'      
        SELF.MojOLE{'r_CustGroupId'}= rabati.CustomerId
        IF rabati.DATUMSTART=0
            SELF.MojOLE{'r_DATUMSTART'}= ''
        else        
            SELF.MojOLE{'r_DATUMSTART'}= clip(rabati.DATUMSTART)
        END                
        IF rabati.DATUMEND=0
            SELF.MojOLE{'r_DATUMEND'}= ''        
        ELSE        
            SELF.MojOLE{'r_DATUMEND'}= clip(rabati.DATUMEND)
        END
            SELF.MojOLE{'r_DATUMKREIRANJA'}= clip(rabati.DATUMVRIJEMEKREIRANJA)
        SELF.MojOLE{'r_POSTOTAK'}= self.decimal_to_ole( rabati.POSTOTAK )
        SELF.MojOLE{'r_CIJENA'}= self.decimal_to_ole( rabati.CIJENA )
        SELF.MojOLE{'r_WandID'}= rabati.WandID        
        SELF.MojOLE{'r_WebId'}= rabati.WebId        
        !MESSAGE('DatumOd='& FORMAT(pDatumOd,@D06.) &' DatumDo:'&FORMAT(pDatumDo,@D06.))
        
        ! l:GlobalRequest = CLIP(SELF.Vrati_GlobalRequest(pGlobalRequest))                
        l:Vraceno=SELF.MojOLE{'Rabat_AddToList()'}
        
        return(l:Vraceno)        
        
!!-----------------------------------                    
!FLPDisc.RabatiSend    PROCEDURE()!,string                
!!-----------------------------------
!l:Vraceno                                   STRING(5000)
!l:GlobalRequest                             STRING(20)
!    code                  !RabatiSend  
!    l:Vraceno=SELF.MojOLE{'RabatiSend()'}
!        
!        return(l:Vraceno)        
        
!-----------------------------------                    
FLPDisc.Rabati_ClearList    PROCEDURE()!,string                
!-----------------------------------
l:Vraceno                                   STRING(5000)
l:GlobalRequest                             STRING(20)
    code            
    l:Vraceno=SELF.MojOLE{'Rabati_ClearList()'}
        
        return(l:Vraceno)        
        
        
!-----------------------------------                            
FLPDisc.Partner_AddToList               PROCEDURE(PartnerType p)!,long             
!-----------------------------------
l:Vraceno                                   STRING(50)
l:GlobalRequest                             STRING(20)
    code
        
!        IF pGlobalRequest<> 1 ! ako nije InsertRecord
!          SELF.MojOLE{'p_WebId'}= p.WebId   
!        END
        SELF.MojOLE{'p_PARTNER'} = p.PARTNER 
        SELF.MojOLE{'p_CustomerId'}= p.CUSTOMERWEBID
        SELF.MojOLE{'p_CentralaCustomerId'}= p.CentralaCUSTOMERWEBID
        SELF.MojOLE{'p_BEZAKCIJE'}= p.BEZAKCIJE       
        SELF.MojOLE{'p_GRUPA'}='"' & clip(p.GRUPA) &'"'
        SELF.MojOLE{'p_RABAT'}= self.decimal_to_ole(p.RABAT)
        SELF.MojOLE{'p_NacinObracunaCijenaNaWebu'}= p.NacinObracunaCijenaNaWebu
      !  MESSAGE('p.PARTNER='&p.PARTNER &' p.NacinObracunaCijenaNaWebu='&p.NacinObracunaCijenaNaWebu)
        
        l:Vraceno=SELF.MojOLE{'Partner_AddToList()'}        
        return(l:Vraceno)   

!!-----------------------------------                    
!FLPDisc.PartnerSend    PROCEDURE()!,string                
!!-----------------------------------
!l:Vraceno                                   STRING(5000)
!l:GlobalRequest                             STRING(20)
!    code
!    l:Vraceno=SELF.MojOLE{'PartneriSend()'}
!        
!        return(l:Vraceno)        
!        
!-----------------------------------                    
FLPDisc.Partner_ClearList    PROCEDURE()!,string                
!-----------------------------------
l:Vraceno                                   STRING(5000)
l:GlobalRequest                             STRING(20)
    code
    l:Vraceno=SELF.MojOLE{'PartneriClear()'}
        
        return(l:Vraceno)     
        
        
!-----------------------------------                            
FLPDisc.RegistriUpdejt               PROCEDURE(LONG pGlobalRequest,RegistriType reg)!,long             
!-----------------------------------
l:Vraceno                                   STRING(50)
l:GlobalRequest                             STRING(20)
    code
        
        IF pGlobalRequest<> 1 ! ako nije InsertRecord
           SELF.MojOLE{'reg_WebId'}= reg.WebId 
        END
        SELF.MojOLE{'reg_BAZA'} = '"' &clip(reg.BAZA ) &'"'
        SELF.MojOLE{'reg_SIFRA'}= '"' &clip(reg.SIFRA) &'"'
        SELF.MojOLE{'reg_CUSTROLA_ID'}= reg.CUSTROLA_WebID
        SELF.MojOLE{'reg_WandID'}=reg.WandID 
        l:GlobalRequest = CLIP(SELF.Vrati_GlobalRequest(pGlobalRequest))                
        l:Vraceno=SELF.MojOLE{'Registri_Updejt("' &CLIP(l:GlobalRequest) &'")'}        
        return(l:Vraceno)   
        

!-----------------------------------                            
FLPDisc.WandRoba_AddToList               PROCEDURE(WandRobaType wr)!,long             
!-----------------------------------
l:Vraceno                                   STRING(50)
l:GlobalRequest                                 STRING(20)
l:VPcijena                                     real! StringTheory      
l:MPcijena                                      StringTheory      
    code
        
!        IF pGlobalRequest<> 1 ! ako nije InsertRecord
!           SELF.MojOLE{'wnd_WebId'}= wr.WebId 
!        END
        
        SELF.MojOLE{'wnd_ROBA'} = wr.roba       
        SELF.MojOLE{'wnd_SIFRA'}= '"' &clip(wr.SIFRA) &'"'
        SELF.MojOLE{'wnd_ProductID'}= wr.ProductID
        
        SELF.MojOLE{'wnd_VPCijena'}=self.decimal_to_ole( wr.VPCijena )
        
        SELF.MojOLE{'wnd_MPCijena'}= self.decimal_to_ole( wr.MPCijena )
        
        SELF.MojOLE{'wnd_PROIZVODJAC'}=  wr.ProizvodjacID 
!        if wr.roba=7461
!            message('fwr.SIFRA='&wr.SIFRA &' wr.VPCijena ' &wr.VPCijena)
!        END
        !l:GlobalRequest = CLIP(SELF.Vrati_GlobalRequest(pGlobalRequest))                
        l:Vraceno=SELF.MojOLE{'WandRoba_AddToList()'}        
        return(l:Vraceno)   
        
!!-----------------------------------                    
!FLPDisc.WandRobaSend    PROCEDURE()!,string                
!!-----------------------------------
!l:Vraceno                                   STRING(5000)
!l:GlobalRequest                             STRING(20)
!    code
!    l:Vraceno=SELF.MojOLE{'WandRobeSend()'}
!        
!        return(l:Vraceno)        
        
!-----------------------------------                    
FLPDisc.WandRoba_ClearList    PROCEDURE()!,string                
!-----------------------------------
l:Vraceno                                   STRING(5000)
l:GlobalRequest                             STRING(20)
    code
    l:Vraceno=SELF.MojOLE{'WandRobeClear()'}
        
        return(l:Vraceno)     

!-----------------------------------                    
FLPDisc.Rabati_AddAll    PROCEDURE()!,string                
!-----------------------------------
l:Vraceno                                   STRING(5000)
l:GlobalRequest                             STRING(20)
    code
    l:Vraceno=SELF.MojOLE{'Rabati_AddAll()'}
        
        return(l:Vraceno)        
        
        
        
!!-----------------------------------                    
!FLPDisc.Rabati_BrisiRabatnu    PROCEDURE()!,long                
!l:Vraceno                                   STRING(5000)
!l:GlobalRequest                             STRING(20)
!    code
!    l:Vraceno=SELF.MojOLE{'Rabati_BrisiRabatnu()'}
!        
!        return(l:Vraceno)     
        
!-----------------------------------            
FLPDisc.Vrati_DiscountWSType_Value    PROCEDURE(REAL postotak, REAL cijena)!,REAL
!-----------------------------------            
    code
        IF postotak<>0 AND cijena=0
            RETURN(postotak)
        ELSIF  postotak=0 AND cijena<>0
            RETURN(cijena)
        ELSIF postotak<>0 AND cijena<>0
            RETURN(cijena*postotak/100)
        ELSE !ako nije ništa onda je postotak od 0 posto
            RETURN(0)
        END
        RETURN(0)
        
!-----------------------------------            
FLPDisc.Vrati_DiscountWSType            PROCEDURE(REAL postotak, REAL cijena)!,STRING
!-----------------------------------            
    code
        
        IF postotak<>0 AND cijena=0
            RETURN(DiscountWSType:DiscountPercent)
        ELSIF  postotak=0 AND cijena<>0
            RETURN(DiscountWSType:FixedPrice)
        ELSIF postotak<>0 AND cijena<>0
            RETURN(DiscountWSType:FixedPrice)
        ELSE !ako nije ništa onda je postotak od 0 posto
            RETURN(DiscountWSType:DiscountPercent)
        END
        RETURN(DiscountWSType:DiscountPercent)
        
!-----------------------------------            
FLPDisc.Vrati_pDiscountWSObjectType     PROCEDURE(LONG pRobaID, STRING pSifraGrupe)!,STRING            
!-----------------------------------            
    code
        
        IF (pRobaID<>0 AND pSifraGrupe<>'')  
            MESSAGE('FLPDisc.Vrati_pDiscountWSObjectType: Oba su razlièita od nule. Nemoguèa situacija!','GREŠKA!!!',ICON:Exclamation)
            RETURN('')
        END
        IF (pRobaID=0 AND pSifraGrupe='')  
            MESSAGE('FLPDisc.Vrati_pDiscountWSObjectType: Oba su  nula. Nemoguèa situacija!','GREŠKA!!!',ICON:Exclamation)
            RETURN('')
        END
        IF pRobaID<>0
            RETURN( DiscountWSObjectType:Product)
        END
        IF pSifraGrupe<>''
            RETURN(DiscountWSObjectType:Category)
        END
        RETURN('')
        
        
!!-----------------------------------            
!FLPDisc.Vrati_AkcijaH_Id                PROCEDURE( LONG pAkcijaL_ID)!,long            
!!-----------------------------------            
!    code
!        
!        RETURN(SELF.MojOLE{'vrati_actionH_Id(' &pAkcijaL_ID   &')'})
!        
!            
!        
!-----------------------------------            
FLPDisc.Vrati_GlobalRequest           PROCEDURE(LONG pGlobalRequest)!,string
!-----------------------------------            
l:GlobalRequest                                   STRING(20)
    CODE
        IF pGlobalRequest = 1
            l:GlobalRequest='InsertRecord'
        ELSIF pGlobalRequest = 2
            l:GlobalRequest='ChangeRecord'
        ELSIF pGlobalRequest = 3
            l:GlobalRequest='DeleteRecord'
        ELSE
            MESSAGE('CustomerDefaultDiscount: pGlobalRequest Nepozanata Vrijednost pGlobalRequest='&pGlobalRequest)
            RETURN (-3)
        END
       RETURN(l:GlobalRequest) 
        
!-----------------------------------            
FLPDisc.Set_URL_Username_Password           PROCEDURE(STRING pURL,STRING pUser, STRING pPass)!,byte
!-----------------------------------            
l:Vraceno                                   STRING(500)
    CODE
        
        l:Vraceno=SELF.MojOLE{'Set_URL("' &CLIP(pURL)  &'")'}
       ! MESSAGE('1l:vraceno='&clip(l:Vraceno))
        IF l:Vraceno='' THEN RETURN(0).       
        
        l:Vraceno=SELF.MojOLE{'Set_UserName("' &CLIP(pUser)  &'")'}
       ! MESSAGE('2l:vraceno='&clip(l:Vraceno))
        IF l:Vraceno='' THEN RETURN(0).
        
        l:Vraceno=SELF.MojOLE{'Set_Pass("' &CLIP(pPass)  &'")'}
       ! MESSAGE('3l:vraceno='&clip(l:Vraceno))
        IF l:Vraceno='' THEN RETURN(0).
        RETURN(1)

        
        
!!-----------------------------------                    
!FLPDisc.ActionStavke                      PROCEDURE(LONG pGlobalRequest,LONG pActionStavke_Id, LONG pActionHead_Id, LONG pCustomer_Id, LONG pProduct_Id, STRING DiscountWSType, REAL pValue)!,long        
!!-----------------------------------
!l:Vraceno                                   STRING(50)
!l:GlobalRequest                             STRING(20)
!    code
!        
!        IF pGlobalRequest<> 1 ! ako nije InsertRecord
!            SELF.MojOLE{'c_AkcijaLModel_Id'}=CLIP(pActionStavke_Id)    
!        END
!        
!        SELF.MojOLE{'c_Customer_ID'}= pCustomer_Id
!        SELF.MojOLE{'c_DefId'}= pProduct_Id 
!        SELF.MojOLE{'c_VrstaDiskaunta'} =clip(DiscountWSType)        
!        SELF.MojOLE{'c_pValue'}= pValue
!        SELF.MojOLE{'c_AkcijaHModel_Id'}= pActionHead_Id
!        
!        l:GlobalRequest = CLIP(SELF.Vrati_GlobalRequest(pGlobalRequest))                
!        l:Vraceno=SELF.MojOLE{'ActionOnProduct("' &CLIP(l:GlobalRequest) &'")'}
!        
!        return(l:Vraceno)
!        
        
        
!-----------------------------------                    
FLPDisc.ActionHead               PROCEDURE(LONG pGlobalRequest,LONG pActionHead_Id, DATE pDatumOd, DATE pDatumDo,  LONG pProduct_Id, STRING DiscountWSType, STRING pDiscountWSObjectType, REAL pValue)!,long        
!-----------------------------------
l:Vraceno                                   STRING(50)
l:GlobalRequest                             STRING(20)
    code
        
        IF pGlobalRequest<> 1 ! ako nije InsertRecord
           SELF.MojOLE{'c_AkcijaHModel_Id'}=CLIP(pActionHead_Id)    
        END
        
        IF pDatumOd=0
            SELF.MojOLE{'c_DateFrom'}= ''
        else        
            SELF.MojOLE{'c_DateFrom'}= FORMAT(pDatumOd,@D06.)
        END        
        
        IF pDatumDo=0
            SELF.MojOLE{'c_DateTo'}= ''        
        ELSE        
            SELF.MojOLE{'c_DateTo'}= FORMAT(pDatumDo,@D06.)
        END
      !  MESSAGE('FLPDisc.ActionHead= '&FORMAT(pDatumOd,@D06.) &'  ' &FORMAT(pDatumDo,@D06.) )
        SELF.MojOLE{'c_Customer_ID'}= 'null'        
        SELF.MojOLE{'c_DefId'}= pProduct_Id 
        SELF.MojOLE{'c_VrstaDiskaunta'} =clip(DiscountWSType)        
        SELF.MojOLE{'c_pValue'}= pValue  
        SELF.MojOLE{'c_VrstaDiskaunta_Object'}=CLIP(pDiscountWSObjectType)
        !MESSAGE('DatumOd='& FORMAT(pDatumOd,@D06.) &' DatumDo:'&FORMAT(pDatumDo,@D06.))
        
        l:GlobalRequest = CLIP(SELF.Vrati_GlobalRequest(pGlobalRequest))                
        l:Vraceno=SELF.MojOLE{'ActionHead("' &CLIP(l:GlobalRequest) &'")'}
        
        return(l:Vraceno)
        
        

!-----------------------------------                    
FLPDisc.DiscOrPriceOnCust                PROCEDURE(LONG pGlobalRequest,LONG pDiscOrPriceOnCust_Id, DATE pDatumOd, DATE pDatumDo, LONG pCustomer_Id,LONG pProduct_Id, STRING DiscountWSType, REAL pValue)!,long        
!-----------------------------------
l:Vraceno                                   STRING(50)
l:GlobalRequest                             STRING(20)
    code
        
        IF pGlobalRequest<> 1 ! ako nije InsertRecord
            SELF.MojOLE{'c_DiscOrPriceOnCust_Id'}=CLIP(pDiscOrPriceOnCust_Id) 
           ! MESSAGE('c_DiscOrPriceOnCust_Id= '&CLIP(pDiscOrPriceOnCust_Id))
        END
        !---- ovo triba razradit
        IF pDatumOd=0
            SELF.MojOLE{'c_DateFrom'}= ''
        else        
            SELF.MojOLE{'c_DateFrom'}= FORMAT(pDatumOd,@D06.)
        END        
        
        IF pDatumDo=0
            SELF.MojOLE{'c_DateTo'}= ''        
        ELSE        
            SELF.MojOLE{'c_DateTo'}= FORMAT(pDatumDo,@D06.)
        END      
        !----
        SELF.MojOLE{'c_DefId'}= CLIP(pProduct_Id)
        SELF.MojOLE{'c_Customer_ID'}= CLIP(pCustomer_Id)
        SELF.MojOLE{'c_VrstaDiskaunta'}= CLIP(DiscountWSType)
        SELF.MojOLE{'c_pValue'} = CLIP(pValue)
        !MESSAGE(' pCustomer_Id='&pCustomer_Id)
        l:GlobalRequest = CLIP(SELF.Vrati_GlobalRequest(pGlobalRequest))                
        l:Vraceno=SELF.MojOLE{'DiscOrPriceOnCust("' &CLIP(l:GlobalRequest) &'")'}
        
        return(l:Vraceno)
        
        
        
        
!-----------------------------------                    
FLPDisc.DiscForCatOnCust                 PROCEDURE(LONG pGlobalRequest,LONG pDiscForCatOnCust_Id, DATE pDatumOd, DATE pDatumDo, LONG pCategory_Id, LONG pCustomer_Id, STRING DiscountWSType, REAL pValue)!,long        
!-----------------------------------
l:Vraceno                                   STRING(50)
l:GlobalRequest                             STRING(20)
    code
        
        IF pGlobalRequest<> 1 ! ako nije InsertRecord
            SELF.MojOLE{'c_DiscForCatOnCust_Id'}=CLIP(pDiscForCatOnCust_Id)    
        END
        IF pDatumOd=0
            SELF.MojOLE{'c_DateFrom'}= ''
        else        
            SELF.MojOLE{'c_DateFrom'}= FORMAT(pDatumOd,@D06.)
        END        
        
        IF pDatumDo=0
            SELF.MojOLE{'c_DateTo'}= ''        
        ELSE        
            SELF.MojOLE{'c_DateTo'}= FORMAT(pDatumDo,@D06.)
        END
        SELF.MojOLE{'c_Category_ID'}=CLIP(pCategory_Id)
        SELF.MojOLE{'c_Customer_ID'}=CLIP(pCustomer_Id)
        SELF.MojOLE{'c_VrstaDiskaunta'}=CLIP(DiscountWSType)
        SELF.MojOLE{'c_pValue'}=CLIP(pValue)
        
        l:GlobalRequest = CLIP(SELF.Vrati_GlobalRequest(pGlobalRequest))                
        l:Vraceno=SELF.MojOLE{'DiscForCatOnCust("' &CLIP(l:GlobalRequest) &'")'}
       ! MESSAGE('DatumOd='&FORMAT(pDatumOd,@D06.) &' DatumDo='&FORMAT(pDatumDo,@D06.) &' pCategory_Id='&pCategory_Id &'  pCustomer_Id='&pCustomer_Id)
        return(l:Vraceno)

        
        
        
!-----------------------------------                    
FLPDisc.DiscOnCustGroup         PROCEDURE(LONG pGlobalRequest,LONG pDiscOnCustGroup_Id, DATE pDatumOd, DATE pDatumDo, LONG pCustGroupId, LONG pDefId, STRING DiscountWSType, STRING pDiscountWSObjectType, REAL pValue)!,long        
!-----------------------------------
l:Vraceno                                   STRING(50)
l:GlobalRequest                             STRING(20)
    code
        
        IF pGlobalRequest<> 1 ! ako nije InsertRecord
            SELF.MojOLE{'c_DiscOnCustGroup_Id'}=CLIP(pDiscOnCustGroup_Id)    
        END
        IF pDatumOd=0
            SELF.MojOLE{'c_DateFrom'}= ''
        else        
            SELF.MojOLE{'c_DateFrom'}= FORMAT(pDatumOd,@D06.)
        END        
        
        IF pDatumDo=0
            SELF.MojOLE{'c_DateTo'}= ''        
        ELSE        
            SELF.MojOLE{'c_DateTo'}= FORMAT(pDatumDo,@D06.)
        END
        SELF.MojOLE{'c_CustGroup_Id'}=CLIP(pCustGroupId)
        SELF.MojOLE{'c_DefId'}=CLIP(pDefId)        
        SELF.MojOLE{'c_VrstaDiskaunta_Object'}=CLIP(pDiscountWSObjectType)
        SELF.MojOLE{'c_VrstaDiskaunta'}=CLIP(DiscountWSType)
        SELF.MojOLE{'c_pValue'}=CLIP(pValue)
        !MESSAGE()
        l:GlobalRequest = CLIP(SELF.Vrati_GlobalRequest(pGlobalRequest))                
        l:Vraceno=SELF.MojOLE{'DiscOnCustGroup("' &CLIP(l:GlobalRequest) &'")'}
        
        return(l:Vraceno)

        
        
        
        
!-----------------------------------                    
FLPDisc.CustomerDefaultDiscount      PROCEDURE(LONG pGlobalRequest,LONG pCustomerDefaultDiscount_Id, LONG pCustomerWebID, STRING DiscountWSType, REAL pValue)!,long        
!-----------------------------------
l:Vraceno                                   STRING(50)
l:GlobalRequest                             STRING(20)
    code
        
        IF pGlobalRequest<> 1
            SELF.MojOLE{'c_CustomerDefaultDiscount_Id'}=CLIP(pCustomerDefaultDiscount_Id)    
        END
        
        SELF.MojOLE{'c_Customer_ID'}=CLIP(pCustomerWebID)
        SELF.MojOLE{'c_VrstaDiskaunta'}=CLIP(DiscountWSType)
        SELF.MojOLE{'c_pValue'}=CLIP(pValue)
        !  MESSAGE('11')
        l:GlobalRequest = CLIP(SELF.Vrati_GlobalRequest(pGlobalRequest))
        MESSAGE('FLPDisc.CustomerDefaultDiscount: l:GlobalRequest = '&l:GlobalRequest)
        !l:Vraceno=SELF.MojOLE{'CustomerDefaultDiscount("' & &'")'}
        l:Vraceno=SELF.MojOLE{'CustomerDefaultDiscount("' &CLIP(l:GlobalRequest) &'")'}
        
        return(l:Vraceno)

        
!-----------------------------------
FLPDisc.Rabati          PROCEDURE()!,LONG
!-----------------------------------
l:Vraceno                   STRING(50)
l:GlobalRequest                             STRING(20)
    CODE
        
            l:Vraceno=SELF.MojOLE{'RabatiList_UpdejtTEST()'}
            return(l:Vraceno)
        
!-----------------------------------
FLPDisc.Kill       PROCEDURE()
!-----------------------------------

        CODE

                RETURN

!-----------------------------------------
FLPDisc.HelloWorld PROCEDURE()
!-----------------------------------------

        CODE

                BEEP(BEEP:SystemAsterisk)
                MESSAGE('Hello World From Clarion Live', 'Hello', ICON:ASTERISK)

                SELF.RaiseError('Display some kind of Error (only in Debug Mode)')

                RETURN

!---------------------------------------------------------
FLPDisc.RaiseError PROCEDURE(STRING pErrorMsg)
!---------------------------------------------------------

        CODE

                IF SELF.InDebug = TRUE
                        BEEP(BEEP:SystemExclamation)
                        MESSAGE(CLIP(pErrorMsg), 'ClarionLive Error', ICON:EXCLAMATION)
                END

                RETURN

!----------------------------------------
FLPDisc.decimal_to_ole                  procedure(real pIznos)!,string      
!----------------------------------------
l:VPcijena                                  StringTheory
    CODE
        
    l:VPcijena.SetValue(pIznos)        
    l:VPcijena.Replace('.',',')        
    return(clip(l:VPcijena.GetValue()))
        
        

!----------------------------------------
FLPDisc.Construct  PROCEDURE()
!----------------------------------------
        CODE

                RETURN



!---------------------------------------
FLPDisc.Destruct   PROCEDURE()
!---------------------------------------
        CODE

                RETURN
!---------------------------------------        
FLPDisc.Test2                      PROCEDURE()
!---------------------------------------
l:Vraceno                                   STRING(22)    
l:GlobalRequest                         STRING(20)
    code
        
        l:GlobalRequest = CLIP(SELF.Vrati_GlobalRequest(1))                
        l:Vraceno=SELF.MojOLE{'Test_DiscOnCustGroup()'}
        
      ! l:Vraceno=SELF.MojOLE{'ActionHead2'}
        MESSAGE('Test2 l:Vraceno='&l:Vraceno)


!---------------------------------------
FLPDisc.SciWS_FullRefresh          procedure()!,BYTE    
!---------------------------------------
    code
       ! MESSAGE('SciWS_FullRefresh: START')
            return(SELF.MojOLE{'SciWS_FullRefresh()'})
