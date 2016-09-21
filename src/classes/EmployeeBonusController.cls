public class EmployeeBonusController {

    @AuraEnabled
    public static Object getEmployeeList() {
        System.debug('UserInfo.getUserName(): ' + UserInfo.getUserName()); 
        System.debug('Schema.sObjectType.User.fields.Bonus__c.isAccessible(): ' + Schema.sObjectType.User.fields.Bonus__c.isAccessible()); 
        List<EmployeeBonusController.Employee> employees;
        if (Schema.sObjectType.User.fields.Bonus__c.isAccessible()) {
            List<AggregateResult> results = [ SELECT OwnerId, SUM(Amount) total FROM Opportunity 
                                      	WHERE CloseDate = THIS_YEAR AND 
                                      	IsWon = true
                                      	GROUP BY OwnerId ];
    	    
            Map<Id, User> employeeUsers = new Map<Id, User>([
                SELECT Id, Name, Bonus__c FROM User WHERE Id IN 
                	(SELECT OwnerId FROM Opportunity WHERE CloseDate = THIS_YEAR AND IsWon = true)
            ]);
            
            employees = new List<Employee>();        
            
            for (AggregateResult result : results) {
    			Employee emp = new Employee();
                emp.Id = (Id)result.get('OwnerId');
                emp.name = employeeUsers.get(emp.Id).Name;
                emp.bonus = employeeUsers.get(emp.Id).Bonus__c;
                emp.totalClosedOpps = (Decimal)result.get('total');
                employees.add(emp);
            }
        } else {
            throw new AuraHandledException('You don\'t have access to view bonus information.');
        }
        String serialized = JSON.serialize(employees);
        Object deserialized = JSON.deserializeUntyped(serialized);
        return deserialized;
    } 
    
    public class Employee {
        public Id id { get; private set; }
        public String name { get; private set; }
        public Decimal totalClosedOpps { get; private set; }
        public Decimal bonus { get; private set; }
    }
}