public class EmployeeBonusManager {
    public static void updateEmployeeBonuses(Set<Id> employeeIds){        
        List<AggregateResult> results = [ SELECT OwnerId, SUM(Amount) total FROM Opportunity 
                                  	WHERE CloseDate = THIS_YEAR AND 
                                  	IsWon = true
                                  	GROUP BY OwnerId ];

        List<User> employees = new List<User>();
        Decimal total;
        
        for (AggregateResult result : results) {
            total = (Decimal)result.get('total');
            if (total < 0) {
                throw new BonusException('Total opp amount can\'t be less than zero');
            }
       		employees.add(new User(
            	Id = (Id)result.get('OwnerId'),
                Bonus__c = calculateBonus(total)
            ));
        }
        update employees;
    }
    
    public static void updateEmployeeBonuses(Id employeeId){
        Set<Id> employeeIds = new Set<Id>();
        employeeIds.add(employeeId);
        updateEmployeeBonuses(employeeIds);
    }
    
    @TestVisible
    private static Decimal calculateBonus(Decimal oppAmount) {
        // employees get 1% bonus for closed opps
        // maximum bonus amount is $25,000
        Decimal bonus = oppAmount / 100;
        if (bonus > 25000) {
            bonus = 25000;
        }
        return bonus;
    }
    
    public class BonusException extends Exception {}
}