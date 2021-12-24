public with sharing class CaseTriggerHandler extends TriggerHandler {

    public CaseTriggerHandler(System.TriggerOperation operation, List<Case> newRecordList, List<Case> oldRecordList, Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        super(operation, newRecordList, oldRecordList, newMap, oldMap);
    }

    private static Boolean runTrigger;

    static {
        runTrigger = true;
    }

    public static Boolean isTriggerEnabled(){
        return runTrigger;
    }

    public static Boolean enableTrigger(){
        return runTrigger = true;
    }

    public static Boolean disableTrigger(){
        return runTrigger = false;
    }

    public override void beforeInsert() {
        CaseTriggerHelper.fillProtocolType(newRecordList);
    }

    public override void afterInsert() {
        CaseTriggerHelper.createTaskToIntegrationRuptureCase(newRecordList);
    }
    
    public override void afterUpdate() {
        CaseTriggerHelper.sendSurveyEmail((Map<Id, Case>) oldMap, newRecordList);
        CaseTriggerHelper.createNextTask((Map<Id, Case>) oldMap, (Map<Id, Case>) newMap);
        CaseTriggerHelper.changeReassignCaseFieldValue((Map<Id, Case>) oldMap, newRecordList);
    }
}