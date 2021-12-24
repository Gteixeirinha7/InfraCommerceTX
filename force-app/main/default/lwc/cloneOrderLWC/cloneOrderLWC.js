import { LightningElement, wire, track, api }    from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import cloneOrder                                from '@salesforce/apex/CloneOrderController.cloneOrder';
import cloneAddress                              from '@salesforce/apex/CloneOrderController.cloneAddress';  
import cloneCD                                   from '@salesforce/apex/CloneOrderController.cloneCD';
import clonePricebook                            from '@salesforce/apex/CloneOrderController.clonePricebook';
import totalPriceOrderItems                      from '@salesforce/apex/CloneOrderController.totalPriceOrderItems';

export default class CloneOrderLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @api itemsList           = [];
    @api productsSkuList     = [];

    @track valorTotal         = '';
    @track pedido             = {};
    @track endereco           = {};
    @track centroDistribuicao = {};
    @track pricebook          = {};

    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //     if (currentPageReference) {
    //         this.recordId = currentPageReference.state.recordId;
    //     }
    // }

    connectedCallback(){
        cloneOrder({idCaso: this.recordId})
            .then((result) =>{
                this.pedido = result;
                console.log('PEDIDO ' + this.pedido.OrderNumber);
                console.log('Nome do Caso ' + result.OrderNumber);
                
                totalPriceOrderItems({idCase : this.recordId})
                .then((result) =>{
                    this.valorTotal = result;
                })
                .catch((error) =>{
                    console.log('ERRO ' + error);
                })
                
                cloneAddress({idAddress: this.pedido.ShippingAddressId})
                .then((result) =>{
                    this.endereco = result;
                    console.log('ENDEREÇO ' + this.endereco.Id);
                })
                .catch((error) =>{
                    console.log('ERRO ' + error);
                })
                
                cloneCD({idCD: this.pedido.DistributionCenterId})
                .then((result) =>{
                    this.centroDistribuicao = result;
                    console.log('CENTRO DE DISTRIBUIÇÃO ' + this.centroDistribuicao.Id);
                })
                .catch((error) =>{
                    console.log('ERRO ' + error);
                })

                clonePricebook({idPricebook: this.pedido.Pricebook2Id})
                .then((result) =>{
                    this.pricebook = result;
                    console.log('PRICEBOOK ' + this.pricebook.Id);
                })
                .catch((error) =>{
                    console.log('ERRO ' + error);
                })
            })
            .catch((error) =>{
                console.log('ERRO ' + error);
            }); 
    }
    
    handleNavigate() {
        console.log('CLICOU!');
        var compDefinition = {
            componentDef: "c:cloneOrderItemsLWC",
            attributes: {recordId   : this.recordId,
                         itemsList : this.itemsList,
                         valorTotal : this.valorTotal}
        };
        try {
            const filterChangeEvent = new CustomEvent('displaymyvaluenew', {
                detail: { "data": JSON.stringify(compDefinition) }
            });
            // Fire the custom event
            this.dispatchEvent(filterChangeEvent);
        } catch (e) {
            debugger;
            console.log(e);
        }

        // //Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     title: 'Clone Order Items LWC',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef,
        //         title: 'Clone Order Items LWC'
        //     }
        // });
    }

    handleNavigateInventory() {
        console.log('CLICOU!');
        var compDefinition = {
            componentDef: "c:cloneOrderItemsLWC",
            attributes: {recordId   : this.recordId}
        };
        try {
            const filterChangeEvent = new CustomEvent('displaymyvalueold', {
                detail: { "data": JSON.stringify(compDefinition) }
            });
            // Fire the custom event
            this.dispatchEvent(filterChangeEvent);
        } catch (e) {
            debugger;
            console.log(e);
        }

        // //Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     title: 'Clone Order Items LWC',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef,
        //         title: 'Clone Order Items LWC'
        //     }
        // });
    }
}