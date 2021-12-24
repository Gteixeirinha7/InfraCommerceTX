({
    init: function (component, event, helper) {
        console.log('Entrou no INIT');
        console.log(component);
        console.log("Method Entry: CreateQuoteQuickActionController.js");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:CloneOrderAuraCmp",
            componentAttributes: {
                recordId: component.get("v.recordId"),
                isCreateOrderFromBudget : true,
                fromBudgetisEdit: true
            }
        });
        evt.fire();
    }
})