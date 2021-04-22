#include "rwmake.ch"
#include "topconn.ch"  
#INCLUDE "DBTREE.CH"
#INCLUDE "TBICONN.CH"     
#INCLUDE "PROTHEUS.CH"
#Include "FWMVCDEF.ch"

/* Author: Cleyton Victor 03/02/2021 */

User Function TLPrice()

Private aFixe      := {}
Private aCores     := {}    
PRIVATE cCadastro := "Notas Fiscais"
PRIVATE aRotina := Menu()
Private Titulo   := "NF Entradas"                    
Private oGet1,oGet2 
Private cPerg := "XSEPA"

aArea := GetArea()                    

PutSx1(cPerg ,"01","Período De" ,"Período De","Período De","mv_ch1","D"  ,8       ,0       ,0      ,"G" ,""    ,"" ,""     ,"","MV_PAR01",""     ,"","",""    ,""           ,"","",""         ,"","",""          ,"","","","","")
PutSx1(cPerg ,"02","Período Até" ,"Período Até","Período Até","mv_ch2","D"  ,8       ,0       ,0      ,"G" ,""    ,"" ,""     ,"","MV_PAR02",""     ,"","",""    ,""           ,"","",""         ,"","",""          ,"","","","","")

Pergunte(cPerg,.T.)

CriaTRB()

AlimentaTRB()

aCores := {	{ "Empty(TRB->CLAS)",'BR_VERMELHO'},; //A CLASSIFICAR
		 	{ "TRB->CLAS = 'A'" ,'BR_VERDE' }}    //CLASSIFICADO
			
			
dbSelectArea("TRB")
dbSetOrder(1)

aFixe := {	{"Nota Fiscal"		,{|| TRB->DOC},"",09,0,"@!"},;	
			{"Serie"			,{|| TRB->SR},"",03,0,"@!"},;
			{"Fornecedor"		,{|| TRB->RAZAO},"",30,0,"@!"},;	
			{"Produto"   		,{|| TRB->COD},"",10,0,"@!"},;
			{"Descrição"		,{|| TRB->DESCR},"",70,0,"@!"},;
			{"Custo R$"			,{|| TRB->CUSTO},"",14,2,"@E 999,999,999.99"},;
			{"Atual R$"			,{|| TRB->ATUAL},"",14,2,"@E 999,999,999.99"},;
			{"Sugestão R$"		,{|| TRB->SGR}  ,"",14,2,"@E 999,999,999.99"}} 
			
//{"Filial"			,{|| TRB->FIL},"",16,0,"@!"},;
SetKey( VK_F5, { || U_xRefresh() } )

oGet1 := mBrowse( 6, 1,22,75,"TRB",aFixe,,,,,aCores)     

//DbCloseArea("TRB")
RestArea(aArea) // Restaura a area atual                                                                 

Return(.T.)


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ºDescrição: Cria Menu no Browse                                         º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
                                                           
Static Function Menu()

Private aRotina := {{ "Atualizar"    ,"U_xRefresh()"	,0,3,0 ,NIL},;
					{ "Legenda"      ,"U_xLegend()"		,0,1,0 ,.F.},;
					{ "Visualizar" 	 ,"U_xVisual(TRB->DOC,TRB->SR,TRB->FORN,TRB->LJ)",0,2,0 ,NIL},;
					{ "Forma Preço"  ,"U_xPrice(TRB->COD,TRB->CLAS)",0,3,0 ,NIL}}
					
Return(aRotina)        

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ºDescrição    Cria arquivo de trabalho (TRB)                            º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CriaTRB()

Local aCampos := {}

aAdd(aCampos,{"EMP"		,"C",2	,0})		// Legenda
aAdd(aCampos,{"FIL"		,"C",20	,0})		// Filial
aAdd(aCampos,{"DOC"		,"C",9	,0})		// Nota Fiscal
aAdd(aCampos,{"SR"		,"C",3	,0})		// Serie
aAdd(aCampos,{"COD"		,"C",10	,0})		// Codigo
aAdd(aCampos,{"DESCR"	,"C",70	,0})		// Descricao
aAdd(aCampos,{"ATUAL"  	,"N",14 ,2,"@E 999,999,999,99"})		// Preco atual
aAdd(aCampos,{"SGR"     ,"N",14,2,"@E 999,999,999,99"})		// Preco Sugerido
aAdd(aCampos,{"RECDA1"	,"N",5,0})		// recno da1
aAdd(aCampos,{"CLAS"	,"C",1,0})		// Status de classificação
aAdd(aCampos,{"FORN"	,"C",6,0})	//Fornecedor
aAdd(aCampos,{"LJ"	,"C",2,0})	//Loja
aAdd(aCampos,{"RAZAO"	,"C",30,0})	//Nome Fornecedor
aAdd(aCampos,{"CUSTO"     ,"N",14,2,"@E 999,999,999,99"})		// Custo do produto

If Select('TRB') > 0
	TRB->(dbCloseArea())
EndIf

