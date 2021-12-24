global class ScheduleCaseNotificationBatch implements Schedulable {

    public static void scheduleBatch() {
        ScheduleCaseNotificationBatch schedulableClass = new ScheduleCaseNotificationBatch();
        String sch = '0 0 9,12,15,18 ? * MON,TUE,WED,THU,FRI *';
        String jobId = System.schedule('ViolatedCasesFilteringBatchSchedule', sch, schedulableClass);
    }

    global void execute(SchedulableContext sc) {
        ViolatedCasesFilteringBatch batch = new ViolatedCasesFilteringBatch();
        Database.executeBatch(batch, 200);
    }
}