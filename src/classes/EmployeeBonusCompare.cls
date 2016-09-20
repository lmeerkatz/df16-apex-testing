public class EmployeeBonusCompare implements Queueable, Database.AllowsCallouts {
    Id userId = null;

    public EmployeeBonusCompare(Id userId) {
        this.userId = userId;
    }

    public void execute(QueueableContext qc) {
        if (userId != null) {
            List<User> employees = [SELECT Id, Bonus__c FROM User WHERE Id = :userId];

            if (employees.size() == 1) {
                User employee = employees.get(0);

                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(Callout_Endpoints__c.getOrgDefaults().Bonus_Compare_Endpoint__c + '/' + employee.Bonus__c);
                req.setMethod('GET');

                HttpResponse resp = h.send(req);

                Map<String, Object> respPayload = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());

                employee.Bonus_Compared_to_Industry__c = 0.01 - (Decimal)respPayload.get('industry_average');
                update employee;
            }
        }
    }
}