@IsTest
global class SolicitarCodigoRastreioMock implements WebServiceMock {

    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType
    ) {

        logisticaReversaCorreios.objetoPostal objetoPostal = new logisticaReversaCorreios.objetoPostal();
        objetoPostal.numero_etiqueta         = '21382174081BR';
        objetoPostal.controle_objeto_cliente = '553379';
        objetoPostal.ultimo_status           = '55';
        objetoPostal.descricao_status        = 'Aguardando Objeto na Agência';
        objetoPostal.data_ultima_atualizacao = '09-09-2021';
        objetoPostal.hora_ultima_atualizacao = '12:11:34';
        
        logisticaReversaCorreios.coletasSolicitadas coletasSolicitadas = new logisticaReversaCorreios.coletasSolicitadas();
        coletasSolicitadas.numero_pedido    = Long.valueOf('32147810');
        coletasSolicitadas.controle_cliente = 'WEB-230814743108';
        coletasSolicitadas.objeto           = new List<logisticaReversaCorreios.objetoPostal>{objetoPostal};
        
        
        logisticaReversaCorreios.retornoAcompanhamento retornoAcompanhamento = new logisticaReversaCorreios.retornoAcompanhamento();
        retornoAcompanhamento.codigo_administrativo = '04871350';
        retornoAcompanhamento.tipo_solicitacao = 'A';
        retornoAcompanhamento.coleta = new List<logisticaReversaCorreios.coletasSolicitadas>{coletasSolicitadas};
        
        logisticaReversaCorreios.acompanharPedidoResponse responseObject = new logisticaReversaCorreios.acompanharPedidoResponse();
        responseObject.acompanharPedido = retornoAcompanhamento;
        response.put('response_x', responseObject);  
    }
}