import { LightningElement, wire, api, track  } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getCaseBrandData from '@salesforce/apex/CustomLookupController.getCaseBrandData'; 

export default class InventoryQueryLWC extends NavigationMixin(LightningElement)  {
    @api recordId;
    @track brandObject;
    @track disabledNext = true;
    @track disableBrandPicklist;
    @track brandId;
    @track showSpinner;
    
    
    orderItemSkus;
    activeTab;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;

        if (currentPageReference.state) {
            this.activeTab = currentPageReference.state.c__activeTab;
            console.log("this.activeTab", this.activeTab);
        }
    }

    connectedCallback() {
        if(this.recordId.startsWith('500')) {
            this.showSpinner = true;
            this.brandObject = getCaseBrandData({ caseId: this.recordId })
                .then(result => {
                    console.log('getCaseBrandData deu certo');
                    if(result != null) {
                        let parsedResult   = JSON.parse(result);
                        this.brandObject   = parsedResult.brandData;
                        this.brandId       = parsedResult.brandData.id;
                        this.orderItemSkus = parsedResult.orderData.orderItemSkus;
                        this.disabledNext = false;
                        this.disableBrandPicklist = true;
                    }
                    this.showSpinner = false;
                });
        }
    }

    handleSelectBrandObj(event) {
        console.log('handleSelectBrandObj');
        this.disabledNext = false;
        const { record } = event.detail;
        this.brandId = record.id;
    }

    handleNavigate(event) {
        console.log('handleNavigate');
        console.log('brandId => ' + this.brandId);

        var compDefinition = {
            componentDef: "c:inventoryProductsView",
            title: "Adicionar produtos",
            attributes: {
                recordId: this.recordId,
                brandId: this.brandId,
                productsSkuList: this.orderItemSkus
            }
        }

        try{
            const filterChangeEvent = new CustomEvent('displaymyvaluenew', {
                detail: { "data" : JSON.stringify(compDefinition) }
            });
            // Fire the custom event
            this.dispatchEvent(filterChangeEvent);
        }catch(e){
            debugger;
            console.log(e);

        }

        // // Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     title: 'Adicionar produtos',
        //     c__activeTab: this.activeTab,
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef,
        //         title: 'Adicionar produtos'
        //     }
        // });
    }
}