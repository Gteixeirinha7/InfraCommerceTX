public with sharing class CorreiosRastreamentoBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	public Database.QueryLocator start(Database.BatchableContext bc) {

		List<String> caseStatusToFilter = new List<String>{'Em atendimento', 'Reaberto'};

        String query = 'SELECT id, caso__c, idObjetoColeta__c, NumeroEtiqueta__c, UltimoStatusRastreamento__c, DataUltimaAtualizacao__c, ReversaStatus__c FROM ObjetoPostagemReversa__c WHERE NumeroEtiqueta__c != null AND EnvioConcluido__c = false AND caso__r.status IN: caseStatusToFilter AND caso__r.NumeroColeta__c != null AND ReversaStatus__c = \'Coletado\'';
		return Database.getQueryLocator(query);

	}

	// batch runs in single scope because correios integration only work with one ticket number at a time
	public void execute(Database.BatchableContext bc, List<ObjetoPostagemReversa__c> scope) {

		Map<String, ObjetoPostagemReversa__c> numeroEtiquetaToObjetoPostagemReversa = new Map<String, ObjetoPostagemReversa__c>();

        Set<Id> caseIds = new Set<Id>();

        for(ObjetoPostagemReversa__c objPostagemReversa : scope) {
            numeroEtiquetaToObjetoPostagemReversa.put(objPostagemReversa.NumeroEtiqueta__c, objPostagemReversa);
            caseIds.add(objPostagemReversa.caso__c);
        }

        SroXML2 response = RastreioCallout.getStatusRastreamento(new List<String>(numeroEtiquetaToObjetoPostagemReversa.keySet()));

        for(SROXML2.ObjetoRastreio objeto : response.objeto) {
            SroXML2.Evento ultimoEvento = objeto.evento[0];
            numeroEtiquetaToObjetoPostagemReversa.get(objeto.numero).UltimoStatusRastreamento__c = ultimoEvento.descricao;
            numeroEtiquetaToObjetoPostagemReversa.get(objeto.numero).DataUltimaAtualizacao__c    = ultimoEvento.data;
            numeroEtiquetaToObjetoPostagemReversa.get(objeto.numero).HoraUltimaAtualizacao__c    = ultimoEvento.hora;
            //alterar para verificar os códigos de status concluídos a partir do metadado
            if(true) { // ultimoEvento.tipo == 'BDE' && listaDeCodigosConcluidos.contains(ultimoEvento.status)?
                numeroEtiquetaToObjetoPostagemReversa.get(objeto.numero).EnvioConcluido__c = true;
            }
        }

        update numeroEtiquetaToObjetoPostagemReversa.values();
	}

	public void finish(Database.BatchableContext bc) {
		
	}
}