import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent }              from 'lightning/platformShowToastEvent';
import { CurrentPageReference }        from 'lightning/navigation';
import { getRecord, getFieldValue }    from 'lightning/uiRecordApi';
import CASE_OBJECT                     from '@salesforce/schema/Case';
import NUMERO_COLETA                   from '@salesforce/schema/Case.NumeroColeta__c';
import acompanharPedido                from '@salesforce/apex/SolicitarCodigoRastreioController.solicitaCodigoRastreio';
import idCase                          from '@salesforce/apex/SolicitarCodigoRastreioController.recordIdCaso';


export default class SolicitarCodigoRastreioLWC extends LightningElement {
    recordId;
    StatusMessage = '';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }

        console.log('RecordId ' + this.recordId);

        idCase({id: this.recordId})
        .then((result) => {
            console.log('RESULTADO THEN ' +  result);
            if (result == 'CódigoDeRastreioJáPreenchido') {

                this.StatusMessage = 'O Código de Rastreio Já Está Preenchido!';
                this.showToast('Atenção', 'Código de Rastreio Já Preenchido!','Warning');

            } else {
                acompanharPedido({idCaso: this.recordId})
                .then((result) => {
                this.StatusMessage = 'Código de Rastreio Solicitado!';
                this.showToast('Mensagem de Retorno', result,'success');

                })
                .catch((result) => {

                this.showToast('ERRO!', result,'Warning');

                });
            }
        })
        .catch((result) => {
            console.log('RESULTADO CATCH ' + result);
        });
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