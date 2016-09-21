# Introduction to Apex Testing - Dreamforce 2016

Presented by [Laura Meerkatz](https://github.com/lmeerkatz) and [Adam Lincoln](https://github.com/adamlincoln), developers at [Salesforce.org](http://developer.salesforce.org/#team)

This readme provides resources related to that session. This repository should also contain everything you need to deploy this code to a dev org.

## Why we write tests
Short answer? Because we like to sleep at night. 

Longer answer:
* During development, tests show us where our architectural plan may be wrong.
* At initial release, tests give us proof that our new code does what we want.
* When we update existing code, tests give us confidence that changes to our code do not break existing functionality.
* Test runs during deployment warn us that new code is trying to break existing code (and prevents that code from deploying).
* Running tests in production can tell us when a configuration change has broken our code.

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
</code></pre>


## Best Practices

### Create your own data
By default, your tests don't have access to data in your org. That's a good thing! 
* Isolating makes writing assertions easier. (You can do things like query for a count of all records and know that you're only getting back results you created in your test.)
* It prevents row-lock errors. (If your tests are updating a record from your real dataset and a real user tries to update that record at the same time, your user can get locked out of making changes.)

You can override that behavior by adding the ([SeeAllData=true] (https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_seealldata_using.htm)) annotation to your test class or method. There are a few cases where this is necessary, but as a general rule you should avoid it. 

*Note: There are a few objects like User that are available to tests regardless of whether SeeAllData is set. Changes made to these records in tests are not persisted outside of tests.

### Use test data factories

A [test data factory](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_utility_classes.htm) is a [class](/blob/master/src/classes/TestData.cls) that makes it easy to create several records quickly, so you don't have to spend as much time setting up data for your tests.

<pre><code>
@isTest 
public class TestData {
    public static List<Account> createAccounts(Integer count) {
		List<Account> accts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            // at a minimum, add enough data to pass validation rules
            accts.add(new Account(
                Name = 'Test Account ' + i
            ));
        }
        return accts;
    }
    
    public static List<Contact> createContacts(Account acct, Integer count) {
        List<Contact> cons = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            cons.add(new Contact(
                AccountId = acct.Id,
            	FirstName = 'Joe',
            	LastName = 'McTest ' + i
            ));
        }
        return cons;
    }
    ...
}
</code></pre>

You can also store test data as a static resource in a .csv file and load the records using [Test.loadData()](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_load_data.htm).

### Use @TestSetup to create data for your test class in one step
You can have a single method in each test class annotated with [@TestSetup](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_testsetup.htm?search_text=testsetup). This method will run once before any test methods run, and at the end of each test the data will be rolled back to its state before the test. Using @TestSetup makes writing your tests faster and it makes them run faster.

<pre><code>
    @TestSetup 
    static void setup(){
        Account testAccount = TestData.createAccounts(1)[0];
        testAccount.Name = 'Apex Testing DF16 Co.';
        insert testAccount;
    }
</code></pre>

### Use System.runAs() to test user access

In a test, you can execute specific blocks of code as a certain user, which means that you can use tests to verify that a user can do the things they should be able to do, and can't do the things they should be blocked from doing. 

<code><pre>
@isTest 
static void testPrivilegedUser(){
	Boolean exceptionCaught;
	System.runAs(TestData.adminUser){
		try {
			SomeClass.doDangerousOperation();
		} catch(Exception e) {
			exceptionCaught = true;
		}
	}
	System.assertEquals(false, exceptionCaught, 'Admin should be able to execute doDangerousOperation');
}
</pre></code>

<code><pre>
@isTest 
static void testLimitedUser(){
	Boolean exceptionCaught;
	System.runAs(TestData.standardUser){
		try {
			SomeClass.doDangerousOperation();
		} catch(Exception e) {
			exceptionCaught = true;
		}
	}
	System.assertEquals(true, exceptionCaught, 'Standard user should NOT be able to execute doDangerousOperation');
}
</pre></code>

## Special Cases

### Visualforce Controllers and Extensions
You can and should test the logic behind your Visualforce pages. Any action that is called from your controller can be tested in an Apex test. Actions in the page UI itself (including anything involving JavaScript) can be covered in end-to-end tests, but that is outside of Apex testing (and not covered here). 

Here's how to set up a test for a custom controller:
<pre><code>
// set the current page
PageReference pageRef = Page.EmployeeBonuses;
Test.setCurrentPage(pageRef);

// set up the controller
EmployeeBonusController ctrl = new EmployeeBonusController();

// call method(s) in the controller
ctrl.doInit();

// check the resulting data by referencing the property in the class
List<EmployeeBonusExtension.Employee> employees = ctrl.employees;    

// assert expectations 
System.assertEquals(2, ctrl.employees.size(), 'The list should have two employees');
System.assertEquals(0, ApexPages.getMessages().size(), 'There should be no error messages on the page');
</code></pre>

Extensions are exactly the same, with an additional step to set up the standard controller and pass it to the extension:
<pre><code>
// set the current page
PageReference pageRef = Page.EmployeeBonuses;
Test.setCurrentPage(pageRef);

// set up the standard controller    
ApexPages.StandardController standardCtrl = new ApexPages.StandardController(new Opportunity());

// set up the extension, referencing the standard controller
EmployeeBonusExtension extension = new EmployeeBonusExtension(standardCtrl);

// call method(s) in the extension
extension.doInit();

// check the resulting data by referencing the property in the class
List<EmployeeBonusExtension.Employee> employees = extension.employees;    

// assert expectations 
System.assertEquals(2, extension.employees.size(), 'The list should have two employees');
System.assertEquals(0, ApexPages.getMessages().size(), 'There should be no error messages on the page');
</code></pre>

You can see a [full code sample](/blob/master/src/classes/EmployeeBonusExtensionTest.cls) here.

### Lightning Component Controllers
Lightning Component controllers are similar, but because all @AuraEnabled methods are static, you don't have to initialize the controller class. You also don't check for error messages from the controller because all error handling for Lightning Components is done on the client side.

<pre><code>
// call the @AuraEnabled method
List&lt;User&gt; employees = EmployeeBonusController.getEmployeeList();

// assert that you get the expected results
System.assertEquals(2, employees.size(), 'The list should have two employees');
</code></pre>

You can see a [full code sample](/blob/master/src/classes/EmployeeBonusControllerTest.cls) here.
