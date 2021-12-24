@IsTest
public with sharing class ScheduleCaseNotificationBatchTest {
    
    public static testMethod void testschedule() {
		Test.StartTest();
            ScheduleCaseNotificationBatch testsche = new ScheduleCaseNotificationBatch();
            ScheduleCaseNotificationBatch.scheduleBatch();
            String sch = '0 0 23 * * ?';
            system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
}