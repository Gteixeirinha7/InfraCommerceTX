import { LightningElement, api, wire, track} from 'lwc';
import { CurrentPageReference, NavigationMixin }          from 'lightning/navigation';
import { updateRecord }   from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import retriveProductsToClone from '@salesforce/apex/CloneOrderController.getProductsToClone';
//import createReversePost from '@salesforce/apex/SolicitarPostagemReversaLWCController.createReversePost';

const columns =[
    { label: 'Nome do Produto', fieldName: 'productName',       type: 'text',     editable: false},
    { label: 'Preço',           fieldName: 'price',             type: 'currency', editable: false},
    { label: 'Quantidade',      fieldName: 'quantity',          type: 'number',   editable: true},
    { label: 'Qtd em Estoque',  fieldName: 'inventoryQuantity', type: 'number',   editable: false},
    { label: 'Sku',             fieldName: 'sku',               type: 'text',     editable: false}
];

export default class CloneOrderItemsLWC extends NavigationMixin(LightningElement) {

    @api recordId;
    @api itemsList = [];
    @api productsSkuList = [];
    @api valorTotal;

    @track data     = [];
    columns = columns;

    saveDraftValues       = [];
    listSelected          = [];
    valorTotalSelecionado = 0;

    // Getting Contacts using Wire Service
    // @wire(retriveOrderItems, {caseId : '$recordId'})
    // contacts(result) {
    //     if (result.data) {
    //         this.data = result.data;
    //         this.error = undefined;

    //     } else if (result.error) {
    //         this.error = result.error;
    //         this.data = undefined;
    //     }
    // }

