import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue }    from 'lightning/uiRecordApi';
import { CurrentPageReference }        from 'lightning/navigation';
import CASE_OBJECT                     from '@salesforce/schema/Case';
import posPostagemController           from '@salesforce/apex/PosPostagemController.PosPostagemController';

export default class PosPostagemLWC extends LightningElement {
    recordId;

    @track bShowModal = false;
 
    caseObject = CASE_OBJECT;
    @track message = '';

    // @wire(getRecord, {recordId: '$recordId', fields: NAME_FIELD })
    // record; 

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }

        console.log('RecordId ' + this.recordId);

        posPostagemController({recordId : this.recordId})
        .then((result) => {
            console.log('RESULTADO THEN ' + result);
            this.message = result;
        })
        .catch((result) => {
            console.log('RESULTADO CATCH ' + result);
        });
    }

    // opening the modal
    openModal() { this.bShowModal = true; }
    // closeing the modal
    closeModal() { this.bShowModal = false;}
}