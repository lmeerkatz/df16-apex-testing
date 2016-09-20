public class EmployeeBonusExtension {
    public List<Employee> employees { get; private set; }
    
    public EmployeeBonusExtension(ApexPages.StandardController stdController) {
        employees = new List<Employee>();
        
        // in a real scenario we'd check more than just one field
        if (!Schema.sObjectType.User.fields.Bonus__c.isAccessible()) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You don\'t have permission to view bonus information'));
        } else {
            initEmployeeList();            
        }
    }
    
    public void initEmployeeList() {
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
    } 
    
    public class Employee {
        public Id id { get; private set; }
        public String name { get; private set; }
        public Decimal totalClosedOpps { get; private set; }
        public Decimal bonus { get; private set; }
    }
}