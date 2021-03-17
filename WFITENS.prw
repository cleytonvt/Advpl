#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "AP5MAIL.CH"   
#include "topconn.ch"  
#include "protheus.ch"
#include "rwmake.ch"    
#include "TbiConn.ch"
#include "TbiCode.ch"

User Function WfItens(cFornec,cLojaF,cDoc,cSerie)

Local cUser := "", cPass := ""
Local nTimeout := 0
Local oServer, oMessage
 
cUser := "cleytonvfsb@gmail.com" //define the e-mail account username
cPass := "" //define the e-mail account password
nTimeout := 60 // define the timout to 60 seconds
 
cNome := Alltrim(SA2->A2_NOME)


oServer := TMailManager():New()
 
oServer:SetUseSSL( .T. )
oServer:SetUseTLS( .F. )
 
oServer:Init( 'pop.gmail.com', 'smtp.gmail.com' , cUser, cPass, 995, 465 )
 
oServer:SetSmtpTimeOut( 120 )
 
//Verifica conexão SMTP
conout( 'Conectando do SMTP' )
nErro := oServer:SmtpConnect()
If nErro <> 0
conout( "ERROR:" + oServer:GetErrorString( nErro ) )
oServer:SMTPDisconnect()
return .F.
Endif 
 
//Verifica autenticação
nErro := oServer:SmtpAuth( cUser ,cPass )
If nErro <> 0
conout( "ERROR:" + oServer:GetErrorString( nErro ) )
oServer:SMTPDisconnect()
return .F.
Endif
 
oMessage := TMailMessage():New()
oMessage:Clear()
oMessage:cFrom := "cleytonvfsb@gmail.com"
oMessage:cTo := "email-destino"
oMessage:cCc := "email-destino"
oMessage:cSubject := "Entrada de Produtos - "+cNome
oMessage:cBody := ConteudoEmail(cNome,cFornec,cLojaF,cDoc,cSerie)

oMessage:AddCustomHeader( "Content-Type", "text/calendar" )
 
//Envia e-mail
nErro := oMessage:Send( oServer )
 
//Verifica se o e-mail foi enviado
if nErro <> 0
conout( "ERROR:" + oServer:GetErrorString( nErro ) )
oServer:SMTPDisconnect()
return .F.
Endif
 
conout( 'Desconectando do SMTP' )
oServer:SMTPDisconnect()


SD1->(DbCloseArea())
SA2->(DbCloseArea())
SF1->(DbCloseArea())
	
Return
/*###################################################################################################
###################################################################################################*/  

Static Function ConteudoEmail(cNome,cFornec,cLojaF,cDoc,cSerie)

DbSelectArea("SD1")
SD1->(DbSetOrder(1))
SD1->(DbSeek(xFilial("SD1")+cDoc+cSerie+cFornec+cLojaF))

cRet := '<html lang="pt_br">'
	
cRet += '<head></head>'
		
cRet += '<body >'
cRet += '<br/> <table> <tr> <td> <table> <tr> '
                
                cRet += '<td '
                cRet += 'style="background-color: #FFFFFF;'
                cRet += 'padding-left: 20px; '
                cRet += 'padding-right: 20px; '
                cRet += 'font-size: 14px;'
                cRet += 'line-height: 20px; '
                cRet += 'font-family: Arial, sans-serif; '
                cRet += '">'
                  
cRet += '<center>'
cRet += '<img align="center" src="logo.png" width=50px>'
cRet += '</center>'
    
    
cRet += '<h2 align="center">   </h2>'
    
cRet += '<br><br><br>'

cRet += '<h3 align="center"> Entrada de Produtos - NF: '+cDoc+' - '+cSerie+' </h3>'

cRet += '<br><br>'
                    
cRet += '<table border = "1">'
cRet += '<tr align="center">'
cRet += '<td> Código </td>'
cRet += '<td> Descricao </td>'
cRet += '<td> Quantidade </td>'
cRet += '<td> Lote </td>'
cRet += '<td> Validade </td>'
cRet += '</tr>'
    
while SD1->(!Eof()) .and. SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == cDoc+cSerie+cFornec+cLojaF 

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))

cRet += '<tr align="center">'
cRet += '<td>'+SD1->D1_COD+ '</td><td>' + Alltrim(SB1->B1_DESC) + '</td><td> ' + Alltrim(Transform(SD1->D1_QUANT,"@E 9,999,999.99")) + '</td><td> ' + SD1->D1_LOTECTL+ '</td><td> ' + dtoc(SD1->D1_DTVALID)'
cRet += '</tr>'
    
SD1->(DbSkip())
EndDo
                     
cRet += '</table>'
cRet += '</td></tr></table></td></tr></table>'
cRet += '</body>'
cRet += '</html>'

SD1->(DbCloseArea())
SB1->(DbCloseArea())
Return cRet
