global class BatchReclameAqui implements Database.Batchable<SObject>, Database.AllowsCallouts{
    public BatchReclameAqui() {}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id From Pricebook2 WHERE isStandard = false LIMIT 1';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext info, List<SObject> records){

        TemplateDataIntegrationFields.ReclameAquiRetriveAllTicketINData tickets = IntegrationReclameAqui.retrieveAllTickets();
         
        System.debug('TICKETS DATA' + JSON.serializePretty(tickets.data));

        Set<String> externalIdsCpf  = new Set<String>();
        Set<String> externalIdsCnpj = new Set<String>();
        List<TemplateDataIntegrationFields.ReclameAquiTicketINData> listaTickets = new List<TemplateDataIntegrationFields.ReclameAquiTicketINData>();

        for (TemplateDataIntegrationFields.ReclameAquiTicketINData itens : tickets.data){
            System.debug('1ºFOR');
            if (itens.customer.cpf.size() > 0) {
                System.debug('1º IF CPF');
                for (String cpf : itens.customer.cpf) {
                    externalIdsCpf.add(cpf);
                }
            }
            if (itens.customer.cnpj.size() > 0) {
                System.debug('1º IF CNPJ');
                for (String cnpj : itens.customer.cnpj) {
                    externalIdsCnpj.add(cnpj);
                }
            }
            listaTickets.add(itens);
        }
        List<Account> accs = [SELECT Id, ExternalId__c 
                            FROM Account 
                            WHERE ExternalId__c IN :externalIdsCpf 
                            OR ExternalId__c IN :externalIdsCnpj];

        Map<String,Account> mapAcc = new Map<String,Account>();
        for (Account itensAcc : accs) {
            System.debug('VERIFICA SE EXISTE CONTAS');
            mapAcc.put(itensAcc.ExternalId__c, itensAcc);
        }

        System.debug('Contas ' + accs);
        List<Account> listaNovasContas = new List<Account>();
        for (TemplateDataIntegrationFields.ReclameAquiTicketINData itens : tickets.data) {
            System.debug('FOR CRIA CONTA ');
            Boolean contaExiste = false;
            if (itens.customer.cpf.size() > 0) {
                if (mapAcc.containsKey(itens.customer.cpf[0])) {
                    contaExiste = true;
                }
            } 
            if (!contaExiste) {
                if (itens.customer.cnpj.size() > 0) {
                    if (mapAcc.containsKey(itens.customer.cnpj[0])) {
                        contaExiste = true;
                    }
                }
            }
            if (!contaExiste) {
                Account newAcc = new Account();
                newAcc.Name = itens.customer.name;
                if (itens.customer.cpf.size() > 0) {
                    newAcc.CPF__c        = itens.customer.cpf[0];
                    newAcc.ExternalId__c = itens.customer.cpf[0];
                }
                if (itens.customer.cnpj.size() > 0) {
                    newAcc.CNPJ__c       = itens.customer.cnpj[0];
                    if (String.isBlank(newAcc.ExternalId__c)) {
                        newAcc.ExternalId__c = itens.customer.cnpj[0];
                    }
                }
                listaNovasContas.add(newAcc);
                mapAcc.put(newAcc.ExternalId__c, newAcc);
            }
        }
        
        if (listaNovasContas.size() > 0) {
            System.debug('CRIOU CONTA');
            Database.insert(listaNovasContas, false);
            for (Account itensAcc : listaNovasContas) {
                mapAcc.put(itensAcc.ExternalId__c, itensAcc);
            }
        }
        List<Case> listaCasosNovos = new List<Case>();
        for (TemplateDataIntegrationFields.ReclameAquiTicketINData itens : tickets.data) {
            System.debug('FOR CRIA CASE');
            Case newCase = new Case();
            newCase.Status        = 'Novo';
            newCase.Origin        = 'ReclameAqui';
            newCase.Subject       = itens.complaint_title;
            newCase.Description   = itens.complaint_content;
            if (mapAcc.containsKey(itens.customer.cpf[0])) {
                newCase.AccountId = mapAcc.get(itens.customer.cpf[0]).Id;
            } else {
                if (mapAcc.containsKey(itens.customer.cnpj[0])) {
                    newCase.AccountId = mapAcc.get(itens.customer.cnpj[0]).Id;
                }
            }
            listaCasosNovos.add(newCase);
        }
        if (listaCasosNovos.size() > 0) {
            System.debug('CRIOU CASE');
            Database.insert(listaCasosNovos, false);
        }
    }


    public void finish(Database.BatchableContext info){

    }
}