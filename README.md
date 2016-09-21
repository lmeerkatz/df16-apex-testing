# Introduction to Apex Testing - Dreamforce 2016

Presented by [Laura Meerkatz](https://github.com/lmeerkatz) and [Adam Lincoln](https://github.com/adamlincoln), developers at [Salesforce.org](http://developer.salesforce.org/#team)

This readme provides resources related to that session. This repository should also contain everything you need to deploy this code to a dev org.

## Testing Basics
### Test Class Structure

[Sample Test Class](/blob/master/src/classes/SampleTest.cls)

<pre><code>@isTest
private class SampleTest {
    @TestSetup 
    static void setup(){
        // insert sample data that you want for all test methods here
    }
    
    // use comments to describe the scenario you're testing
    @isTest
    static void testSomething(){
        // set up test data for this scenario
        
        // execute the logic you're testing
        
        // query for the updated record(s)
        
        // assert expected results
    }
}</code></pre>

## What to Test
* Positive tests (things that should happen do happen)
* Negative tests (things that shouldn't happen don't happen)
* Exception tests (exceptions we're expecting are thrown as expected)
* Bulk tests (everything still works when we're dealing with lots of records)

### Sample Scenario

We have code to [calculate employee bonuses](/blob/master/src/classes/EmployeeBonusManager.cls). Employees should earn a 1% bonus for all Closed Won opportunities this year. The maximum bonus is $25,000. If an employees total opp amount is negative, an exception is thrown.

**What should we test?**

*Things that should happen:*
- Employees with closed won opportunities should get a bonus based on the amount
- Employees with lots of closed won opps should receive the maximum bonus

*Things that shouldn't happen:*
- Employees who don't have closed opps should not get a bonus
- Open opps shouldn't count toward the bonus amount

*Exception testing:*
- A negative total opp amount should result in an exception

*Bulk testing:*
- Calculate bonus for an employee with 200 closed opps

Here's what that looks like ([full code](/blob/master/src/classes/EmployeeBonusManagerTest.cls)):

*Employees with closed won opportunities should get a bonus based on the amount*
<pre><code>
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
</code></pre>

*Employees with lots of closed won opps should receive the maximum bonus*
<pre><code>
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
</code></pre>

*Employees who don't have closed opps should not get a bonus*
<pre><code>
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
</code></pre>

*Open opps shouldn't count toward the bonus amount*
<pre><code>
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
</code></pre>

*A negative total opp amount should result in an exception*
<pre><code>
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
</code></pre>

*Calculate bonus for an employee with 200 closed opps*
<pre><code>
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
</pre></code>




