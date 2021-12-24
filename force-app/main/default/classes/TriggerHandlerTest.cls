@isTest
private class TriggerHandlerTest {
    
    @isTest
    static void testVirtualMethods() {
        TriggerHandler h = new TriggerHandler(null, null, null, null, null);
        h.beforeInsert();
        h.beforeUpdate();
        h.beforeDelete();
        h.afterInsert();
        h.afterUpdate();
        h.afterDelete();
    }
}