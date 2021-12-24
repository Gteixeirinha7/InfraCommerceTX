global with sharing class ViolatedCasesFilteringBatch implements Database.Batchable<SObject>, Database.Stateful {

    Set<Id> supervisorToBeNotifiedIds = new Set<Id>();
    Set<Id> managersToBeNotifiedIds = new Set<Id>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT id, ownerId, (SELECT id, createdDate, isViolated FROM CaseMilestones ORDER BY startDate DESC) ' +
        'FROM Case ' +
        'WHERE id IN (SELECT caseId FROM CaseMilestone WHERE isViolated = true AND isCompleted = false) ' +
        'AND status != \'Closed\'';

        System.debug('query => ' + query.substringAfter('WHERE'));

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        
        Set<Id> ownerIds = new Set<Id>();

        System.debug('scope => ' + JSON.serializePretty(scope));

        for(Case caseObj : scope) {
            if(caseObj.ownerId != null && caseObj.caseMilestones[0].isViolated) {
                ownerIds.add(caseObj.ownerId);
            }
        }

        System.debug('ownerIds => ' + JSON.serializePretty(ownerIds));

        List<User> users = [SELECT managerId, manager.ManagerId FROM User WHERE id IN : ownerIds];

        System.debug('users => ' + JSON.serializePretty(users));
        
        for(User userObj : users) {
            if(userObj.managerId != null) {
                supervisorToBeNotifiedIds.add(userObj.managerId);
            }

            if(userObj.manager?.managerId != null) {
                managersToBeNotifiedIds.add(userObj.manager.managerId);
            }
        }

        System.debug('supervisorToBeNotifiedIds => ' + JSON.serializePretty(supervisorToBeNotifiedIds));
        System.debug('managersToBeNotifiedIds => ' + JSON.serializePretty(managersToBeNotifiedIds));
    }

    global void finish(Database.BatchableContext BC) {
        Id batchJobId = Database.executeBatch(new CaseNotificationBatch(supervisorToBeNotifiedIds, managersToBeNotifiedIds), 200);
    }
}