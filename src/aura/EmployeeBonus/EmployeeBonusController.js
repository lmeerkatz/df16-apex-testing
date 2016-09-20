({
	doInit : function(component, event, helper) {
		var action = component.get("c.getEmployeeList");
        action.setCallback(this, function(response) {
            component.set("v.employees", response.getReturnValue());
        });
        $A.enqueueAction(action);
	}
})