cArqTRB := CriaTrab(aCampos,.T.)
Use (cArqTRB) Alias TRB New Exclusive

Index On EMP + DOC To (cArqTRB) 

Return nil

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ºDescrição       Alimentar a tabela temporaria                          º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function AlimentaTRB()

Local cQry := ""

cQry += "SELECT "
cQry += "SF1.F1_FILIAL FILIAL, "
cQry += "SF1.F1_DOC DOC, "
cQry += "SF1.F1_SERIE SR, "
cQry += "SF1.F1_FORNECE FORN,"
cQry += "SF1.F1_LOJA LJ,"
cQry += "DA1_CODPRO COD, "
cQry += "SB2.B2_CM1 CUSTO, "
cQry += "SB1.B1_DESC DESCR, "
cQry += "DA1_PRCVEN ATUAL, "
cQry += "DA1.R_E_C_N_O_ RECDA1, "
cQry += "SF1.F1_STATUS CLAS, "
cQry += "(SB2.B2_CM1 * "
cQry += "(1 / "
cQry += "(1 - ( "
cQry += "(CASE WHEN SB1.B1_GRTRIB = ('001') THEN 0.18 ELSE 0 END) + /*ICMS*/ "
cQry += "0.0065  +/*PIS*/ "
cQry += "0.03  +/*COFINS*/ "
cQry += "0.0108 +/*CSLL*/ "
cQry += "(CASE WHEN SB1.B1_LOCPAD IN ('03','FL') THEN 0.0120 ELSE 0.02 END)+/*IRPJ*/ "
cQry += "(CASE WHEN SB1.B1_LOCPAD IN ('03','FL') THEN 0.10 ELSE 0.18 END)+/*DESPESAS FIXAS*/ "
cQry += "(CASE WHEN SB1.B1_LOCPAD IN ('03','FL')THEN 0.01 ELSE 0.01 END)+/*COMISSAO*/ "
cQry += "(CASE WHEN SB1.B1_LOCPAD IN ('03','FL')THEN 0.0474 ELSE 0 END)+/*CARTAO*/ "
cQry += "(0.10)/*MARGEM DE LUCRO*/ "
cQry += ")))) AS SGR "

cQry += "FROM SF1010 SF1 (NOLOCK) "
cQry += "INNER JOIN SD1010 SD1 (NOLOCK) ON (SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE) "
cQry += "INNER JOIN DA1010 DA1 (NOLOCK) ON (DA1.DA1_CODPRO = SD1.D1_COD) "
cQry += "INNER JOIN SB1010 SB1 (NOLOCK) ON (SB1.B1_COD = SD1.D1_COD) "
cQry += "INNER JOIN SB2010 SB2 (NOLOCK) ON (SB2.B2_COD = SD1.D1_COD AND SB2.B2_LOCAL = SD1.D1_LOCAL) "

cQry += "WHERE SF1.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' AND DA1.D_E_L_E_T_ <> '*' AND SB2.D_E_L_E_T_ <> '*' "
cQry += "AND F1_FILIAL =  '" + cFilAnt + "' AND F1_TIPO = 'N' AND F1_DTDIGIT BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02)+ "' " 
cQry += "AND SD1.D1_FORNECE = SF1.F1_FORNECE AND SD1.D1_LOJA = SF1.F1_LOJA AND SD1.D1_CF IN ('1102','1403','2403','2102') "
cQry += "AND DA1.DA1_CODTAB = '065' AND SD1.D1_XOK <> 'S'"

/* A IDEIA É SETAR OS CAMPOS VIA QUERY, MONDAR O BROWSE EM CIMA DA CONSULTA, E USAR AXALTERA NA DA1 UTILIZANDO RECDA1*/
	
	If Select("TEMP") > 0
		dbSelectArea("TEMP")
		dbCloseArea()
	Endif
		
TcQuery cQry New Alias "TEMP"

DbSelectArea("TEMP")

While TEMP->(!Eof())                                                       

  RecLock("TRB",.T.)
  TRB->EMP   := Alltrim(Substr(TEMP->FILIAL,1,2))
  TRB->FIL   := TEMP->FILIAL + "-" + POSICIONE("SM0",1,TEMP->FILIAL,"SM0->M0_NOME")
  TRB->DOC   := TEMP->DOC
  TRB->SR    := TEMP->SR
  TRB->COD  := TEMP->COD
  TRB->DESCR    := TEMP->DESCR
  TRB->ATUAL := TEMP->ATUAL
  TRB->SGR:= TEMP->SGR
  TRB->RECDA1   := TEMP->RECDA1
  TRB->CLAS := TEMP->CLAS
  TRB->FORN := TEMP->FORN
  TRB->LJ := TEMP->LJ   
  TRB->RAZAO := BuscaRaz(TEMP->FILIAL,"N",TEMP->FORN,TEMP->LJ)
  TRB->CUSTO := TEMP->CUSTO

  TRB->(MsUnLock())
  TEMP->(DbSkip())

EndDo

TRB->(DbGoTop())

