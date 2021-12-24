import { LightningElement, api, track, wire } from 'lwc';

// importing Apex Class
import retriveOrderItems from '@salesforce/apex/SolicitarPostagemReversaLWCController.getOrderItems';
import createReversePost from '@salesforce/apex/SolicitarPostagemReversaLWCController.createReversePost';

export default class CustomHTMLDatatable extends LightningElement {
    // reactive variables
    @api recordId; //= '5002M00001JL5ScQAL';

    @track data = [];
    @track error;
    @track bShowModal = false;
    @track selectedItems;
    @track showLoading;

    // connectedCallback() {
    //     console.log('teste');

    //     getOrderId({caseId : this.recordId})
    //         .then(result => {
    //             this.orderId = result;
    //         })
    //         .catch(error => {
    //             this.error = error;
    //         });
    // }

    // opening the modal
    openModal() { this.bShowModal = true; }
    // closeing the modal
    closeModal() { this.bShowModal = false;}

    // Getting Contacts using Wire Service
    @wire(retriveOrderItems, {caseId : '$recordId'})
    contacts(result) {
        console.log('teste retrieveOrderItems');
        console.log('teste retrieveOrderItems 2');
        if (result.data) {
            this.data = result.data;
            this.error = undefined;

        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

    // Select the all rows
    allSelected(event) {
        let selectedRows = this.template.querySelectorAll('lightning-input');
        
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
            }
        }
    }

    async requestReversePost() {

        this.showLoading = true;

        this.selectedItems = [];

        let selectedRows = this.template.querySelectorAll('lightning-input');

        // based on selected row getting values of the contact
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].checked && selectedRows[i].type === 'checkbox') {
                this.selectedItems.push(selectedRows[i].dataset.id)
            }
        }
        
        console.log(this.selectedItems);

        var response = await createReversePost({caseId : this.recordId, orderItemIdsJSON : JSON.stringify(this.selectedItems)});
        console.log(response);

        this.showLoading = false;

        if(response.message) {
            this.error = response.message;
            this.openModal();
        }
    }

}