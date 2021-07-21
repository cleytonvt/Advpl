#include "Protheus.ch"
#include "totvs.ch"
#include "topconn.ch"
#include "rwmake.ch"
#INCLUDE "TBICONN.CH"   

User Function xOrdemSep(cNum,cLibok,cNota,cBlq,cBlest,cBlcred,cContra)

Local cNumSep := ''
Local cQry :=''
Local nItens := 0

If Alltrim(cContra) = '1'
msgstop("Ordem de Separação já foi gerada para este pedido!")
Else

	If !Empty(cLibok) .and. Empty(cNota) .and. Empty(cBlq) .and. Empty(cBlest) .and. Empty(cBlcred) .and. Alltrim(cContra) <> 'M'

		if MSGYESNO("Deseja gerar ordem de separação para pedido: "+cNum+"?")

		cQry := " SELECT C6_ITEM ITEM, C6_PRODUTO PRODUTO, C6_LOCAL LOCAL, C6_QTDVEN QUANT, C6_LOTECTL LOTE,C6_NUM NUM,"
		cQry += " (SELECT top 1 BF_LOCALIZ FROM SBF010 SBF (NOLOCK) WHERE SBF.D_E_L_E_T_ <> '*' AND BF_PRODUTO = C6_PRODUTO AND BF_LOTECTL = C6_LOTECTL AND BF_LOCAL = C6_LOCAL  AND C6_QTDVEN <= (BF_QUANT - BF_EMPENHO) ORDER BY BF_PRIOR) ENDER"
		cQry += " FROM SC6010 SC6 (NOLOCK)"
		cQry += " WHERE SC6.D_E_L_E_T_ <> '*'"
		cQry += " AND SC6.C6_NUM = '"+cNum+"'"

		TCQUERY cQry NEW ALIAS "QRY" 
		QRY->(DBGotop()) 
		DbSelectArea("QRY")  

		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xfilial("SC5")+cNum))

		cNumSep := GETSXENUM("CB7","CB7_ORDSEP")

		While QRY->(!Eof()) .AND. QRY->NUM == cNum
		nItens:= nItens+1 
		RECLOCK("CB8",.T.)
		CB8->CB8_FILIAL := XFILIAL("CB8")
		CB8->CB8_ORDSEP := cNumSep
		CB8->CB8_PEDIDO := cNum
		CB8->CB8_ITEM   := QRY->ITEM
		CB8->CB8_PROD   := QRY->PRODUTO
		CB8->CB8_LOCAL  := QRY->LOCAL
		CB8->CB8_QTDORI := QRY->QUANT
		CB8->CB8_SALDOS := QRY->QUANT
		CB8->CB8_SALDOE := 0
		if Localiza(QRY->PRODUTO)
		CB8->CB8_LCALIZ := QRY->ENDER
		EndIf
		CB8->CB8_SEQUEN := '01'
		CB8->CB8_LOTECT := QRY->LOTE
		CB8->CB8_SALDOD := 0
		CB8->CB8_CFLOTE := '1'
		CB8->CB8_SLDPRE := QRY->QUANT
		CB8->CB8_TIPSEP := '1'
		CB8->(MSUNLOCK())
		QRY->(DbSkip())
		EndDo


		RECLOCK("CB7",.T.)
		CB7->CB7_FILIAL := XFILIAL("CB7")
		CB7->CB7_ORDSEP := cNumSep
		CB7->CB7_LOCAL  := '01'
		CB7->CB7_PEDIDO := ''//cNum
		CB7->CB7_CLIENT := SC5->C5_CLIENTE
		CB7->CB7_LOJA   := SC5->C5_LOJACLI
		CB7->CB7_DTEMIS := DATE() 
		CB7->CB7_HREMIS := TIME()
		CB7->CB7_STATUS := '0'
		CB7->CB7_PRIORI := '1'
		CB7->CB7_ORIGEM := '1'
		CB7->CB7_TIPEXP := '00*03*04*08*09*10'
		CB7->CB7_COND   := SC5->C5_CONDPAG
		CB7->CB7_LOJENT := SC5->C5_LOJACLI
		CB7->CB7_NUMITE := nItens
		CB7->(MSUNLOCK())

		msginfo("Ordem de Separação Numero: "+cNumSep+" gerada com sucesso!")

		Reclock("SC5",.F.)
		SC5->C5_KITREP := '1'
		SC5->C5_XHORA1 := Left(Time(),5)
		MSUNLOCK()
		
		U_xCargped()
		
		Else

		msgstop("Cancelado pelo usuário!")

		EndiF
		
	Else
		
	msgstop("Pedido não está apto para separação")
	
	EndIF

QRY->(DbCloseArea())
SC5->(DbCloseArea())
EndIf


Return