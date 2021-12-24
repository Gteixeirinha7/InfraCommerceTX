({
    init : function(component, event, helper) {
        console.log("init 2");
        console.log(component.get("v.recordId"));
        console.log(component.get("v.isCreateOrderFromBudget"));
        component.set("v.isCreateOrderFromBudget", true);
        window.setTimeout(function(){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "Gerar pedido"
                });            
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "action:adjust_value",
                    iconAlt: "Tela Especial"
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }, 1000);
    },
    handleCloseClicked: function(component, event) {
        console.log('Fechando orçamento!');
        component.set('v.message', 'Close Clicked');

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        })
            .catch(function (error) {
                console.log(error);
            });
    }
})