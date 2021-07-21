#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "AP5MAIL.CH"   
#include "topconn.ch"  
#include "protheus.ch"
#include "rwmake.ch"    
#include "TbiConn.ch"
#include "TbiCode.ch"

/*Author: CLeyton Victor 28/11/2020*/

User Function MyTeca500()

RegToMemory("AB6",.F.)

If M->AB6_STATUS == 'A' .AND. Empty(M->AB6_OK)

	If msgyesno("Deseja gerar agendamento para a O.S. "+M->AB6_NUMOS+"?")

	SetPrvt("oFont1","oFont2","oDlg1","oSay1","oSay2","oSay3","oSay4","oGet1","oGet2","oGet3","oGet4","oBtn1","oBtn2")    

	Private dDataIni := STOD(space(10))
	Private dDataFim := STOD(space(10))
	Private cHoraIni := space(5)
	Private cHoraFim := space(5)
	Private cNum := M->AB6_NUMOS
	Private cAtend := M->AB6_ATEND
	Private cMail := ''

	oFont1     := TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )
	oFont2     := TFont():New( "MS Sans Serif",0,-13,,.F.,0,,400,.F.,.F.,,,,,, )   

	DbSelectArea("AA1")
	AA1->(DbSetOrder(5))
	AA1->(DbSeek(xFilial("AA1")+PadR(cAtend,30)))

	cCodAt:=AA1->AA1_CODTEC
	cMail := Alltrim(AA1->AA1_EMAIL)

	oDlg1      := MSDialog():New( 092,232,355,777,"Parametros de Agendamento",,,.F.,,,,,,.T.,,,.T. )		

	oSay1      := TSay():New( 016,024,{||"Data Ini."},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) 
	oSay2      := TSay():New( 036,024,{||"Data Fim"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3      := TSay():New( 056,024,{||"Hora Ini."},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) 
	oSay4      := TSay():New( 076,024,{||"Hora Fim"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

	oGet1      := TGet():New( 016,064,{|u| If(PCount()>0,dDataIni:=u,dDataIni)},oDlg1,060,008,'@r 99/99/9999',,CLR_BLACK,CLR_WHITE,oFont2,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDataIni",,)
	oGet2      := TGet():New( 036,064,{|u| If(PCount()>0,dDataFim:=u,dDataFim)},oDlg1,060,008,'@r 99/99/9999',,CLR_BLACK,CLR_WHITE,oFont2,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDataFim",,)
	oGet3      := TGet():New( 056,064,{|u| If(PCount()>0,cHoraIni:=u,cHoraIni)},oDlg1,060,008,'99:99',,CLR_BLACK,CLR_WHITE,oFont2,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cHoraIni",,)
	oGet4      := TGet():New( 076,064,{|u| If(PCount()>0,cHoraFim:=u,cHoraFim)},oDlg1,060,008,'99:99',,CLR_BLACK,CLR_WHITE,oFont2,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cHoraFim",,)

	oBtn1     := SButton():New( 079,160,1,{||Ok()},oDlg1,,"OK", )
	oBtn2     := SButton():New( 079,208,2,{||oDlg1:End()},oDlg1,,"", )

	oDlg1:Activate(,,,.T.)

	Else
	msgstop("Cancelado pelo Usúario!")
	EndIf

EndiF
Return     


Static Function Ok()

//DEFININDO variáveis
Local aTecnico := {}
Local aAgenda := {}
Local aAgendas := {}
//Local dDataIni := substr(dDataIni,1,2)+'/'+substr(dDataI§ni,3,2)+'/'+substr(dDataIni,5,2)
//Local dDataFim := substr(dDataFim,1,2)+'/'+substr(dDataFim,3,2)+'/'+substr(dDataFim,5,2)


Begin Transaction
lMsErroAuto:=.F.

//Necessário ter cadastrado préviamente o técnico com código 000002
aAdd(aTecnico,{"AA1_CODTEC",cCodAt,Nil})
aAdd(aAgenda,{"ABB_DTINI",dDataIni,Nil})
aAdd(aAgenda,{"ABB_HRINI",cHoraIni,Nil})
aAdd(aAgenda,{"ABB_DTFIM",dDataFim,Nil})
aAdd(aAgenda,{"ABB_HRFIM",cHoraFim,Nil})
aAdd(aAgenda,{"ABB_ENTIDA", "AB6", Nil}) 
aAdd(aAgenda,{"ABB_CHAVE", cNum, Nil}) 
aAdd(aAgenda,{"ABB_NUMOS", cNum, Nil}) 
aAdd(aAgendas,aAgenda)

MSExecAuto( {|x,y| TECA500(x,y)},aTecnico,aAgendas)

 If lMsErroAuto
 	MostraErro()
	DisarmTransaction()
 Else
 
 Msginfo("Agendamento realizado com Sucesso!")
 
 RECLOCK("AB6",.F.)
 AB6->AB6_OK := 'AG'
 AB6->(MSUNLOCK())
 
 //################################################################################### 
 EnvAgd(cNum,cMail,dDataIni,cHoraIni,dDataFim,cHoraFim)//#################ENVIAR EMAIL
 //###################################################################################
 ENDIF
 


End Transaction

AA1->(DbCloseArea())	
oDlg1:end()
Return Nil


//#####################################################################################
//########################################################################INICIO ENVAGD
//#####################################################################################
Static Function EnvAgd(cNum,cMail,dDataIni,cHoraIni,dDataFim,cHoraFim)

Local cServidor	:= "smtp.gmail.com:465"
Local lAutentic	:= .T.
Local cContaEm	:= "workflow@diagfarma.com.br"
Local cPassEm	:= "diag12345678"
Local lOk	:= .T.
Local cTO	:= cMail
Local cCC	:= 'gvendas@diagfarma.com.br'
Local cBCC	:= ''
Local cTitulo := 'Agendamento - OS #'+cNum
Local cAnexo := ''

DbSelectArea("ABB")
ABB->(DbSetOrder(3))
ABB->(DbSeek(xfilial("ABB")+cNum))

	
//Adiciona os dados referentes ao email
If Empty(cServidor) .And. Empty(cContaEm) .And. Empty(cPassEm)
	MsgAlert("Dados do servidor de email não configurados")
	lOk := .F.
EndIf
	
//Conteúdo do Email
If lOk
	cHTML := ConteudoEmail(cNum,dDataIni,cHoraIni,dDataFim,cHoraFim)
EndIf
	
//Realiza o envio do email
If lOk

//Conecta com o servidor de e-mail
	CONNECT SMTP SERVER cServidor ACCOUNT cContaEm PASSWORD cPassEm RESULT lOk
	        
//Realiza a autenticação caso necessário
	If lOk .And. lAutentic
		lOk := MailAuth(cContaEm, cPassEm)
	EndIf
				
//Realiza o envio do email
	If lOk
	
		SEND MAIL FROM cContaEm TO cTO CC cCC BCC cBCC SUBJECT cTitulo BODY cHTML FORMAT TEXT ATTACHMENT cAnexo RESULT lOk
	
	EndIf

	DISCONNECT SMTP SERVER
			
	EndIf
	
Return
/*###################################################################################################
###################################################################################################*/  

Static Function ConteudoEmail(cNum,dDataIni,cHoraIni,dDataFim,cHoraFim) 

DbSelectArea("AB7")
AB7->(DbSetOrder(1))
AB7->(DbSeek(xfilial("AB7")+cNum))

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbSeek(xfilial("SA1")+AB7->AB7_CODCLI+AB7->AB7_LOJA))

cRet:= '<html lang="pt_br">'
cRet+= '<head>'
cRet+= '</head>'
cRet+= '<body >'
cRet+= '<div class="a">'
cRet+= '<h3>Dados do Cliente</h3>'
cRet+= '<br> <b> Data Inicial: </b> '+ dtoc(dDataIni)+'&nbsp; <b>Data Final: </b> '+dtoc(dDataFim)
cRet+= '<br> <b> Hora Inicial: </b> '+cHoraIni+'&nbsp; <b>Hora Final: </b> '+cHoraFim
cRet+= '<br> <b> Cliente: </b> '+SA1->A1_COD+'-'+Alltrim(SA1->A1_NOME)
cRet+= '<br> <b> Endereço: </b> '+ Alltrim(SA1->A1_END) +', '+Alltrim(SA1->A1_BAIRRO)
cRet+= '<br> <b> Cidade: </b> '+ Alltrim(SA1->A1_MUN) + '<b> Estado: </b> '+Alltrim(SA1->A1_EST)
cRet+= '<br> <b> Telefone: </b>'
cRet+= '<a href="'+SA1->A1_TEL+'">'+ SA1->A1_TEL +' </a> / '
cRet+= '<a href="'+SA1->A1_TELEX+'">'+ SA1->A1_TELEX +'</a> / '
cRet+= '<a href="'+SA1->A1_FAX+'">'+ SA1->A1_FAX +'</a>'
cRet+= '<p><a href="http://maps.google.com/?saddr=&daddr='+Alltrim(SA1->A1_END)+','+Alltrim(SA1->A1_BAIRRO)+','+Alltrim(SA1->A1_MUN)+','+Alltrim(SA1->A1_EST)+'" target="_blank"><button style="background: #069cc2; border-radius: 6px; padding: 12px; cursor: pointer; color: #fff; border: none; font-size: 12px;">Gerar Rota</button></a></p>'
cRet+= '<h3>Dados do Atendimento</h3>  '
cRet+= '<br> <b> Equipamento: </b> '+AB7->AB7_CODPRO+' - '+AB7->AB7_XDESC
cRet+= '<br> <b> N/S: </b> '+AB7->AB7_NUMSER
cRet+= '<br> <b> Ocorrencia: </b> '+AB7->AB7_CODPRB
cRet+= '<br> <b> Descrição dos problemas: </b> <br> '+ memoline(AB7->AB7_MEMO5)
cRet+= '</div>'
cRet+= '</body>'
cRet+= '</html>'

Return cRet
