@IsTest
public class TAG_DeleteReportingDataSchedulerTest {
    @isTest
    static void execute_schedulesWithoutError() {
        Test.startTest();
        TAG_DeleteReportingDataScheduler scheduler = new TAG_DeleteReportingDataScheduler();
        String cronExp = '0 0 2 * * ?';
        System.schedule('Test Delete ReportingData', cronExp, scheduler);
        Test.stopTest();

        System.assert(true, 'Scheduler should execute without errors');
    }
}
