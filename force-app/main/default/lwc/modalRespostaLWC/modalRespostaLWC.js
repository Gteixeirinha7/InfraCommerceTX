import { LightningElement}        from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent }         from 'lightning/platformShowToastEvent';
import sendPublicMessage          from '@salesforce/apex/IntegrationReclameAqui.sendPublicMessage';

export default class ModalRespostaLWC extends LightningElement {
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    } 

    id   = '45543619';
    message = '';
    
    messageTyped(event) { 
        this.message = event.target.value;
    } 

    enviarMensagem(){
        sendPublicMessage({id:this.id, message:this.message})
        .then((result) => {
            console.log(result);
            this.showToast('Sucesso!', result,'success');
            this.closeAction();
        })
        .catch((result) => {
            console.log(result);
            this.showToast('Atenção', result,'Warning');
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