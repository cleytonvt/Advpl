#include "protheus.ch"
#include "topconn.ch" 
#include "rwmake.ch"

User Function MyTeca500()

RegToMemory("AB6",.F.)

If msgyesno("Deseja gerar agendamento para a O.S. "+M->AB6_NUMOS+"?")

SetPrvt("oFont1","oFont2","oDlg1","oSay1","oSay2","oSay3","oSay4","oGet1","oGet2","oGet3","oGet4","oBtn1","oBtn2")    

Private dDataIni := space(10)
Private dDataFim := space(10)
Private cHoraIni := space(5)
Private cHoraFim := space(5)
Private cNum := M->AB6_NUMOS
Private cAtend := M->AB6_ATEND

oFont1     := TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )
oFont2     := TFont():New( "MS Sans Serif",0,-13,,.F.,0,,400,.F.,.F.,,,,,, )   

DbSelectArea("AA1")
AA1->(DbSetOrder(5))
AA1->(DbSeek(xFilial("AA1")+PadR(cAtend,30)))

cCodAt:=AA1->AA1_CODTEC

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
Return     


Static Function Ok()

//DEFININDO variáveis
Local aTecnico := {}
Local aAgenda := {}
Local aAgendas := {}
Local cDataIni := substr(dDataIni,1,2)+'/'+substr(dDataIni,3,2)+'/'+substr(dDataIni,5,2)//substr(dDataIni,5,4)+substr(dDataIni,3,2)+substr(dDataIni,1,2)
Local cDataFim := substr(dDataFim,1,2)+'/'+substr(dDataFim,3,2)+'/'+substr(dDataFim,5,2)//substr(dDataFim,5,4)+substr(dDataFim,3,2)+substr(dDataFim,1,2)


Begin Transaction
lMsErroAuto:=.F.
MSGINFO(cCodAt)
//Necessário ter cadastrado préviamente o técnico com código 000002
aAdd(aTecnico,{"AA1_CODTEC",cCodAt,Nil})
aAdd(aAgenda,{"ABB_DTINI",cToD(cDataIni),Nil})
aAdd(aAgenda,{"ABB_HRINI",cHoraIni,Nil})
aAdd(aAgenda,{"ABB_DTFIM",cTod(cDataFim),Nil})
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
 AB6->AB6_STATUS := 'C'
 AB6->(MSUNLOCK())
 ENDIF

End Transaction
AA1->(DbCloseArea())	
oDlg1:end()
Return Nil
