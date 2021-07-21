#include "Protheus.ch"
#include "TopConn.ch"

User Function WFW120P()

	Local cPedido  := PARAMIXB
	Private cQuery := ""
	Private nDias  := GetMV("MV_DPERD")

	dBselectArea('SC7')
	dbSetOrder(1)
	dbSeek(cPedido)

	cNum:= Substr(cPedido,7,6)

//confere se é uma inclusão ou uma alteração, na exclusão nao executa o fonte
	If INCLUI .or. ALTERA

		cQuery +="SELECT D2_COD PROD, D2_DOC NF, D2_EMISSAO DATA, D2_QUANT QTD,D2_LOTECTL LOTE, D2_DTVALID VALID FROM SD2010 "
		cQuery += "WHERE D_E_L_E_T_ <> '*' "
		cQuery += "AND D2_CF = '5927' "
		cQuery += "AND D2_COD IN (SELECT C7_PRODUTO FROM SC7010 WHERE C7_NUM = '"+cNum+"' AND D_E_L_E_T_ <> '*') "
		cQuery += "AND D2_DTVALID BETWEEN '"+dtos(DaySub(Date(),nDias))+"' AND '"+dtos(Date())+"'"
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"QY", .F., .T.)
		Count to nCount

		If nCount > 0
			MailVenc(cNum,cQuery)
		EndIf
	QY->(dbCloseArea())
	EndIf
Return


/*##############################################################################
TRECHO DE CODIGO RESPONSAVEL POR ENVIAR EMAIL PARA DIRETORIA E COMPRAS
INFORMANDO QUE O PRODUTO QUE ESTA SENDO COMPRADO SE VENCEU EM N DIAS
*///############################################################################

Static Function MailVenc(cNum,cQuery)

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
	oMessage:cTo := "destino"
	oMessage:cCc := ""
	oMessage:cSubject := "Produtos venceram recentemente Pedido - "+cNum
	oMessage:cBody := Conteudo(cNum,cQuery)

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

/*##############################################################################
TRECHO DE CODIGO RESPONSAVEL POR MONTAR O CORPO DO EMAIL
*///############################################################################

Static Function Conteudo(cNum,cQuery)

	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	SC7->(DbSeek(xFilial("SC7")+cNum))

	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"QRY", .F., .T.)

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

	cRet +='<center><img align="center" src="imglogo" width="15%"></center>'

	cRet +='<p><h3 align="center">Produtos que Venceram Recente no Pedido - '+cNum+' </h3></p>'

	cRet +='<table border = "1">'
	cRet +='<tr align="center">'
	cRet +='<td> Código </td>'
	cRet +='<td> Descricao </td>'
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
		cRet +='<td> ' + Alltrim(Transform(QRY->QTD,"@E 9,999,999.99")) + '</td>'
		cRet +='<td> ' + QRY->LOTE+ '</td>'
		cRet +='<td> ' + DtoC(StoD(QRY->VALID)) +'</td></tr>'
		QRY->(DbSkip())
	EndDo


	cRet +='</table></td></tr></table></td></tr></table>'
	cRet +='</body>'
	cRet +='</html>'

	SC7->(DbCloseArea())
	SB1->(DbCloseArea())
	QRY->(DbCloseArea())

Return cRet
