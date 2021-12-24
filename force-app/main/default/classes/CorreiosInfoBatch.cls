public with sharing class CorreiosInfoBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	public Database.QueryLocator start(Database.BatchableContext bc) {

		List<String> caseStatusToFilter = new List<String>{'Closed'};

        String query = 'SELECT id, NumeroColeta__c, ReversaStatus__c FROM Case WHERE status NOT IN: caseStatusToFilter AND NumeroColeta__c != null AND ReversaStatus__c = \'Aguardando Objeto na Agência\'';
		return Database.getQueryLocator(query);

	}

	// batch runs in single scope because correios integration only work with one ticket number at a time
	public void execute(Database.BatchableContext bc, List<Case> scope) {

		Case caseObj = scope[0];

		List<ObjetoPostagemReversa__c> postalObjects = [
			SELECT  id, idObjetoColeta__c, NumeroEtiqueta__c, UltimoStatusRastreamento__c, DataUltimaAtualizacao__c
			FROM 	ObjetoPostagemReversa__c
			WHERE   Caso__c =: caseObj.Id
		];

		logisticaReversaCorreios.logisticaReversaWSPort logistica = new logisticaReversaCorreios.logisticaReversaWSPort();
		logisticaReversaCorreios.retornoAcompanhamento retornoAcompanhamento = logistica.acompanharPedido(new List<String>{caseObj.NumeroColeta__c});

		// Date data_atualizacao_historico = createNewDateInstance(retornoAcompanhamento.coleta[0].historico[0].data_atualizacao);

		Map<String, ObjetoPostagemReversa__c> idObjetoColetaToObjetoPostagemReversa = new Map<String, ObjetoPostagemReversa__c>();

		for(ObjetoPostagemReversa__c objPostagemReversa : postalObjects) {
			if(String.isBlank(objPostagemReversa.NumeroEtiqueta__c)) {
				idObjetoColetaToObjetoPostagemReversa.put(objPostagemReversa.idObjetoColeta__c, objPostagemReversa);
			}
		}

		Boolean isAnyPostalObjectPosted = false;

		for (logisticaReversaCorreios.objetoPostal objeto : retornoAcompanhamento.coleta[0].objeto) {
			if(idObjetoColetaToObjetoPostagemReversa.get(objeto.controle_objeto_cliente) != null) {
				idObjetoColetaToObjetoPostagemReversa.get(objeto.controle_objeto_cliente).NumeroEtiqueta__c = objeto.numero_etiqueta;
				idObjetoColetaToObjetoPostagemReversa.get(objeto.controle_objeto_cliente).UltimoStatusRastreamento__c = objeto.descricao_status;
				String lastUpdateDate = objeto.data_ultima_atualizacao;
				String formattedDate = lastUpdateDate.substring(0, 2) + '/' + lastUpdateDate.substring(3, 5) + '/' + lastUpdateDate.substring(6, 10);
				idObjetoColetaToObjetoPostagemReversa.get(objeto.controle_objeto_cliente).DataUltimaAtualizacao__c = formattedDate;
				idObjetoColetaToObjetoPostagemReversa.get(objeto.controle_objeto_cliente).HoraUltimaAtualizacao__c = objeto.hora_ultima_atualizacao;

				if(objeto.numero_etiqueta != null) {
					isAnyPostalObjectPosted = true;
				}
			}
		}

		update idObjetoColetaToObjetoPostagemReversa.values();

		retornoAcompanhamento.coleta[0].historico[0].descricao_status = 'Prazo de Utilização Expirado';

		if(caseObj.ReversaStatus__c != retornoAcompanhamento.coleta[0].historico[0].descricao_status) {
			System.debug('caseObj.ReversaStatus__c => ' + caseObj.ReversaStatus__c);
				caseObj.ReversaStatus__c = retornoAcompanhamento.coleta[0].historico[0].descricao_status;
			System.debug('caseObj.ReversaStatus__c => ' + caseObj.ReversaStatus__c);
		}

		update caseObj;
	}

	public void finish(Database.BatchableContext bc) {
		
	}

	// date must be in DD-MM-YYYY format
	private static Date createNewDateInstance(String dateString) {
		Integer day   = Integer.valueOf(dateString.substring(0, 2));
		Integer month = Integer.valueOf(dateString.substring(3, 5));
		Integer year  = Integer.valueOf(dateString.substring(6, 10));

		return date.newInstance(year, month, day);
	}
}