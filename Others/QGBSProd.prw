#include "Protheus.ch"

User Function EXECSBZ()

	Local aCab            := {}
	Local aItens        := {}
	Local aItem        := {}
	Local aAreaSM0    := {}
	Local nOpc            := 3

	Private lMsErroAuto    := .F.

	aCab := {}
	lMsErroAuto := .F.

	aAdd(aCab,{'BZ_COD',"000000001",Nil})
	aAdd(aCab,{'BZ_LOCPAD',"01",Nil})
	aAdd(aCab,{'BZ_TE',"",Nil})

	MSExecAuto({|v,x| MATA018(v,x)},aCab,nOpc)

	If !lMsErroAuto
		Conout('Inserido/Alterado/Excluido com sucesso')
	Else
		Conout('Erro na Inclusão/Alteração/Exclusão')
		MostraErro()
	Endif


Return