    @wire(retriveProductsToClone, {productInventories : '$itemsList'})
    contacts(result) {
        if (result.data) {
            this.data = result.data;
            this.error = undefined;

        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

    handleSave(event) {
        console.log('draftSave')
        this.saveDraftValues = event.detail.draftValues;
        // draft com valores editados
        console.log(this.saveDraftValues);
        console.log("this.saveDraftValues.length");

        
    }

    getSelectedDel(event){
        const selectedRows = event.detail.selectedRows;
        this.listSelected  = selectedRows;
        console.log('LISTA SELECIONADA ' + this.listSelected);
        this.valorTotalSelecionado = 0;
        for (var a = 0; a < this.listSelected.length; a++) {

            var precoItem = event.detail.selectedRows[a].price;
            //console.log('Preço do Item ' + precoItem);
            var quntItem  = event.detail.selectedRows[a].quantity;
            //console.log('Quantidade do Item');

            if(quntItem == null || quntItem == undefined) {
                this.showToast('Atenção!', 'Preencha a quantidade do item corretamente','Warning');
            }

            var inventoryQuntItem  = event.detail.selectedRows[a].inventoryQuantity;
            //console.log('Quantidade Em Estoque do Item');

            var marginQunt = this.listSelected[a].quantityMargin;

            if(quntItem > (inventoryQuntItem - marginQunt)) {
                this.showToast('Atenção!', 'A quantidade do item não pode exceder a margem de segurança de quantidade (' + marginQunt + ') em Estoque','Warning');
            }

            this.valorTotalSelecionado = this.valorTotalSelecionado + (precoItem * quntItem);
            //this.valorTotalSelecionado = parseFloat(this.valorTotalSelecionado + (precoItem * quntItem)).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL'});
        }
        console.log(Number(this.valorTotal.replace(',','.')));

        // if(this.valorTotalSelecionado > Number(this.valorTotal.replace(',','.'))){
        //     this.showToast('Atenção!', 'A soma dos pedidos selecionados não pode ser maior que o valor total do pedido.','Warning');
        // }
    }
    handleCellChange(event){
        console.log('event' + event.detail.draftValues);

        this.saveDraftValues = event.detail.draftValues;

        var saveDraftValues = this.saveDraftValues;
        console.log('Teste');
        var recordId = event.detail.draftValues[0].id;
        console.log('recordID' + recordId);
        var itemsDatatable = [];
        itemsDatatable = JSON.parse(JSON.stringify(this.data));
        console.log(JSON.parse(JSON.stringify(itemsDatatable)));

        var previousQuantity = Number(itemsDatatable.find(data => data.id === recordId).quantity);

        if(event.detail.draftValues[0].quantity == null || event.detail.draftValues[0].quantity == undefined) {
            this.showToast('Atenção!', 'Preencha a quantidade do item corretamente','Warning');
        }

        itemsDatatable.find(data => data.id === recordId).quantity = Number(event.detail.draftValues[0].quantity);

        if(itemsDatatable.find(data => data.id === recordId).quantity > (itemsDatatable.find(data => data.id === recordId).inventoryQuantity - itemsDatatable.find(data => data.id === recordId).quantityMargin)) {
            this.showToast('Atenção!', 'A quantidade do item não pode exceder a margem de segurança de quantidade (' + itemsDatatable.find(data => data.id === recordId).quantityMargin + ') em Estoque','Warning');
            itemsDatatable.find(data => data.id === recordId).quantity = Number(previousQuantity);
            saveDraftValues.find(data => data.id === recordId).quantity = Number(previousQuantity);
            this.saveDraftValues = saveDraftValues;
        } 

        console.log(JSON.parse(JSON.stringify(this.data)));
        this.data = itemsDatatable;

        console.log(JSON.parse(JSON.stringify(this.data)));
        console.log('finalizou');
        console.log('ParseINT' + parseInt(this.valorTotal));
        console.log('Number '  + Number(this.valorTotal));

        var listSelectedAtt = [];
        for (var a = 0; a < this.data.length; a++) {
            for (var b = 0; b < this.listSelected.length; b++) {
                if(this.data[a].id == this.listSelected[b].id){
                    listSelectedAtt.push(this.data[a]);
                }
            }
        }
        this.listSelected = listSelectedAtt;

        if (this.listSelected.find(data => data.id === recordId) != undefined){
            //var valorAnterior = this.valorTotalSelecionado;
            this.valorTotalSelecionado = 0;
            for (var a = 0; a < this.listSelected.length; a++) {
                //var precoItem = event.detail.draftValues[a].price;
                var precoItem = this.listSelected[a].price;
                console.log('Preço do Item ' + precoItem);
                //var quntItem  = event.detail.draftValues[0].quantity;
                var quntItem  = this.listSelected[a].quantity;
                console.log('Quantidade do Item');

                var marginQunt = this.listSelected[a].quantityMargin;

                if(quntItem == null || quntItem == undefined) {
                    this.showToast('Atenção!', 'Preencha a quantidade do item corretamente','Warning');
                }
    
                var inventoryQuntItem  = this.listSelected[a].inventoryQuantity;
                //console.log('Quantidade Em Estoque do Item');
    
                if(quntItem > (inventoryQuntItem - marginQunt)) {
                    this.showToast('Atenção!', 'A quantidade do item não pode exceder a margem de segurança de quantidade (' + marginQunt + ') em Estoque','Warning');
                }

                this.valorTotalSelecionado = this.valorTotalSelecionado + (precoItem * quntItem);
                //this.valorTotalSelecionado = parseFloat(this.valorTotalSelecionado + (precoItem * quntItem)).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL'});
            }
            // if(this.valorTotalSelecionado > Number(this.valorTotal.replace(',','.'))){
            //     this.showToast('Atenção!', 'A soma dos pedidos selecionados não pode ser maior que o valor total do pedido.','Warning');
            // }
        }
    }

    handleNavigateA() {
        console.log('CLICOU!');
        var compDefinition = {
            componentDef: "c:cloneOrderLWC",
            attributes: {
                recordId  : this.recordId, 
                itemsList : this.itemsList
            }
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

    handleNavigateP() {
        console.log('CLICOU!');
        // if(this.valorTotalSelecionado > Number(this.valorTotal.replace(',','.'))){
        //     this.showToast('Atenção!', 'A soma dos pedidos selecionados não pode ser maior que o valor total do pedido.','Warning');
        //     console.log('IF');
        // }else{
        //     console.log('ELSE');

        if(this.valorTotalSelecionado <= 0) {
            this.showToast('Atenção!', 'Selecione ao menos um produto para seguir!','Warning');
        } else {

            var compDefinition = {
                componentDef: "c:cloneLogisticInformationLWC",
                attributes: {recordId   : this.recordId,
                            valorTotal  : this.valorTotal,
                            itemSelecionados : this.listSelected}
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
        //}
        }
    }

    showToast(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }
}