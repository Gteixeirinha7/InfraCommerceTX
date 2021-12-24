import { LightningElement, api, track } from 'lwc';
import { NavigationMixin }              from 'lightning/navigation';
import { ShowToastEvent }               from 'lightning/platformShowToastEvent'
import { loadScript }                   from 'lightning/platformResourceLoader';
import cloneLogisticInformation         from '@salesforce/apex/CloneOrderController.cloneLogisticInformation';
import holidays                         from '@salesforce/apex/CloneOrderController.holidays';
import createCloneOrder                 from '@salesforce/apex/CloneOrderController.createCloneOrder';
import sendOrderToIntegration           from '@salesforce/apex/CloneOrderController.sendOrderToIntegration';
import sendCaseToIntegration            from '@salesforce/apex/CloneOrderController.sendCaseToIntegration';
import AllJsFilesSweetAlert             from '@salesforce/resourceUrl/AllJsFilesSweetAlert';
import UserPreferencesShowFaxToGuestUsers from '@salesforce/schema/User.UserPreferencesShowFaxToGuestUsers';

export default class CloneLogisticInformationLWC extends NavigationMixin(LightningElement) {

    @api recordId;
    @api valorTotal            = '';
    @api itemSelecionados      = [];
    @track logisticInformation = {};
    @track showSpinner;

    feriados              = [];
    empresaEntrega        = '';
    estimativaEntrega     = '';
    dataEstimativaEntrega = '';
    contratoLogistico     = '';
    estimativaEnvio       = '';
    createdOrderId        = '';

    connectedCallback(){
        cloneLogisticInformation({idCaso : this.recordId})
            .then((result) =>{
                this.logisticInformation = result;
                console.log('RESULT ' + result);
            })
            .catch((error) =>{
                console.log('ERROR ' + error);
            });
        holidays()
            .then((result) =>{
                this.feriados = result;
                console.log('RESULT HOLIDAYS ' + result);
            })
            .catch((error) =>{
                console.log('ERROR ' + error);
            });
        
        Promise.all([loadScript(this, AllJsFilesSweetAlert + '/sweetalert-master/sweetalert.min.js')]).then(() => {console.log('Files loaded.');}).catch(error => {console.log('error: ' + JSON.stringify(error));});
    }

    handleEmpresaEntrega(event){
        this.empresaEntrega = event.target.value;
        console.log('Empresa de Entrege ' + this.empresaEntrega);
    }

    handleEstimativaEnvio(event){   
        this.estimativaEntrega = event.target.value;
        console.log('Estimativa de Entrega ' + this.estimativaEntrega);
    }

    handleDataEstimada(event){
        this.dataEstimativaEntrega = event.target.value;
        console.log('Data Estimada de Entrega ' + this.dataEstimativaEntrega);

        var dataEstimada = new Date(this.dataEstimativaEntrega);
        console.log('DATA ESTIMADA FORMATADA ' + dataEstimada);

        var today = new Date();
        var datee = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();

        var dataAtual    = new Date(datee);
        console.log('DATA ATUAL FORMATADA ' + dataAtual);

        let count = 0;
        const curDate = new Date(dataAtual.getTime()); 

        while (curDate <= dataEstimada) {
            const dayOfWeek = curDate.getDay();

            if (typeof curDate == 'string' || typeof curDate == 'number') {
                curDate = new Date(curDate);
            }
            if (!(curDate instanceof Date)) {
                return false;
            }
            var sSizeAno = (curDate.getUTCFullYear());
            var ano      = (sSizeAno < 10 ? '0' + sSizeAno : sSizeAno);
            var sSizeMes = (curDate.getUTCMonth()+1);
            var mes      = (sSizeMes < 10 ? '0' + sSizeMes : sSizeMes);
            var sSizeDia = (curDate.getDate());
            var dia      = (sSizeDia < 10 ? '0' + sSizeDia : sSizeDia);

            var dateFormat = ano + '-' + mes + '-' + dia;
            console.log('Data formatada ' + dateFormat);

            
            console.log('curDate ' + curDate);
            console.log('dayOfWeek ' + dayOfWeek);
            console.log('this.feriados ' + this.feriados);

            if(!(dayOfWeek in [0, 6]) && !(this.feriados.includes(dateFormat))) count++;
            curDate.setDate(curDate.getDate() + 1);
        }
        console.log('DIAS ÚTEIS ' + count);
        this.logisticInformation.shippingEstimate__c = count + ' dias úteis (' + count + 'bd)';
    }

    handleContratoLogistico(event){
        this.contratoLogistico = event.target.value;
        console.log('Contrato Logístico ' + this.contratoLogistico);
    }

