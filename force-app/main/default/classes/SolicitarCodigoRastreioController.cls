public with sharing class SolicitarCodigoRastreioController {

    @AuraEnabled
    public static String recordIdCaso(String id) {
        Case caso = new Case();
        String retorno = 'Sucesso';
        return retorno;
    }

    @AuraEnabled
    public static String solicitaCodigoRastreio(String idCaso) {

        try {

            Case caso = [
                SELECT  Id, AccountId, CaseNumber, NumeroColeta__c,
                        (   SELECT id, idObjetoColeta__c, NumeroEtiqueta__c, UltimoStatusRastreamento__c
                            FROM ObjetosPostagemReversa__r
                        )
                FROM    Case 
                WHERE   Id =: idCaso
            ];

            // if(caso.ObjetosPostagemReversa__r.isEmpty()) {
            //     return 'Não há nenhum objeto de postagem reversa criado para este case. Solicite a Postagem Reversa dos Itens.';
            // }

            Map<String, ObjetoPostagemReversa__c> idObjetoColetaToObjetoPostagemReversa = new Map<String, ObjetoPostagemReversa__c>();

            for(ObjetoPostagemReversa__c objPostagemReversa : caso.ObjetosPostagemReversa__r) {
                if(String.isBlank(objPostagemReversa.NumeroEtiqueta__c)) {
                    idObjetoColetaToObjetoPostagemReversa.put(objPostagemReversa.idObjetoColeta__c, objPostagemReversa);
                }
            }

            System.debug('Número da Coleta ' + caso.NumeroColeta__c);

            logisticaReversaCorreios.logisticaReversaWSPort logistica = new logisticaReversaCorreios.logisticaReversaWSPort();            
            logisticaReversaCorreios.retornoAcompanhamento a = logistica.acompanharPedido(new List<String>{caso.NumeroColeta__c});   
            System.debug('A ' + a);
            System.debug('A ' + a.coleta[0].objeto);
            

            // caso.StatusRastreamento__c = a.coleta[0].objeto[0].descricao_status;

            for (logisticaReversaCorreios.objetoPostal objeto : a.coleta[0].objeto) {
                System.debug('OBJETO ' + objeto);
                System.debug('objeto.controle_objeto_cliente => ' + objeto.controle_objeto_cliente);
                System.debug('objeto.numero_etiqueta => ' + objeto.numero_etiqueta);
                if(idObjetoColetaToObjetoPostagemReversa.get(objeto.controle_objeto_cliente) != null) {
                    idObjetoColetaToObjetoPostagemReversa.get(objeto.controle_objeto_cliente).NumeroEtiqueta__c = objeto.numero_etiqueta;
                    idObjetoColetaToObjetoPostagemReversa.get(objeto.controle_objeto_cliente).UltimoStatusRastreamento__c = objeto.descricao_status;
                    String lastUpdateDate = objeto.data_ultima_atualizacao;
                    String formattedDate = lastUpdateDate.substring(0, 2) + '/' + lastUpdateDate.substring(3, 5) + '/' + lastUpdateDate.substring(6, 10);
                    idObjetoColetaToObjetoPostagemReversa.get(objeto.controle_objeto_cliente).DataUltimaAtualizacao__c = formattedDate;
                    idObjetoColetaToObjetoPostagemReversa.get(objeto.controle_objeto_cliente).HoraUltimaAtualizacao__c = objeto.hora_ultima_atualizacao;
                }
            }

            System.debug('idObjetoColetaToObjetoPostagemReversa.values => ' + JSON.serializePretty(idObjetoColetaToObjetoPostagemReversa.values()));

            update idObjetoColetaToObjetoPostagemReversa.values();

            update caso;

            return 'Sucesso. Os registros de Objeto Postagem Reversa estão com a última descrição de status e/ou com os devidos Códigos de Rastreio.';
        
        } catch (Exception e) {
            return 'Erro: ' + e.getMessage();
        }
    }
}