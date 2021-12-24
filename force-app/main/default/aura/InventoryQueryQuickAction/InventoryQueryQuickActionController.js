({
    init : function (component, event, helper) {
        console.log('Entrou no INIT');
        console.log(component);
        console.log("Method Entry: InventoryQueryQuickActionController.js");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:InventoryQueryAuraCmp",
            componentAttributes: {
                recordId: component.get("v.recordId"),
                isEdit: false,
                isBudget: true
            }
        });
        evt.fire();
    }
})