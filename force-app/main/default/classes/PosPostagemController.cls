public with sharing class PosPostagemController {

    @AuraEnabled 
    public static String PosPostagemController(String recordId) {

        try {

            Case caso = [
                SELECT  id, 
                    (   SELECT id, idObjetoColeta__c, NumeroEtiqueta__c, UltimoStatusRastreamento__c
                        FROM ObjetosPostagemReversa__r
                    )
                FROM    Case 
                WHERE   id =: recordId
            ];

            if(caso.ObjetosPostagemReversa__r.isEmpty()) {
                return 'Não há nenhum objeto de postagem reversa criado para este case. Solicite a Postagem Reversa dos Itens.';
            }

            Map<String, ObjetoPostagemReversa__c> numeroEtiquetaToObjetoPostagemReversa = new Map<String, ObjetoPostagemReversa__c>();

            for(ObjetoPostagemReversa__c objPostagemReversa : caso.ObjetosPostagemReversa__r) {
                if(!String.isBlank(objPostagemReversa.NumeroEtiqueta__c)) {
                    numeroEtiquetaToObjetoPostagemReversa.put(objPostagemReversa.NumeroEtiqueta__c, objPostagemReversa);
                }
            }

            if(numeroEtiquetaToObjetoPostagemReversa.keySet().isEmpty()) {
                return 'Não há nenhum objeto de postagem reversa com o número etiqueta. Solicite o Número de Etiqueta (E-Ticket) dos Itens.';
            }
            
            SroXML2 response = RastreioCallout.getStatusRastreamento(new List<String>(numeroEtiquetaToObjetoPostagemReversa.keySet()));

            for(SROXML2.ObjetoRastreio objeto : response.objeto) {
                System.debug('objeto => ' + JSON.serializePretty(objeto));
                System.debug('objeto.numero => ' + objeto.numero);
                System.debug('objeto.descricao => ' + objeto.evento[0].descricao);
                numeroEtiquetaToObjetoPostagemReversa.get(objeto.numero).UltimoStatusRastreamento__c = objeto.evento[0].descricao;
                numeroEtiquetaToObjetoPostagemReversa.get(objeto.numero).DataUltimaAtualizacao__c    = objeto.evento[0].data;
                numeroEtiquetaToObjetoPostagemReversa.get(objeto.numero).HoraUltimaAtualizacao__c    = objeto.evento[0].hora;
            }

            update numeroEtiquetaToObjetoPostagemReversa.values();

            return 'Sucesso! Últimos status dos objetos com número etiqueta atualizados.';

        } catch (Exception e) {
            return 'Erro: ' + e.getMessage();
        }
    }
}