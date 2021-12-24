global with sharing class CaseNotificationBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Set<Id> supervisorToBeNotifiedIds = new Set<Id>();
    global Set<Id> managersToBeNotifiedIds = new Set<Id>();

    global CaseNotificationBatch (Set<Id> supervisorToNotifyIds, Set<Id> managerToNotifyIds) {
        this.supervisorToBeNotifiedIds = supervisorToNotifyIds;
        this.managersToBeNotifiedIds = managerToNotifyIds;

        System.debug('supervisorToBeNotifiedIds => ' + JSON.serializePretty(this.supervisorToBeNotifiedIds));
        System.debug('managersToBeNotifiedIds => ' + JSON.serializePretty(this.managersToBeNotifiedIds));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        Set<Id> supervisorToBeNotifiedIdsAux = this.supervisorToBeNotifiedIds;
        Set<Id> managersToBeNotifiedIdsAux = this.managersToBeNotifiedIds;
        
        String query = 'SELECT id, name, email ' +
        'FROM User ' +
        'WHERE id IN :supervisorToBeNotifiedIdsAux OR id IN :managersToBeNotifiedIdsAux';

        System.debug('query => ' + query.substringAfter('WHERE'));

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User> scope) {

        System.debug('scope => ' + JSON.serializePretty(scope));
        
        Map<Id, User> userIdToUser = new Map<Id, User>(scope);

        Map<Id, User> usersMap = new Map<Id, User>([
            SELECT id, managerId, manager.managerId
            FROM User
            WHERE managerId IN :supervisorToBeNotifiedIds
            OR manager.managerId IN :managersToBeNotifiedIds
        ]);

        System.debug('usersMap => ' + JSON.serializePretty(usersMap));

        List<Case> violatedCases = [
            SELECT id, caseNumber, subject, account.Name, taskQueueName__c, ownerId, owner.name
            FROM Case
            WHERE ownerId IN :usersMap.keySet()
            AND id IN (SELECT caseId FROM CaseMilestone WHERE isViolated = true)
        ];

        System.debug('violatedCases => ' + JSON.serializePretty(violatedCases));

        Map<Id, List<Case>> supervisorIdToViolatedCases = new Map<Id, List<Case>>();
        Map<Id, List<Case>> managerIdToViolatedCases = new Map<Id, List<Case>>();

        for(Case caseObj : violatedCases) {
            User userAux = usersMap.get(caseObj.ownerId);

            if(userAux.managerId != null){
                if(!supervisorIdToViolatedCases.containsKey(userAux.managerId)){
                    supervisorIdToViolatedCases.put(userAux.managerId, new List<Case>());
                }

                supervisorIdToViolatedCases.get(userAux.managerId).add(caseObj);
            }

            if(userAux.manager?.managerId != null){
                if(!managerIdToViolatedCases.containsKey(userAux.manager.managerId)){
                    managerIdToViolatedCases.put(userAux.manager.managerId, new List<Case>());
                }

                managerIdToViolatedCases.get(userAux.manager.managerId).add(caseObj);
            }
        }

        System.debug('supervisorIdToViolatedCases => ' + JSON.serializePretty(supervisorIdToViolatedCases));
        System.debug('managerIdToViolatedCases => ' + JSON.serializePretty(managerIdToViolatedCases));
        
        Map<String, EmailTemplate> templateMap = new Map<String, EmailTemplate>();
        for(EmailTemplate template : [SELECT id, name, developerName, htmlValue FROM EmailTemplate WHERE developerName = 'Caso_SLA_Violado' OR developerName = 'Lista_Caso_SLA_Violado']) {
            templateMap.put(template.developerName, template);
        }

        EmailTemplate template;
        EmailTemplate listCaseTemplate;
        
        if(Test.isRunningTest()) {
            template = ViolatedCasesFilteringBatchTest.getViolatedCasesEmailTestTemplate();
            listCaseTemplate = ViolatedCasesFilteringBatchTest.getViolatedCasesEmailTestTemplate();
        } else {
            template = templateMap.get('Caso_SLA_Violado');
            listCaseTemplate = templateMap.get('Lista_Caso_SLA_Violado');
        }
        
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();

        for(Id supervisorId : supervisorIdToViolatedCases.keySet()) {

            String body = template.HtmlValue;
            body = body.replaceAll('<!\\[CDATA\\[', ''); // replace '<![CDATA['
            body = body.replaceAll('\\]\\]>', ''); // replace ']]'

            Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
            mailMessage.toAddresses = new List<String>{userIdToUser.get(supervisorId).email};
            mailMessage.subject = 'Casos com SLA Violado';

            String caseListToReplace = '';
            
            body = body.replace('{!UserName}', userIdToUser.get(supervisorId).name);
            for(Case caseObj : supervisorIdToViolatedCases.get(supervisorId)){
                String listCaseTemplateHTMLValue = listCaseTemplate.htmlValue.substringBetween('{!BetweenTag}');
                
                String caseUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + caseObj.Id;
                listCaseTemplateHTMLValue = listCaseTemplateHTMLValue.replace('{!Case.Account}', caseObj.account?.name == null? '-' : caseObj.account?.name);
                listCaseTemplateHTMLValue = listCaseTemplateHTMLValue.replace('{!Case.CaseNumber}', caseObj.caseNumber == null? '-' : caseObj.caseNumber);
                listCaseTemplateHTMLValue = listCaseTemplateHTMLValue.replace('{!Case.Subject}', caseObj.subject == null? '-' : caseObj.subject);
                listCaseTemplateHTMLValue = listCaseTemplateHTMLValue.replace('{!Case.TaskQueueName__c}', caseObj.taskQueueName__c == null? '-' : caseObj.taskQueueName__c);
                listCaseTemplateHTMLValue = listCaseTemplateHTMLValue.replace('{!Case.OwnerName}', caseObj.owner?.name == null? '-' : caseObj.owner.name);
                listCaseTemplateHTMLValue = listCaseTemplateHTMLValue.replace('{!Case.Link}', caseUrl);

                caseListToReplace += listCaseTemplateHTMLValue;
            }

            System.debug('caseListToReplace => ' + JSON.serializePretty(caseListToReplace));

            body = body.replace('{!CaseList}', caseListToReplace);

            System.debug('body => ' + body);
            System.debug('body => ' + JSON.serializePretty(body));
            mailMessage.setHTMLBody(body);

            System.debug('mailMessage => ' + JSON.serializePretty(mailMessage));
            emailMessageList.add(mailMessage);
        }

        for(Id managerId : managerIdToViolatedCases.keySet()) {

            String body = template.HtmlValue;
            body = body.replaceAll('<!\\[CDATA\\[', ''); // replace '<![CDATA['
            body = body.replaceAll('\\]\\]>', ''); // replace ']]'
            
            Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
            mailMessage.toAddresses = new List<String>{userIdToUser.get(managerId).email};
            mailMessage.subject = 'Casos com SLA Violado';

            String caseListToReplace = listCaseTemplate.htmlValue.substringBetween('{!BetweenTag}');

            body = body.replace('{!UserName}', userIdToUser.get(managerId).name);

            for(Case caseObj : managerIdToViolatedCases.get(managerId)){
                String caseUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + caseObj.Id;

                caseListToReplace = caseListToReplace.replace('{!Case.Account}', caseObj.account?.name == null? '-' : caseObj.account?.name);
                caseListToReplace = caseListToReplace.replace('{!Case.CaseNumber}', caseObj.caseNumber == null? '-' : caseObj.caseNumber);
                caseListToReplace = caseListToReplace.replace('{!Case.Subject}', caseObj.subject == null? '-' : caseObj.subject);
                caseListToReplace = caseListToReplace.replace('{!Case.TaskQueueName__c}', caseObj.taskQueueName__c == null? '-' : caseObj.taskQueueName__c);
                caseListToReplace = caseListToReplace.replace('{!Case.OwnerName}', caseObj.owner?.name == null? '-' : caseObj.owner.name);
                caseListToReplace = caseListToReplace.replace('{!Case.Link}', caseUrl);
            }

            System.debug('caseListToReplace => ' + JSON.serializePretty(caseListToReplace));

            body = body.replace('{!CaseList}', caseListToReplace);

            System.debug('body => ' + body);
            System.debug('body => ' + JSON.serializePretty(body));
            mailMessage.setHTMLBody(body);

            System.debug('mailMessage => ' + JSON.serializePretty(mailMessage));
            emailMessageList.add(mailMessage);
        }

        System.debug('emailMessageList => ' + JSON.serializePretty(emailMessageList));

        if(!emailMessageList.isEmpty()) {
            System.debug('Pre Email Send');
            Messaging.sendEmail(emailMessageList);
            System.debug('Email Sent Successfully.');
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}