Return()                                                       

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ºDescrição       Cria tela de visualização                              º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

User Function xVisual(cDoc,cSerie,cForn,cLoja)

Local aArea := GetArea()


DbSelectArea("SF1")
SF1->(DbSetOrder(1))
SF1->(DbSeek(xFilial("SF1")+cDoc+cSerie+cForn+cLoja))

A103NFiscal("SF1",SF1->(Recno()),2)
RestArea(aArea)

Return()                                         

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ºDescrição     Define legenda na tela                                   º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
                                                 
User Function xLegend()

Local aLegenda

aLegenda := {	{ "BR_VERMELHO"  ,"Aguardando Classificação" },;
				{ "BR_VERDE"    ,"Apto a analisar" }}  
			
BrwLegenda( cCadastro, OemToAnsi( "Status" ), aLegenda  ) 

Return
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ºDescrição          Atualiza Browse                                     º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

User Function xRefresh()
Pergunte(cPerg,.T.)
CriaTRB()
AlimentaTRB()
TRB->(DbGoTop())   

Return()                                         

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ºDescrição       Pesquisa Razao Social                                  º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
                                                    
Static Function BuscaRaz(cEmpresa,cTipo,cFor,cLoja)

Local cQuery := ""

Do Case
Case cTipo == "N"
 cQuery := "SELECT A2_NOME NOME FROM "+RETSQLNAME("SA2")+" A2 WHERE A2.D_E_L_E_T_ <> '*' AND A2_MSBLQL <> 1 AND A2_COD = '"+cFor+"' AND A2_LOJA = '"+cLoja+"' "
Otherwise
 cQuery := "SELECT A1_NOME NOME FROM "+RETSQLNAME("SA1")+" A1 WHERE A1.D_E_L_E_T_ <> '*' AND A1_MSBLQL <> 1 AND A1_COD = '"+cFor+"' AND A1_LOJA = '"+cLoja+"' "
End
		
If Select("TMP") > 0
	dbSelectArea("TMP")
	dbCloseArea()
Endif
		
TcQuery cQuery New Alias "TMP"

DbSelectArea("TMP")
TMP->(DbGotop())                                                       

Return(TMP->NOME) 

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ºDescrição       Pesquisa Razao Social                                  º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

User Function xPrice(cProd,cClas)

Private cCadastro := "Formação de Preço"
Private nPreco := 0//space(14)
Private lHasButton := .T.

SetPrvt("oFont1","oDlg1","oSay1","oGet1","oBtn1")
DbSelectArea("DA1")
DA1->(DbSetOrder(1))
DA1->(DbGoTop())
DA1->(DbSeek(FWxFilial('DA1') + '065' + cProd))  

nPreco := DA1->DA1_PRCVEN

If !Empty(cClas)

    oFont1  := TFont():New( "arial",0,-16,,.F.,0,,400,.F.,.F.,,,,,, )
	oDlg1   := MSDialog():New( 100,230,280,430,"Altera Preço",,,.F.,,,,,,.T.,,,.T. )
	oSay1   := TSay():New( 004,004,{||"Novo Preço:"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,084,015)
	oGet1   := TGet():New( 020, 009, { | u | If( PCount() == 0, nPreco, nPreco := u ) },oDlg1,060, 010, "@E 9,999,999.99",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nPreco",,,,lHasButton  )
	oBtn1   := TButton():New( 45,004,"Confirmar",oDlg1,{||Ok(cProd)},060,012,,oFont1,,.T.,,"",,,,.F. )
	
	oDlg1:Activate(,,,.T.)
else
    MsgStop("Nota fiscal ainda não foi classificada!")
EndIf

  
Return

Static Function Ok(cProd)
Local cQuery := ""
cQuery := "SELECT D1_XOK,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA FROM SD1010 WHERE D_E_L_E_T_ <> '*' AND D1_XOK = '' AND D1_COD = '"+cProd+"'"
	
    If Select("TP") > 0
		dbSelectArea("TP")
		dbCloseArea()
	Endif
		
TcQuery cQuery New Alias "TP"

DbSelectArea("TP")

DbSelectArea("DA1")
DA1->(DbSetOrder(1))
DA1->(DbGoTop())
DA1->(DbSeek(FWxFilial('DA1') + '065' + cProd))  

While TP->(!Eof())  

DbSelectArea("SD1")
SD1->(DbSetOrder(1))
SD1->(DbSeek(xFilial("SD1")+TP->D1_DOC+TP->D1_SERIE+TP->D1_FORNECE+TP->D1_LOJA+cProd)) 


RecLock("SD1",.F.)
SD1->D1_XOK := "S"   
SD1->(MsUnLock())

TP->(DbSkip())
EndDo

RecLock("DA1",.F.)
DA1->DA1_PRCVEN := nPreco
DA1->(MsUnLock())

DA1->(DbCloseArea())
SD1->(DbCloseArea())
TP->(DbCloseArea())

U_xRefresh()

oDlg1:End()

Return
