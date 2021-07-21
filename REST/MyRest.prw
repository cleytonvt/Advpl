#Include 'Protheus.ch'
#Include 'RestFul.CH'

#DEFINE nPages := 1

//NOMEIA A API
WSRESTFUL produtos DESCRIPTION 'API de Produtos'

//DEFINIÇÃO DOS METODOS HTTP

WSMETHOD GET prodID DESCRIPTION "Retorna Produto passado na URL" PATH "/produtos/{id}"

END WSRESTFUL

//MONTAGEM DOS METODOS
WSMETHOD GET prodID WSSERVICE PRODUTOS
Local cProd := ::aURLParms[1] 
Local aArea := GetArea()
Local oProd := Nil 
Local cJson := ""
Local cStatus := ""

/*-------------------------*/
/*define o tipo de resposta*/
/*-------------------------*/
::setContentType("application/json")

/*-------------------------*/
/*inicia objeto, com campos*/
/*-------------------------*/
DbSelectArea("SB1")
SB1->(DbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+cProd))
    cStatus("Produto Encontrado!")
    oProd:Produtos():New(SB1->B1_COD,SB1->B1_DESC,SB1->B1_LOCPAD,SB1->B1_UM,cStatus)
else
    oProd:Produtos():New(cStatus)
EndIf

/*-----------------------------------*/
/*funcao totvs para serializar o json*/
/*-----------------------------------*/
cJson := FWJsonSerialize(oProd)

/*-----------------------------------------------------*/
/*seta como resposta, a variavel com o json serializado*/
/*-----------------------------------------------------*/
::setResponse(cJson)

RestArea(aArea)
return .t.
