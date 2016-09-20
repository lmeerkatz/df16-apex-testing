@isTest
public class EmployeeBonusCompareTest {
    @TestSetup
    static void setup() {
        User testUser = TestData.standardUser;
        Account acct = TestData.createAccounts(1)[0];
        insert acct;
        
        List<Opportunity> testOpps = TestData.createOpportunities(acct, 1);
        testOpps[0].StageName = 'Closed Won';
        testOpps[0].Amount = 10000;
        testOpps[0].OwnerId = testUser.Id;
        insert testOpps;
    }

    @isTest
    static void willNotWaitForQueueable() {
        // Note that test data isolation does not apply to some special setup objects!
        User testUser = TestData.standardUser;

        Id qJobId = System.enqueueJob(new EmployeeBonusCompare(
            testUser.Id
        ));

        // Requery to get newly computed Bonus_Compared_to_Industry__c value
        testUser = [SELECT Bonus_Compared_to_Industry__c FROM User WHERE Id = :testUser.Id];

        // This fails because Queueable Apex is not synchronous!
        System.assertNotEquals(null, testUser.Bonus_Compared_to_Industry__c);
    }

    @isTest
    static void queueableWillRunButCalloutIsNotAllowed() {
        // Note that test data isolation does not apply to some special setup objects!
        User testUser = TestData.standardUser;

        Test.startTest();
        Id qJobId = System.enqueueJob(new EmployeeBonusCompare(
            testUser.Id
        ));
        Test.stopTest();

        // Requery to get newly computed Bonus_Compared_to_Industry__c value
        testUser = [SELECT Bonus_Compared_to_Industry__c FROM User WHERE Id = :testUser.Id];

        // This fails because Queueable Apex is not synchronous!
        System.assertNotEquals(null, testUser.Bonus_Compared_to_Industry__c);
    }

    @isTest
    static void finallyAGoodTest() {
        Test.setMock(HttpCalloutMock.class, new EmployeeBonusCompareMock());

        User testUser = TestData.standardUser;

        Test.startTest();
        Id qJobId = System.enqueueJob(new EmployeeBonusCompare(
            testUser.Id
        ));
        // All asynchronous work takes place here
        Test.stopTest();

        // Requery to get newly computed Bonus_Compared_to_Industry__c value
        testUser = [SELECT Bonus_Compared_to_Industry__c FROM User WHERE Id = :testUser.Id];

        System.assertNotEquals(null, testUser.Bonus_Compared_to_Industry__c);
    }
}