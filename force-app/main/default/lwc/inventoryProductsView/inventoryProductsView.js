import { api, LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getProduct from '@salesforce/apex/InventoryProductsViewController.getProduct';

export default class InventoryProductsView extends LightningElement {
    @api brandId;
    @api recordId;
    @api productsSkuList;
    
    @track isLoadingProducts = false;
    @track prodFilterList = [];
    @track searchGenericValue = '';
    @track valorBusca;
    @track disabledNext = true;

    @track productsToContinue = [];
    @track productsSkuToContinue = [];

    activeTab

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;

        if (currentPageReference.state) {
            this.activeTab = currentPageReference.state.c__activeTab;
            console.log("this.activeTab", this.activeTab);
        }
    }

    connectedCallback(){
        this.isLoadingProducts = true;
        this.offSetValue = 0;
        this.prodFilterList = [];
        this.prodList = [];

        console.log('connectedCallback: Entrou na inventoryProductsView!');

        getProduct({ brandId: this.brandId, offSetValue: this.offSetValue.toString(), searchGenericValue: this.searchGenericValue, productSkuList: this.productsSkuList})
            .then(result => {
                console.log('getProduct: entrou certo!');
                console.log(result);
                this.isLoadingProducts = false;
                if (result != null) {
                    for (var i = 0; i < result.length; i++) {
                        this.prodList.push({
                            ...result[i],
                        });
                    }
                }
                if (result.length < 8) {
                    this.showMoreProduct = false;
                } else {
                    this.showMoreProduct = true;
                }
                this.prodFilterList = this.prodList;
            }).catch(error => {
                console.log('getProduct: entrou no erro!');
                console.log(error);
                this.isLoadingProducts = false;
            });
    }

    onChangeSearchProductName(event) {
        this.searchGenericValue = event.target.value;
        console.log(event.target.value);
        this.valorBusca = event.target.value;
        if (event.key === 'Enter') {
            this.isLoadingProducts = true;
            this.handleFilterSearchProd();
        }
    }

    handleFilterSearchProd() {
        console.log('Buscando produtos filtrados: ');
        this.isLoadingProducts = true;
        this.offSetValue = 0;
        this.prodFilterList = [];
        this.prodList = [];
        this.searchProducts();
    }

    searchProducts() {
        getProduct({ brandId: this.brandId, offSetValue: this.offSetValue.toString(), searchGenericValue: this.searchGenericValue, productSkuList: this.productsSkuList })
            .then(result => {
                console.log('getProduct: entrou certo!');
                console.log(result);
                this.isLoadingProducts = false;
                if (result != null) {
                    for (var i = 0; i < result.length; i++) {
                        this.prodList.push({
                            ...result[i],
                        });
                    }
                }
                if (result.length < 8) {
                    this.showMoreProduct = false;
                } else {
                    this.showMoreProduct = true;
                }

                for (var i = 0; i < this.prodList.length; i++) {
                    if(this.productsSkuToContinue.indexOf(this.prodList[i].id) > -1) {
                        this.prodList[i].isSelected = true;
                    }
                }

                this.prodFilterList = this.prodList;
            }).catch(error => {
                console.log('getProduct: entrou no erro!');
                console.log(error);
                this.isLoadingProducts = false;
            });
    }

    handleGetMoreProducts() {
        this.isLoadingProducts = true;
        this.offSetValue += 8;
        this.searchProducts();
    }

    get disabledNext() {
        return this.productsSkuToContinue === []? true : false;
    }

    handleCardClick(event) {
        console.log('handleCardClick');
        let productId = event.detail;
        console.log(productId);
        console.log(JSON.parse(JSON.stringify(this.productsSkuToContinue)));

        var isSelected;

        var productList = JSON.parse(JSON.stringify(this.prodFilterList));

        var currentProduct = productList.find(t => t.id === productId);

        if(this.productsSkuToContinue.find(obj => obj === productId)) {
            const index = this.productsSkuToContinue.indexOf(productId);

            if (index > -1) {
                this.productsSkuToContinue.splice(index, 1);
                this.productsToContinue.splice(index, 1);
            }
            isSelected = false;
        } else {
            this.productsSkuToContinue.push(productId);
            this.productsToContinue.push(currentProduct);
            isSelected = true;
        }

        this.template.querySelectorAll('c-inventory-products-card').forEach(item => {
            if (item.prod.id === productId) {
                item['selected'] = isSelected;
            }
        });

        console.log(JSON.parse(JSON.stringify(this.productsSkuToContinue)));

        console.log('this.disabledNext => ' + this.disabledNext);
            this.disabledNext = this.productsSkuToContinue.length === 0? true : false;
        console.log('this.disabledNext => ' + this.disabledNext);
    }

    goToOrderScreen() {
        console.log('goToOrderScreen');
        console.log('brandId => ' + this.brandId);

        var compDefinition = {
            componentDef: "c:cloneOrderLWC",
            title: "Gerar pedido",
            attributes: {
                recordId: this.recordId,
                itemsList: this.productsToContinue,
                productsSkuToContinue: this.productsSkuToContinue
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
        //     title: 'Gerar Pedido',
        //     c__activeTab: this.activeTab,
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef,
        //         title: 'Gerar Pedido'
        //     }
        // });
    }
}