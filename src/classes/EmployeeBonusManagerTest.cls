@isTest
private class EmployeeBonusManagerTest {

    @TestSetup 
    static void setup(){
        Account testAccount = TestData.createAccounts(1)[0];
        testAccount.Name = 'Apex Testing DF16 Co.';
        insert testAccount;
    }
    
    private static Account testAccount {
        get {
            if (testAccount == null) {
                testAccount = [ SELECT Id, Name FROM Account WHERE Name = 'Apex Testing DF16 Co.' LIMIT 1];
            }
            return testAccount;
        }
        set;
    }
    
    // test employee with some open opps and some closed opps
    // they should get a bonus
    @isTest 
    static void testAwardBonus() {
    	// set up data
        User employee = TestData.standardUser;
		
        List<Opportunity> opps = TestData.createOpportunities(testAccount, 3);
    	opps[0].Amount = 1000;
    	opps[0].StageName = 'Closed Won';
    	
	    opps[1].Amount = 10000;
    	opps[1].StageName = 'Prospecting';
    
	    opps[2].Amount = 100000;
    	opps[2].StageName = 'Closed Won';
    
        insert opps;

       	// execute the logic we're testing
		EmployeeBonusManager.updateEmployeeBonuses(employee.Id);
        
        // query for updated record
        employee = queryForUser(employee.Id);
        
        // assert expected results
        System.assertEquals(1010, employee.Bonus__c, 'Employee has have bonus for $101,000 in opps');
    }
    
    // test employee who should get the maximum bonus
    static void testAwardMaximumBonus() {
    	// set up data
        User employee = TestData.standardUser;
		
        List<Opportunity> opps = TestData.createOpportunities(testAccount, 1);
    	opps[0].Amount = 60000000;
    	opps[0].StageName = 'Closed Won';
    
        insert opps;

       	// execute the logic we're testing
		EmployeeBonusManager.updateEmployeeBonuses(employee.Id);
        
        // query for updated record
        employee = queryForUser(employee.Id);
        
        // assert expected results
        System.assertEquals(25000, employee.Bonus__c, 'Employee should be awarded the maximum bonus');
    }

    // test employee with no opps
    // they shouldn't get a bonus
    @isTest 
    static void testNoBonusNoOpps(){
        // set up data
        User employee = TestData.standardUser;

       	// execute the logic we're testing
		EmployeeBonusManager.updateEmployeeBonuses(employee.Id);
        
        // query for updated record
        employee = queryForUser(employee.Id);
        
        // assert expected results
        System.assertEquals(null, employee.Bonus__c, 'Employee has no opportunities and should have no bonus');
    }
    
    // test employee bonus with several opps
    @isTest 
    static void testBonusBulk(){
        // set up data
        User employee = TestData.standardUser;
		
        List<Opportunity> opps = TestData.createOpportunities(testAccount, 200);
        for (Opportunity opp : opps) {
			opp.Amount = 10000;
    		opp.StageName = 'Closed Won';
        }
        insert opps;

       	// execute the logic we're testing
		EmployeeBonusManager.updateEmployeeBonuses(employee.Id);
        
        // query for updated record
        employee = queryForUser(employee.Id);
        
        // assert expected results
        System.assertEquals(25000, employee.Bonus__c, 'Employee should be awarded the maximum bonus');
    }
    
	// test employee with only open opps
	// they shouldn't get a bonus
    @isTest 
    static void testNoBonusOnlyOpenOpps(){
        // set up data
        User employee = TestData.standardUser;
		
        List<Opportunity> opps = TestData.createOpportunities(testAccount, 3);
        for (Opportunity opp : opps) {
            opp.StageName = 'Prospecting';
        }
        insert opps;

       	// execute the logic we're testing
		EmployeeBonusManager.updateEmployeeBonuses(employee.Id);
        
        // query for updated record
        employee = queryForUser(employee.Id);
        
        // assert expected results
        System.assertEquals(null, employee.Bonus__c, 'Employee has only open opportunities and should have no bonus');
    }
    
	// test negative total opp amount
	// this should throw an exception
	@isTest 
    static void testNegativeOppTotal(){
        // set up data
        User employee = TestData.standardUser;
        List<Opportunity> opps = TestData.createOpportunities(testAccount, 3);
        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Won';
            opp.Amount = -5;
        }
        insert opps;
        
       	Boolean exceptionThrown = false;
        
        try {
            // execute the logic we're testing
            EmployeeBonusManager.updateEmployeeBonuses(employee.Id);
        } catch (Exception ex) {
            exceptionThrown = true;
            System.assert(ex instanceOf EmployeeBonusManager.BonusException, 'Thrown exception should be a Bonus Exception');
        }
                
        // assert expected results
        System.assert(exceptionThrown, 'An exception should have been thrown');
    }
	
    private static User queryForUser(Id userId) {
        return [SELECT Id, Bonus__c FROM User WHERE Id = :userId];
    }
}