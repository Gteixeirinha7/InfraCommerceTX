public inherited sharing class SolicitarPostagemReversaLWCController {

    @AuraEnabled(Cacheable = true)
    public static List<OrderItemModel> getOrderItems(String caseId) {

        System.debug('caseId => ' + caseId);

        String orderId = [SELECT order__c FROM Case WHERE id =: caseId LIMIT 1].order__c;
        
        Map<Id, OrderItem> orderItems = new Map<Id, OrderItem>([SELECT id, product2.name, unitPrice, quantity, totalPrice, sku__c FROM OrderItem WHERE OrderId =: orderId]);

        List<OrderItemModel> result = new List<OrderItemModel>();

        Set<Id> orderItemsWithPostalObjectCreated = new Set<Id>();

        for(ObjetoPostagemReversa__c postalObject : [SELECT id, orderItem__c FROM ObjetoPostagemReversa__c WHERE orderItem__c IN :orderItems.keySet() AND caso__r.status != 'Closed']) {
            orderItemsWithPostalObjectCreated.add(postalObject.orderItem__c);
        }

        for(OrderItem orderItem : orderItems.values()) {
            if(!orderItemsWithPostalObjectCreated.contains(orderItem.id)) {
                result.add(new OrderItemModel(orderItem));
            }
        }

        System.debug('result => ' + JSON.serializePretty(result));

        return result;
    }

    @AuraEnabled
    public static Response createReversePost(String caseId, String orderItemIdsJSON){

        try {

            Type idArrType = Type.forName('List<string>');
            List<string> orderItemIds = (List<string>) JSON.deserialize(orderItemIdsJSON, idArrType);

            System.debug('caseId => ' + caseId);
            System.debug('orderItemIds => ' + orderItemIds);

            Case caseObj = [SELECT id, accountId, order__c, numeroColeta__c, ProtocolType__c FROM Case WHERE id = :caseId LIMIT 1];

            if(!String.isBlank(caseObj.numeroColeta__c)) {
                return new Response('Já existe uma coleta aberta para este caso.', true, null);
            }

            Account account = [
                SELECT id, phone, email__c, externalId__c, 
                (
                    SELECT  city__c, complement__c, country__c, neighborhood__c, 
                            number__c, postalCode__c, receiverName__c, street__c, 
                            state__c
                    FROM AccountAddress__r
                ) 
                FROM Account
                WHERE id = :caseObj.accountId
                LIMIT 1
            ];

            Order order = [
                SELECT id, numeroPedidoERP__c, brand__r.name, CentrodeDistribuicao__r.name, 
                endereco__r.city__c, endereco__r.complement__c, endereco__r.country__c, endereco__r.neighborhood__c, 
                endereco__r.number__c, endereco__r.postalCode__c, endereco__r.receiverName__c, endereco__r.street__c, endereco__r.state__c,
                centrodeDistribuicao__c, centrodeDistribuicao__r.bairroReversa__c, centrodeDistribuicao__r.cepReversa__c, 
                centrodeDistribuicao__r.cidadeReversa__c, centrodeDistribuicao__r.complementoReversa__c, centrodeDistribuicao__r.enderecoReversa__c, 
                centrodeDistribuicao__r.logradouroReversa__c, centrodeDistribuicao__r.numeroReversa__c, centrodeDistribuicao__r.ufReversa__c
                FROM Order
                WHERE id = :caseObj.order__c
            ];

            Centro_de_Distribuicao__c cdOrder = order.centrodeDistribuicao__r;

            Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem>([SELECT id, totalPrice FROM OrderItem WHERE id IN : orderItemIds]);

            Map<String, ObjetoPostagemReversa__c> idObjetoColetaToObjPostagemReversa = new Map<String, ObjetoPostagemReversa__c>();

            List<logisticaReversaCorreios.objeto> objList = new List<logisticaReversaCorreios.objeto>();

            Double totalItemsValue = 0;
            
            for(Integer i = 0; i < orderItemMap.keySet().size(); i++) {

                OrderItem currentOrderItem = orderItemMap.values().get(i);
                totalItemsValue += currentOrderItem.totalPrice;

                ObjetoPostagemReversa__c objPostagemReversa = new ObjetoPostagemReversa__c();
                objPostagemReversa.orderItem__c = currentOrderItem.id;
                
                String idObjetoColeta = String.valueOf(System.currentTimeMillis()) + i;
                objPostagemReversa.idObjetoColeta__c = idObjetoColeta;
                objPostagemReversa.caso__c = caseId;

                idObjetoColetaToObjPostagemReversa.put(idObjetoColeta, objPostagemReversa);

                logisticaReversaCorreios.objeto obj_col = new logisticaReversaCorreios.objeto();
                obj_col.item = '1';
                obj_col.id = idObjetoColeta;

                objList.add(obj_col);
            }

            System.debug('idObjetoColetaToObjPostagemReversa => ' + JSON.serializePretty(idObjetoColetaToObjPostagemReversa));

            logisticaReversaCorreios.pessoa destinatario = new logisticaReversaCorreios.pessoa();
            destinatario.nome = order.brand__r.name + '-' + order.CentrodeDistribuicao__r.name; // 'Joao'; // nome marca + nome cd
            
            // informações virão do centro de distribuição
            destinatario.logradouro = cdOrder.logradouroReversa__c;
            destinatario.numero = cdOrder.numeroReversa__c;
            destinatario.complemento = cdOrder.complementoReversa__c;
            destinatario.bairro = cdOrder.bairroReversa__c;
            destinatario.cidade = cdOrder.cidadeReversa__c;
            destinatario.uf = cdOrder.ufReversa__c;
            destinatario.cep = cdOrder.cepReversa__c.replaceAll('[^0-9]+', '');
            destinatario.ddd = '61';
            destinatario.telefone = '34261111';
            destinatario.email = 'joao';
            destinatario.ciencia_conteudo_proibido = 'N';
            
            // verificar de onde vem os dados de remetente
            logisticaReversaCorreios.remetente remetente = new logisticaReversaCorreios.remetente();
            Address__c receiverAddress = order.endereco__r;
            remetente.nome = receiverAddress.receiverName__c;
            remetente.logradouro = receiverAddress.street__c;
            remetente.numero = receiverAddress.number__c;
            remetente.complemento = receiverAddress.complement__c;
            remetente.bairro = receiverAddress.neighborhood__c;
            remetente.cidade = receiverAddress.city__c;
            remetente.uf = receiverAddress.state__c;
            remetente.cep = receiverAddress.postalCode__c.replaceAll('[^0-9]+', '');
            remetente.referencia = '';
            remetente.identificacao = account.externalId__c;
            String telefone = account.phone.replaceAll('\\+55', '');
            remetente.ddd_celular = telefone.substring(0, 2);
            remetente.celular = telefone.substring(2, telefone.length());
            remetente.sms = 'S';
            remetente.restricao_anac = 'S';
            
            String id_cliente = order.numeroPedidoERP__c; // String.valueOf(System.currentTimeMillis()); // numero pedido ERP (WEB-43891048)
            
            logisticaReversaCorreios.coletaReversa coletaReversa = new logisticaReversaCorreios.coletaReversa();

            System.debug('Antes: ' + String.valueOf(totalItemsValue));

            totalItemsValue = totalItemsValue > 21 ? totalItemsValue : 21.1;

            System.debug('Depois: ' + String.valueOf(totalItemsValue));

            coletaReversa.tipo = 'A';
            coletaReversa.id_cliente = id_cliente;
            coletaReversa.valor_declarado = String.valueOf(totalItemsValue); // String.valueOf(order.orderTotals__c);
            coletaReversa.remetente = remetente;
            coletaReversa.obj_col = objList;

            logisticaReversaCorreios.logisticaReversaWSPort l = new logisticaReversaCorreios.logisticaReversaWSPort();
            logisticaReversaCorreios.retornoPostagem retornoPostagem = l.solicitarPostagemReversa(destinatario, new List<logisticaReversaCorreios.coletaReversa>{coletaReversa});

            if(!String.isBlank(retornoPostagem.msg_erro) || retornoPostagem.cod_erro != '00') {
                String erro = String.isBlank(retornoPostagem.msg_erro)? retornoPostagem.resultado_solicitacao[0].descricao_erro : retornoPostagem.msg_erro;
                return new Response('Falha na Solicitação: ' + erro, true, null);
            }
            
            caseObj.idClientePostagemReversa__c = id_cliente;
            caseObj.numeroColeta__c = retornoPostagem.resultado_solicitacao[0].numero_coleta;
            caseObj.ReversaStatus__c = 'Aguardando Objeto na Agência';

            update caseObj;

            insert idObjetoColetaToObjPostagemReversa.values();

            if(caseObj.ProtocolType__c == 'return') {
                IntegrationCaseOUT.sendCaseOUTFuture(caseObj.Id);
            }

            return new Response('Sucesso! Registros de Objetos de Postagem Reversa gerados.', false, null);

        } catch (Exception e) {
            return new Response('Falha de Execução: ' + e.getMessage(), true, e.getStackTraceString());
        }
    }

    public class OrderItemModel {
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String price;
        @AuraEnabled
        public String sku;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String quantity;

        public OrderItemModel(OrderItem orderItem) {
            this.id          = orderItem.id;
            this.quantity    = String.valueOf(orderItem.quantity);
            this.productName = orderItem.product2.name;
            this.sku         = orderItem.sku__c;
            this.price       = String.valueOf(orderItem.unitPrice);
        }
    }
    
    public class Response {
        @AuraEnabled public String message;
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String stackTrace;

        public Response(String message, Boolean isError, String stackTrace) {
            this.message     = message;
            this.isError     = isError;
            this.stackTrace  = stackTrace;
        }
    }
}