public with sharing class CaseTriggerHelper {

    public static void sendSurveyEmail(Map<Id, Case> oldRecordsMap, List<Case> records) {
        Set<Id> filteredCasesIds = new Set<Id>();
        
        for(Case caseRecord : records) {
            if(oldRecordsMap.get(caseRecord.id).isClosed != caseRecord.isClosed && caseRecord.isClosed) {
                filteredCasesIds.add(caseRecord.id);
            }
        }
        
        if(!filteredCasesIds.isEmpty()) {
            Map<Id, Case> filteredCases = new Map<Id, Case>([
                SELECT id, accountId, account.email__c, marca__r.supportEmail__c
                FROM Case
                WHERE id IN :filteredCasesIds
                AND id NOT IN (SELECT caso__c FROM Pesquisa_de_Satisfacao__c WHERE Caso__c IN :filteredCasesIds)
                AND account.email__c != null
                AND marca__r.supportEmail__c != null
            ]);

            List<String> supportEmails = new List<String>();
            List<Pesquisa_de_Satisfacao__c> surveyRecordsToInsert = new List<Pesquisa_de_Satisfacao__c>();

            for(Case caseRecord : filteredCases.values()) {
                Pesquisa_de_Satisfacao__c pesquisaSatisfacaoRecord = new Pesquisa_de_Satisfacao__c(
                    Conta__c = caseRecord.accountId,
                    Caso__c = caseRecord.id
                );

                surveyRecordsToInsert.add(pesquisaSatisfacaoRecord);
                supportEmails.add(caseRecord.marca__r.supportEmail__c);
            }

            if(!surveyRecordsToInsert.isEmpty()){
                insert surveyRecordsToInsert;
            }

            Set<Id> surveyRecordsIds = new Set<Id>();

            for(Pesquisa_de_Satisfacao__c surveyRecord : surveyRecordsToInsert){
                surveyRecordsIds.add(surveyRecord.id);
            }

            List<Pesquisa_de_Satisfacao__c> surveyRecords = [
                SELECT id, caso__c, caso__r.caseNumber, conta__c, conta__r.email__c, conta__r.name,
                caso__r.marca__r.businessName__c, caso__r.marca__r.supportEmail__c
                FROM Pesquisa_de_Satisfacao__c
                WHERE id IN :surveyRecordsIds
            ];

            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            
            Blob key;
            String publicSiteURL;
            if(!Test.isRunningTest()) {
                key = EncodingUtil.base64Decode([SELECT Id, key__c from Encryption__c LIMIT 1].key__c);
                publicSiteURL = [SELECT id, publicSiteURL__c FROM GeneralSettings__c LIMIT 1].publicSiteURL__c;
            } else {
                key = EncodingUtil.base64Decode('Z8FqwEUWZhcs3hZxzpfvZQ==');
                publicSiteURL = 'https://dev-infracommercebr.cs78.force.com';
            }

            EmailTemplate template;

            if(!Test.isRunningTest()) {
                template = [SELECT Id, HtmlValue FROM EmailTemplate WHERE developerName = 'PesquisaSatisfacao' LIMIT 1];
            } else {
                template = CaseTriggerHelperTest.getPesquisaSatisfacaoEmailTestTemplate();
            }

            Map<String, Id> brandSupportEmailToOrgWideEmailAddressId = new Map<String, Id>();

            for(OrgWideEmailAddress orgWideEmailAddress : [SELECT ID, IsAllowAllProfiles, DisplayName, Address FROM OrgWideEmailAddress WHERE address IN: supportEmails]) {
                brandSupportEmailToOrgWideEmailAddressId.put(orgWideEmailAddress.Address, orgWideEmailAddress.Id);
            }

            for(Pesquisa_de_Satisfacao__c surveyRecord : surveyRecords) {
                
                String encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(surveyRecord.id)));
                String encodedId = encodingUtil.URLEncode(encodedCipherText, 'UTF-8');

                String body = template.HtmlValue;
                body = body.replaceAll('<!\\[CDATA\\[', ''); // replace '<![CDATA['
                body = body.replaceAll('\\]\\]>', ''); // replace ']]'
                System.debug('body => ' + body);
                System.debug('body => ' + JSON.serializePretty(body));
                body = body.replace('{!NomeConta}', surveyRecord.conta__r.name);
                body = body.replace('{!NumeroCaso}', surveyRecord.caso__r.caseNumber);
                body = body.replace('{!NomeComercialMarca}', (surveyRecord.caso__r?.marca__r?.businessName__c == null? '-' : surveyRecord.caso__r?.marca__r?.businessName__c));
                body = body.replace('{!link}', '<a href="' + publicSiteURL + '/PesquisaSatisfacao?id=' + encodedId + '">Clique aqui para responder à pesquisa</a>');
                System.debug('body => ' + body);
                System.debug('body => ' + JSON.serializePretty(body));

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.toAddresses = new List<String>{surveyRecord.conta__r.email__c};
                email.subject = 'Pesquisa de Satisfação ' + surveyRecord.caso__r.caseNumber;
                email.setReplyTo(surveyRecord.caso__r.marca__r.supportEmail__c);
                email.setOrgWideEmailAddressId(brandSupportEmailToOrgWideEmailAddressId.get(surveyRecord.caso__r.marca__r.supportEmail__c));
                // email.setSenderDisplayName(surveyRecord.caso__r.marca__r.businessName__c);
                email.setHTMLBody(body);
                
                emailsToSend.add(email);
            }

            if(!emailsToSend.isEmpty()) {
                System.debug('Pre Email Send');
                Messaging.sendEmail(emailsToSend);
                System.debug('Email Sent Successfully.');
            }
        }
    }

    public static void fillProtocolType (List<Case> records) {
        for(Case caseObj : records) {
            if (caseObj.Reason__c == 'Cliente atesta não conformidade' || caseObj.Reason__c == 'Cliente não gostou do produto') {
                if (caseObj.Type == 'Atendimento sobre a Troca') {
                    caseObj.ProtocolType__c = 'exchange';
                } else if (caseObj.Type == 'Atendimento sobre a Devolução') {
                    caseObj.ProtocolType__c = 'return';
                }
            }
        }
    }

    public static void createNextTask(Map<Id, Case> oldRecordsMap, Map<Id, Case> newRecordsMap) {
        
        System.debug('createNextTask');

        Set<Id> filteredCaseIds = new Set<Id>();

        List<Task> tasksToUpsert = new List<Task>();
        List<Task> tasksToInsert = new List<Task>();
        List<Case> casesToSendExpiredTermEmail = new List<Case>();
        Set<Id> caseIdsToChangeOwner = new Set<Id>();
        Set<Id> brandIds = new Set<Id>();

        for(Id caseId : caseIdsToChangeOwner) {
            brandIds.add(newRecordsMap.get(caseId).marca__c);
        }

        Map<Id, Brand__c> idToBrand = new Map<Id, Brand__c>([SELECT id, QueueN2__c FROM Brand__c WHERE id IN: brandIds]);

        Map<Id, String> brandIdToQueueName = new Map<Id, String>();

        for(Brand__c brand : idToBrand.values()) {
            brandIdToQueueName.put(brand.Id, brand.QueueN2__c);
        }

        System.debug('brandIdToQueueName => ' + brandIdToQueueName.values());

        Map<String, Id> queueNameToGroupId = new Map<String, Id>();

        for(Group groupObj : [SELECT id, name FROM Group WHERE Type = 'Queue' AND name IN: brandIdToQueueName.values()]) {
            System.debug('groupObj => ' + groupObj);
            queueNameToGroupId.put(groupObj.Name, groupObj.Id);
        }

        for(Id caseId : caseIdsToChangeOwner) {
            System.debug('newRecordsMap.get(caseId).ownerId => ' + newRecordsMap.get(caseId).ownerId);
                newRecordsMap.get(caseId).ownerId = queueNameToGroupId.get(brandIdToQueueName.get(newRecordsMap.get(caseId).marca__c));
            System.debug('newRecordsMap.get(caseId).ownerId => ' + newRecordsMap.get(caseId).ownerId);
        }
        
        for(Case caseObj : newRecordsMap.values()) {
            if(caseObj.ReversaStatus__c != oldRecordsMap.get(caseObj.Id).ReversaStatus__c) {
                
                filteredCaseIds.add(caseObj.Id);

                Task newTask = new Task(
                    WhatId = caseObj.Id,
                    Status = 'Em andamento'
                );
                
                System.debug('caseObj.ReversaStatus__c => ' + caseObj.ReversaStatus__c);
                
                if(caseObj.ReversaStatus__c == 'Aguardando Objeto na Agência') {
                    newTask.Fila__c = 'Consumidor';
                    newTask.FilaSubtipo__c = 'Aguardando Postagem';
                    newTask.CaseOnHold__c = true;
                } else if(caseObj.ReversaStatus__c == 'Prazo de Utilização Expirado') {
                    // envio de email para o consumidor
                    casesToSendExpiredTermEmail.add(caseObj);
                    // newTask.Fila__c = 'Consumidor';
                    // newTask.FilaSubtipo__c = 'Aguardando Postagem';
                } else if(caseObj.ReversaStatus__c == 'Coletado') {
                    newTask.Fila__c = 'Transportes';
                    newTask.FilaSubtipo__c = 'Reversa Devolução';
                    newTask.CaseOnHold__c = true;
                } else if(caseObj.ReversaStatus__c == 'Entrega não realizada') {
                    newTask.Fila__c = 'SAC';
                    newTask.FilaSubtipo__c = 'Abertura de PI';
                    newTask.ReassignCase__c = true;
                    caseIdsToChangeOwner.add(caseObj.Id);
                } else if(caseObj.ReversaStatus__c == 'Aguardando Check-in Reversa') {
                    newTask.Fila__c = 'Logística';
                    newTask.FilaSubtipo__c = 'Aguardando check in reversa';
                    newTask.CaseOnHold__c = true;
                } else if(caseObj.ReversaStatus__c == 'Reversa Liberada') {
                    newTask.Fila__c = 'Financeiro Infra';
                    newTask.FilaSubtipo__c = 'Aguardando Reembolso';
                    newTask.ReassignCase__c = true;
                }

                tasksToInsert.add(newTask);
            }
        }

        List<Task> tasksToClose = [SELECT Id, Status, WhatId FROM Task WHERE WhatId IN: filteredCaseIds AND status = 'Em andamento' ORDER BY createdDate DESC];

        System.debug('casesToSendExpiredTermEmail => ' + casesToSendExpiredTermEmail);
        
        if(!casesToSendExpiredTermEmail.isEmpty()) {
            sendCorreiosExpiredTermEmail(casesToSendExpiredTermEmail);
        }

        Set<Id> mostRecentTaskFoundCaseId = new Set<Id>();

        for(Task task : tasksToClose) {
            if(!mostRecentTaskFoundCaseId.contains(task.WhatId)) {
                
                task.Status = 'Completed';
                
                mostRecentTaskFoundCaseId.add(task.WhatId);
                tasksToUpsert.add(task);
            }
        }

        System.debug('tasksToUpsert => ' + tasksToUpsert.size());
        System.debug('tasksToUpsert => ' + JSON.serializePretty(tasksToUpsert));

        tasksToUpsert.addAll(tasksToInsert);

        System.debug('tasksToUpsert => ' + tasksToUpsert.size());
        System.debug('tasksToUpsert => ' + JSON.serializePretty(tasksToUpsert));

        upsert tasksToUpsert;
    }

    public static void sendCorreiosExpiredTermEmail(List<Case> casesToSendEmail) {
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        EmailTemplate template;

        if(!Test.isRunningTest()) {
            template = [SELECT Id, HtmlValue FROM EmailTemplate WHERE developerName = 'Item_nao_chegou_Devolucao_Troca' LIMIT 1];
        } else {
            template = CaseTriggerHelperTest.getPesquisaSatisfacaoEmailTestTemplate();
        }

        Set<Id> ownerIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Set<Id> brandIds = new Set<Id>();

        for(Case caseObj : casesToSendEmail) {
            ownerIds.add(caseObj.ownerId);
            accountIds.add(caseObj.accountId);
            orderIds.add(caseObj.Order__c);
            brandIds.add(caseObj.marca__c);
        }

        Map<Id, User> idToUser = new Map<Id, User>([
            SELECT id, name
            FROM User
            WHERE id IN :ownerIds
        ]);

        Map<Id, Account> idToAccount = new Map<Id, Account>([
            SELECT id, name, email__c
            FROM Account
            WHERE id IN :accountIds
        ]);

        Map<Id, Order> idToOrder = new Map<Id, Order>([
            SELECT id, NumeroPedidoCliente__c
            FROM Order
            WHERE id IN: orderIds
        ]);

        Map<Id, Brand__c> idToBrand = new Map<Id, Brand__c>([
            SELECT id, BusinessName__c, Phone__c, SupportEmail__c
            FROM Brand__c
            WHERE id IN : brandIds
        ]);

        List<String> supportEmails = new List<String>();

        for(Brand__c brand : idToBrand.values()) {
            supportEmails.add(brand.supportEmail__c);
        }

        Map<String, Id> brandSupportEmailToOrgWideEmailAddressId = new Map<String, Id>();

        for(OrgWideEmailAddress orgWideEmailAddress : [SELECT ID, IsAllowAllProfiles, DisplayName, Address FROM OrgWideEmailAddress WHERE address IN: supportEmails]) {
            brandSupportEmailToOrgWideEmailAddressId.put(orgWideEmailAddress.Address, orgWideEmailAddress.Id);
        }

        for(Case caseObj : casesToSendEmail) {

            String body = template.HtmlValue;
            body = body.replaceAll('<!\\[CDATA\\[', ''); // replace '<![CDATA['
            body = body.replaceAll('\\]\\]>', ''); // replace ']]'
            body = body.replace('{!Account.Name}', idToAccount.get(caseObj.accountId)?.name);
            body = body.replace('{!Order.NumeroPedidoCliente__c}', idToOrder.get(caseObj.Order__c)?.NumeroPedidoCliente__c);
            body = body.replace('{!Brand__c.BusinessName__c}', (idToBrand.get(caseObj.marca__c)?.businessName__c == null? '-' : idToBrand.get(caseObj.marca__c)?.businessName__c));
            body = body.replace('{!Brand__c.Phone__c}', (idToBrand.get(caseObj.marca__c)?.Phone__c == null? '-' : idToBrand.get(caseObj.marca__c)?.Phone__c));
            body = body.replace('{!Case.OwnerFirstName}', idToUser.get(caseObj.ownerId)?.name == null? '-' : idToUser.get(caseObj.ownerId)?.name);

            System.debug('body => ' + body);
            System.debug('body => ' + JSON.serializePretty(body));

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.toAddresses = new List<String>{idToAccount.get(caseObj.accountId)?.email__c};
            email.subject = 'Produto não foi postado - ' + caseObj.caseNumber;
            email.setReplyTo(idToBrand.get(caseObj.marca__c)?.supportEmail__c);
            email.setOrgWideEmailAddressId(brandSupportEmailToOrgWideEmailAddressId.get(idToBrand.get(caseObj.marca__c)?.supportEmail__c));
            email.setHTMLBody(body);

            System.debug('email => ' + email);
            
            emailsToSend.add(email);
        }

        System.debug('emailsToSend => ' + emailsToSend);

        if(!emailsToSend.isEmpty()) {
            System.debug('Pre Expired Term Email Send');
            Messaging.sendEmail(emailsToSend);
            System.debug('Expired Term Email Sent Successfully.');
        }

        List<Case> casesToClose = new List<Case>();

        for(Case caseObj : casesToSendEmail) {
            Case caseToClose = new Case(
                id = caseObj.Id,
                status = 'Closed'
            );
            casesToClose.add(caseToClose);
        }

        if(!casesToClose.isEmpty()) {
            CaseTriggerHandler.disableTrigger();
                update casesToClose;
            CaseTriggerHandler.enableTrigger();
        }

    }

    public static void changeReassignCaseFieldValue(Map<Id, Case> oldRecordsMap, List<Case> newRecords) {

        List<Case> casesToUpdate = new List<Case>();

        AssignmentRule assignmentRule = [SELECT id FROM AssignmentRule WHERE SObjectType = 'Case' AND Active = true LIMIT 1];

        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = assignmentRule.id;
        
        System.debug('changeReassignCaseFieldValue');
        for(Case caseObj : newRecords) {
            System.debug('caseObj.ReassignCase__c => ' + caseObj.ReassignCase__c);
            System.debug('oldRecordsMap.get(caseObj.Id).ReassignCase__c => ' + oldRecordsMap.get(caseObj.Id).ReassignCase__c);
            if(caseObj.ReassignCase__c && oldRecordsMap.get(caseObj.Id).ReassignCase__c != caseObj.ReassignCase__c) {
                
                System.debug('caseObj.ReassignCase__c => ' + caseObj.ReassignCase__c);
                
                Case caseToUpdate = new Case(
                    Id = caseObj.Id, 
                    ReassignCase__c = false
                );
                caseToUpdate.setOptions(dmlOpts);

                casesToUpdate.add(caseToUpdate);
            }
        }

        if(!casesToUpdate.isEmpty()) {
            CaseTriggerHandler.disableTrigger();
                update casesToUpdate;
            CaseTriggerHandler.enableTrigger();
        }
    }

    public static void createTaskToIntegrationRuptureCase(List<Case> records) {
        List<Case> caseToUpdate = new List<Case>();
        List<Task> taskToInsert = new List<Task>();

        for(Case caseObj : records) {
            if (caseObj.Subject  == 'Ruptura de Pedido' && caseObj.ExternalCaseId__c  != null) {
                System.debug('caseObj if ' + caseObj);

                // Order order = [SELECT id, Brand__c/*, Account.Name, Account.Email__c, Account.Phone*/ 
                //                 FROM Order 
                //                 WHERE Id =: caseObj.Order__c
                // ];

                Case newCase = new Case(
                    Id              = caseObj.Id,
                    Type            = 'Atendimento Sobre o Pedido',
                    Reason__c       = 'Status da entrega-CD',
                    SubReason__c    = 'Ruptura',
                    Origin          = 'Logistica'
                    // Marca__c        = caseObj.Marca__c == null ? order.Brand__c : caseObj.Marca__c
                    // SuppliedEmail   = caseObj.SuppliedEmail == null ? Account.Email__c : caseObj.SuppliedEmail,
                    // SuppliedName    = caseObj.SuppliedName == null ? Account.Name : caseObj.SuppliedName
                );

                Task newTask = new Task(
                    WhatId          = caseObj.Id,
                    Description     = caseObj.Description,
                    Fila__c         = 'SAC',
                    FilaSubtipo__c  = 'Comunicar ruptura/Falta estoque',
                    ReassignCase__c = true
                );
                caseToUpdate.add(newCase);
                taskToInsert.add(newTask);

            }
        }
        update caseToUpdate;
        insert taskToInsert;
    }

}