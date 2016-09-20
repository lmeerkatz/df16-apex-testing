@isTest
private class EmployeeBonusExtensionTest {
    @TestSetup 
    static void setupData() {
        Account acct = TestData.createAccounts(1)[0];
        insert acct;
        
        List<Opportunity> testOpps = TestData.createOpportunities(acct, 4);
        
        testOpps[0].OwnerId = TestData.adminUser.Id;
        testOpps[0].StageName = 'Closed Won';
        testOpps[0].Amount = 10000;
        // total for admin user = 10000
        
        testOpps[1].OwnerId = TestData.standardUser.Id;
        testOpps[1].StageName = 'Closed Won';
        testOpps[1].Amount = 20000;
        
        testOpps[2].OwnerId = TestData.standardUser.Id;
        testOpps[2].StageName = 'Closed Won';
        testOpps[2].Amount = 5000;
        
        testOpps[3].OwnerId = TestData.standardUser.Id;
        testOpps[3].StageName = 'Prospecting';
        testOpps[3].Amount = 10000;
        // total for standard user is 25000
        
        insert testOpps;
        
        // update user bonuses
        Set<Id> employeeIds = new Set<Id>();
        employeeIds.add(TestData.standardUser.Id);
        employeeIds.add(TestData.adminUser.Id);
        EmployeeBonusManager.updateEmployeeBonuses(employeeIds);
    }
    
    // test view page as admin
    // user should be able to see data
    @isTest
    static void testViewPageAsAdmin() {
        EmployeeBonusExtension extension;
        
        System.runAs(TestData.adminUser) {
            // set up page
            PageReference pageRef = Page.EmployeeBonuses;
            Test.setCurrentPage(pageRef);
    
            ApexPages.StandardController standardCtrl = new ApexPages.StandardController(new Opportunity());
            extension = new EmployeeBonusExtension(standardCtrl);
            
            // check the data on the page
            List<EmployeeBonusExtension.Employee> employees = extension.employees;    
        }
        
        System.assertEquals(2, extension.employees.size(), 'The list should have two employees');
        Integer checkedEmployees = 0;
        
        for (EmployeeBonusExtension.Employee employee : extension.employees) {
            if (employee.Id == TestData.standardUser.Id) {
                System.assertEquals('Standard Test User', employee.name);
                System.assertEquals(25000, employee.totalClosedOpps);
                System.assertEquals(250, employee.bonus);
                checkedEmployees++;
            } else if (employee.Id == TestData.adminUser.Id) {
                System.assertEquals(10000, employee.totalClosedOpps);
                System.assertEquals(100, employee.bonus);
                checkedEmployees++;
            }
        }
        System.assertEquals(2, checkedEmployees, 'Both employees should have been checked');
        
        // check for error messages
        System.assertEquals(0, ApexPages.getMessages().size(), 'There should be no error messages on the page');
    }
    
    // test view page as standard user
    // user should not have access to this data
    @isTest
    static void testViewPageAsStandardUser() {
        EmployeeBonusExtension extension;
        
        System.runAs(TestData.standardUser) {
            // set up page
            PageReference pageRef = Page.EmployeeBonuses;
            Test.setCurrentPage(pageRef);
    
            ApexPages.StandardController standardCtrl = new ApexPages.StandardController(new Opportunity());
            extension = new EmployeeBonusExtension(standardCtrl);
            
            // check the data on the page
            List<EmployeeBonusExtension.Employee> employees = extension.employees;    
        }
        
        System.assertEquals(0, extension.employees.size(), 'This user should not have access to employee bonus data');
        
        // check for error messages
        System.assertEquals(1, ApexPages.getMessages().size(), 'There should be an error message on the page');
        System.assert(ApexPages.getMessages()[0].getDetail().contains('You don\'t have permission to view bonus information'));
    }
}