global class BatchIntegrationOrderOUT implements Database.Batchable<SObject>, Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id From Pricebook2 WHERE isStandard = false LIMIT 1';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext info, List<SObject> records) {
        List<Order> listBatchOrder = [SELECT Id FROM Order];

        List<Order> listOrderOUT = new List<Order>();

        for (Order batchOrder : listBatchOrder) {
            if (batchOrder.OkForSending__c == true && batchOrder.Sended__c == false) {
                listOrderOUT.add(batchOrder);
            }
        }

        //IntegrationOrderOUT.sendOrderOUT(listOrderOUT);
    }

    public void finish(Database.BatchableContext info){

    }
}