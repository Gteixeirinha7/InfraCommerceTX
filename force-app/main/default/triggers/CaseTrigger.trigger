trigger CaseTrigger on Case (before insert, after insert, after update) {

    CaseTriggerHandler handler = new CaseTriggerHandler(
        Trigger.operationType,
        Trigger.new, 
        Trigger.old,
        Trigger.newMap, 
        Trigger.oldMap
    );

    if (CaseTriggerHandler.isTriggerEnabled())
        handler.execute();
}