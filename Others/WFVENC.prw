#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "AP5MAIL.CH"   
#include "topconn.ch"  
#include "protheus.ch"
#include "rwmake.ch"    
#include "TbiConn.ch"
#include "TbiCode.ch"

User Function WFVENC()

 Local cUser := "", cPass := ""
 Local nTimeout := 0
 Local oServer, oMessage
 
 cUser := "cleytonvfsb@gmail.com" //define the e-mail account username
 cPass := "" //define the e-mail account password
 nTimeout := 60 // define the timout to 60 seconds
 
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
 oMessage:cTo := "email_destino"
 oMessage:cCc := "emails_destino"
 oMessage:cSubject := "Produtos a vencer"
 oMessage:cBody := content()

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
 
return

/*###################################################################################################
###################################################################################################*/

Static Function Content()

PREPARE ENVIRONMENT EMPRESA ( "01" ) FILIAL ( "01" ) MODULO "FAT"

cQuery := "SELECT B8_PRODUTO PROD, B8_LOCAL ARM, B8_SALDO SALDO, B8_LOTECTL LOTE, B8_DTVALID VALID "
cQuery += "FROM SB8010 WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND B8_DTVALID BETWEEN CONVERT(VARCHAR(8), GETDATE(), 112) AND  CONVERT(VARCHAR(8), DATEADD(month, 3, GETDATE()), 112)"
cQuery += "AND B8_SALDO > 0"
cQuery += "ORDER BY B8_DTVALID"

TCQUERY cQuery NEW ALIAS "QRY" 
QRY->(DBGotop()) 
DbSelectArea("QRY")  

cRet :='<html lang="pt_br">'

cRet +='<head></head>'
	
cRet +='<body> <table> <tr> <td> <table> <tr>' 
                
cRet +='<td' 
cRet +='style="background-color:#FFF;'
cRet +='padding-left: 20px;' 
cRet +='padding-right: 20px;' 
cRet +='font-size: 14px;'
cRet +='line-height: 20px;' 
cRet +='font-family: Arial, sans-serif;' 
cRet +='">'
                  
cRet +='<center><img align="center" src="logomarca.png" width="15%"></center>'
    
cRet +='<p><h3 align="center"> Listagem de Produtos a Vencer </h3></p>'    
           
cRet +='<table border = "1">'
cRet +='<tr align="center">'
cRet +='<td> Código </td>'
cRet +='<td> Descricao </td>'
cRet +='<td> Local </td>'
cRet +='<td> Quantidade </td>'
cRet +='<td> Lote </td>'
cRet +='<td> Validade </td></tr>'

while QRY->(!Eof()) 

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+QRY->PROD))
    
		cRet +='<tr align="center">'
		cRet +='<td>'+QRY->PROD+ '</td>'
		cRet +='<td>' + Alltrim(SB1->B1_DESC) + '</td>'
		cRet +='<td>' + QRY->ARM + '</td>'
		cRet +='<td> ' + Alltrim(Transform(QRY->SALDO,"@E 9,999,999.99")) + '</td>'
		cRet +='<td> ' + QRY->LOTE+ '</td>'
		cRet +='<td> ' + DtoC(StoD(QRY->VALID)) +'</td></tr>'
QRY->(DbSkip())
EndDo
        
                        
cRet +='</table></td></tr></table></td></tr></table>'
cRet +='</body>'
cRet +='</html>'

SB1->(DbCloseArea())
QRY->(DbCloseArea())

RESET ENVIRONMENT

Return cRet
