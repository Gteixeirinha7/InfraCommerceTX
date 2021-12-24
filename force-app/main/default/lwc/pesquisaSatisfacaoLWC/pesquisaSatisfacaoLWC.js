import { LightningElement, track } from 'lwc';
import saveSurvey from '@salesforce/apex/PesquisaSatisfacaoController.saveSurvey';
import verifySurvey from '@salesforce/apex/PesquisaSatisfacaoController.verifySurvey';

export default class PesquisaSatisfacaoLWC extends LightningElement {
    @track hideResponse = true;
    @track showResponse = false;
    @track responseMessage;
    value = '';
    ratingValue = 0;
    surveyRecordId = '';
    encodedSurveyRecordId = '';
    observations = '';

    get problemSolvedOptions() {
        return [
            { label: 'Sim', value: 'Sim' },
            { label: 'Não', value: 'Não' }
        ];
    }

    get ratingValueOptions() {
        return [
            { label: '1', value: 1 },
            { label: '2', value: 2 },
            { label: '3', value: 3 },
            { label: '4', value: 4 },
            { label: '5', value: 5 }
        ];
    }
    
    async connectedCallback() {
        var str = window.location.href;
        var urlTest = new URL(str);
        this.surveyRecordId = urlTest.searchParams.get('id');
        this.encodedSurveyRecordId = encodeURIComponent(this.surveyRecordId);

        // var response = await verifySurvey(this.encodedSurveyRecordId);

        verifySurvey({encodedId : this.surveyRecordId}).then(response => {
            if(response.isError){
                this.responseMessage = response.message;
                this.hideResponse = false;
                this.showResponse = true;
            } else {
                this.hideResponse = true;
                this.showResponse = false;
            }
        });
    }

    handleChange(event) {
        console.log(event.detail);
        this.value = event.detail.value;
        console.log(this.value);
    }

    handleRatingChange(event) {
        console.log(this.ratingValue);
        this.ratingValue = parseInt(event.detail.value);
        console.log(this.ratingValue);
    }

    async handleClick(event) {

        console.log('this.surveyRecordId => ' + this.surveyRecordId);

        let survey = { 'surveyRecordId' : this.surveyRecordId};
        survey.problemSolved = this.value;
        survey.rating = this.ratingValue;
        survey.observations = this.observations;

        console.log(survey);

        // var response = await saveSurvey({surveyData : survey});
        var response = await saveSurvey({problemSolved: this.value, rating: this.ratingValue, encodedId: this.surveyRecordId, observations: this.observations});
        console.log(response);

        this.responseMessage = 'Obrigado pelo feedback!';
        this.hideResponse = false;
        this.showResponse = true;
    }

    consoleModified(a) {
        console.log(JSON.parse(JSON.stringify(a)));
    }
}