({
    init : function(component, event, helper) {
        console.log("init 2");
        console.log(component.get("v.recordId"));
        window.setTimeout(function(){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "Consulta de Estoque"
                });            
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "standard:fulfillment_order",
                    iconAlt: "Consultar Estoque"
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }, 1000);
    },
    
    handleBrandSelection: function(component, event) {
        debugger;
        try {
            var data = JSON.parse(event.getParam('data'));
            component.set("v.recordId", (data.attributes.recordId));
            if(data.attributes.brandId != undefined && data.attributes.brandId != null) {
                component.set("v.brandId", (data.attributes.brandId));
            }
            if(data.attributes.productsSkuList != undefined && data.attributes.productsSkuList != null) {
                component.set("v.productsSkuList", (data.attributes.productsSkuList));
            }
            component.set("v.headerLayout", false);
            component.set("v.navigateToProductView", true);
        } catch (e) {
            debugger;
            console.log(e);
        }
    },

    navigateToOrder: function(component, event) {
        debugger;
        try {
            var data = JSON.parse(event.getParam('data'));
            component.set("v.recordId", (data.attributes.recordId));
            component.set("v.itemsList", (data.attributes.itemsList));
            component.set("v.productsSkuToContinue", (data.attributes.productsSkuToContinue));
            component.set("v.headerLayout", false);
            component.set("v.navigateToProductView", false);
            component.set("v.navigateToOrderView", true);
            window.setTimeout(function(){
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Gerar Pedido"
                    });            
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "action:adjust_value",
                        iconAlt: "Geração de Pedido"
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            }, 1000);
        } catch (e) {
            debugger;
            console.log(e);
        }
    },

    navigateToOrderProducts: function(component, event) {
        debugger;
        try {
            var data = JSON.parse(event.getParam('data'));
            component.set("v.recordId", (data.attributes.recordId));
            if(data.attributes.itemsList != undefined && data.attributes.itemsList != null) {
                component.set("v.itemsList", (data.attributes.itemsList));
            }
            component.set("v.valorTotal", (data.attributes.valorTotal));
            component.set("v.headerLayout", false);
            component.set("v.navigateToProductView", false);
            component.set("v.navigateToOrderView", false);
            component.set("v.navigateToOrderProductsView", true);
        } catch (e) {
            debugger;
            console.log(e);
        }
    }, 

    navigateToLogisticInfo: function(component, event) {
        debugger;
        try {
            var data = JSON.parse(event.getParam('data'));
            component.set("v.recordId", (data.attributes.recordId));
            component.set("v.valorTotal", (data.attributes.valorTotal));
            component.set("v.listSelected", (data.attributes.itemSelecionados));
            component.set("v.headerLayout", false);
            component.set("v.navigateToProductView", false);
            component.set("v.navigateToOrderView", false);
            component.set("v.navigateToOrderProductsView", false);
            component.set("v.navigateToLogisticInfoView", true);
        } catch (e) {
            debugger;
            console.log(e);
        }
    }
})