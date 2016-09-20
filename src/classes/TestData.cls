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
    
    public static List<Opportunity> createOpportunities(Account acct, Integer count){
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < count; i++) {
            opps.add(new Opportunity(
                AccountId = acct.Id,
            	Amount = 10000,
            	StageName = 'Closed Won',
                CloseDate = System.today(),
                Name = acct.Name + ' Opportunity ' + i
            ));
        }
        return opps;
    }
    
    public static User standardUser {
        get {
            if (standardUser == null) {
                List<User> standardUsers = 
                    [SELECT Id, Username FROM User WHERE Username = 'standarduser@df16apextests.com'];
                if (standardUsers.size() > 0) {
                    standardUser = standardUsers[0];
                } else {
                    Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
                    standardUser = new User(
                        Alias = 'person',
                        Email = 'standarduser@test.com',
                        Username = 'standarduser@df16apextests.com',
                        EmailEncodingKey = 'UTF-8',
                        FirstName = 'Standard',
                        LastName = 'Test User',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        ProfileId = profileId,
                        TimeZoneSidKey = 'America/Los_Angeles'
                    );
                    System.runAs(adminUser) {
                        insert standardUser;
                    }
                }
            }
            return standardUser;
        }
        set;
    }
    
    public static User adminUser {
        get {
            if (adminUser == null) {
                adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
            }
            return adminUser;
        }
        set;
    }
}