    async handleSave(){
        console.log('logisticInformation.shippingEstimate__c ' + this.logisticInformation.shippingEstimate__c);


        if(this.logisticInformation.shippingEstimate__c == null || this.logisticInformation.shippingEstimate__c == undefined) {
            this.showToast('Atenção!', 'Preencha o campo "Data Estimada de Entrega" antes de seguir!','Warning');
        } else {

            try {

                this.showSpinner = true;

                const createCloneOrderResult = await createCloneOrder(
                    {   idCaso: this.recordId,
                        logisticInformationToClone : this.logisticInformation,
                        shippingEstimatedDate: this.dataEstimativaEntrega, 
                        listOrderItemsJSON: JSON.stringify(this.itemSelecionados)
                    }
                );

                console.log('createCloneOrderResult => ' + createCloneOrderResult);

                if(createCloneOrderResult.hasError) {
                    console.log('mostrar erro' + createCloneOrderResult.message);
                    swal('Aviso!', 'Ocorreu um erro ao gerar os registros de Pedido no SF: \n' + createCloneOrderResult.message);
                    this.showSpinner = false;
                } else {
                    this.createdOrderId = createCloneOrderResult.orderId;
                    const sendOrderResult = await sendOrderToIntegration({idCaso: this.recordId, idOrder: createCloneOrderResult.orderId});
                    console.log('sendOrderResult => ' + sendOrderResult);

                    if(sendOrderResult.hasError) {
                        swal('Aviso!', 'Ocorreu um erro ao tentar enviar o Pedido ao ERP: \n' + sendOrderResult.message);
                        this.showSpinner = false;
                    } else {
                        const sendCaseResult = await sendCaseToIntegration({idCaso: this.recordId});
                        this.showSpinner = false;
                        
                        if(sendCaseResult.hasError) {
                            swal('Aviso!', 'Ocorreu um erro ao tentar enviar o Protocolo para o ERP: \n' + sendCaseResult.message);
                        } else {
                            swal({
                                title: 'Sucesso!',
                                text: ('O seu pedido foi enviado para o ERP!'),
                                type: 'success',
                                confirmButtonColor: "#5cb85c",
                                confirmButtonText: "Ok",
                                closeOnConfirm: false
                            }).then(function (isConfirm) {
                                if(isConfirm) {
                                    this[NavigationMixin.Navigate]({
                                        type: 'standard__recordPage',
                                        attributes: {
                                            recordId: this.createdOrderId,
                                            objectApiName: 'order',
                                            actionName: 'view'
                                        }
                                    })
                                }
                            });
                        }
                    }
                }
            } catch (error) {
                console.log('ERROR ' + error);
                this.showSpinner = false;
                swal('Aviso!', 'Ocorreu um erro ao tentar enviar o Protocolo para o ERP: \n' + error);
            }
            /*
            createCloneOrder({idCaso: this.recordId,
                            logisticInformationToClone : this.logisticInformation,
                            shippingEstimatedDate: this.dataEstimativaEntrega, 
                            listOrderItemsJSON: JSON.stringify(this.itemSelecionados)})
                            .then((result) =>{
                                console.log('RESULT ' + result);
                                if(result.hasError) {
                                    console.log('mostrar erro' + result.message);
                                    swal('Aviso!', 'Ocorreu um erro ao gerar os registros de Pedido no SF: \n' + result.message);
                                    this.showSpinner = false;
                                } else {
                                    this.createdOrderId = result.orderId;
                                    sendOrderToIntegration({idCaso: this.recordId, idOrder: result.orderId})
                                    .then((result) => {
                                        console.log('RESULT sendOrderToIntegration' + result);
                                        if(result.hasError) {
                                            swal('Aviso!', 'Ocorreu um erro ao tentar enviar o Pedido ao ERP: \n' + result.message);
                                            this.showSpinner = false;
                                        } else {
                                            sendCaseToIntegration({idCaso: this.recordId})
                                            .then((result) =>  {
                                                console.log('RESULT sendCaseToIntegration' + result);
                                                this.showSpinner = false;
                                                if(result.hasError) {
                                                    swal('Aviso!', 'Ocorreu um erro ao tentar enviar o Protocolo para o ERP: \n' + result.message);
                                                } else {
                                                    swal({
                                                        title: 'Sucesso!',
                                                        text: ('O seu pedido foi enviado para o ERP!'),
                                                        type: 'success',
                                                        confirmButtonColor: "#5cb85c",
                                                        confirmButtonText: "Ok",
                                                        closeOnConfirm: false
                                                    }).then(function (isConfirm) {
                                                        if(isConfirm) {
                                                            this[NavigationMixin.Navigate]({
                                                                type: 'standard__recordPage',
                                                                attributes: {
                                                                    recordId: this.createdOrderId,
                                                                    objectApiName: 'order',
                                                                    actionName: 'view'
                                                                }
                                                            })
                                                        }
                                                    });
                                                }
                                            }).catch((error) => {
                                                console.log('ERROR ' + error);
                                                this.showSpinner = false;
                                                swal('Aviso!', 'Ocorreu um erro ao tentar enviar o Protocolo para o ERP: \n' + result.message);
                                            })
                                        }
                                    })
                                    .catch((error) =>{
                                        console.log('ERROR ' + error);
                                        this.showSpinner = false;
                                    });
                                }
                            })
                            .catch((error) =>{
                                console.log('ERROR ' + error);
                                this.showSpinner = false;
                                swal('Aviso!', 'Ocorreu um erro ao gerar o Pedido no SF: \n' + error);
                            });
                            */
        }
    }

    handleNavigateA(){
        console.log('CLICOU!');
        var compDefinition = {
            componentDef: "c:cloneOrderItemsLWC",
            attributes: {recordId   : this.recordId,
                         valorTotal : this.valorTotal,
                         itemSelecionados : []
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