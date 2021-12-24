import { LightningElement, api, track } from 'lwc';
import {refreshApex} from '@salesforce/apex';
import getAvailableData from '@salesforce/apex/CustomLookupController.getAvailableData';
import getRecords from '@salesforce/apex/CustomLookupController.getRecords';
import BRAND_NAME_FIELD from '@salesforce/schema/Brand__c.Name';
import BRAND_EXTERNAL_ID_FIELD from '@salesforce/schema/Brand__c.ExternalId__c';

const brandFields = [BRAND_NAME_FIELD, BRAND_EXTERNAL_ID_FIELD];

export default class CustomLookup extends LightningElement {
  @api objectApiName;
  @api fieldApiName = 'name';
  @api objectIconName = 'standard:custom_notification';
  @api inputLabel = 'Selecione um registro';
  @api clientId = '';
  @api checkType = '';
  @api conditionId = '';
  @api disabled = false;
  @api placeholder;
  @api required;

  @track searchValue = null;
  @track recordsList = null;
  @track isLoading = false;
  @api selectedRecord = null;
  @api hideClose = false;

  @track query;

  connectedCallback() {
    console.log('this.checkType ' + this.checkType);
    console.log('brandFields ' + brandFields);
    if(this.checkType =='ContaOrdem'){
        getContaOrdem({
          clientId: this.clientId,
          searchValue: this.searchValue
        }).then(data => {
            console.log(data);
            this.recordsList = JSON.parse(data);
            this.isLoading = false;
            
          })
          .catch(error => {
            console.log(error);
          });
    }else{
      if (brandFields) {
        const searchFieldsApiNames = brandFields
          .filter(fieldRef => fieldRef.objectApiName === this.objectApiName)
          .map(fieldRef => fieldRef.fieldApiName)

        this.generateQueryBase(searchFieldsApiNames);
      }
    }
  }

  generateQueryBase(searchFieldsApiNames) {
    let searchBase = '';
    console.log('searchValue: ' + this.searchValue);
    searchFieldsApiNames.forEach((field, index) => {
      searchBase += `${index > 0 ? ' OR' : ''} ${field} LIKE '%#SEARCH#%'`;
    });

    this.query = `
      SELECT ${searchFieldsApiNames.join()}
      FROM ${this.objectApiName}
      WHERE Id != NULL
      AND ( ${searchBase} ) LIMIT 50
    `;
  }

  handleTyping(event) {
    const { value } = event.target;

    if (value.length < 1) {
      this.recordsList = null;
      return;
    }

    this.searchValue = value;
    this.isLoading = true;

    this.handleGetRecords();
  }

  handleGetRecords() {
    const formattedQuery = this.query.replace(/#SEARCH#/g, this.searchValue);
    console.log(formattedQuery);
    console.log('this.checkType ' + this.checkType);
    if (this.checkType == 'Account') {
      getRecords({ query: formattedQuery, checkType: this.objectApiName }).then(data => {
        console.log('getRecords: entrou certo!');
        console.log(data);
        this.recordsList = JSON.parse(data);
        this.isLoading = false;
      }).catch(error => {
        console.log('getRecords: entrou no erro!');
        console.log(error);
      });
    } else {    
        getAvailableData({
          clientId: this.clientId,
          conditionId: this.conditionId,
          filter: this.searchValue,
          checkType : this.checkType
        }).then(data => {
            console.log(data);
            this.recordsList = JSON.parse(data);
            this.isLoading = false;
            
          })
          .catch(error => {
            console.log(error);
          });
    }      
  }
  handleFocus(event) {

      console.log('conta ordem ' + this.checkType);

    if(this.checkType =='ContaOrdem'){
        getContaOrdem({
          clientId: this.clientId,
          searchValue: this.searchValue
        }).then(data => {
            console.log(data);
            this.recordsList = JSON.parse(data);
            this.isLoading = false;
            
          })
          .catch(error => {
            console.log(error);
          });
    }else{
      if (event.target.value == '') {
        const q = `
        SELECT Id, Name
        FROM ${this.objectApiName} LIMIT 50
      `;
        getRecords({ query: q, checkType: this.objectApiName}).then(data => {
          console.log('getRecords: entrou certo!');
          console.log(data);
          this.recordsList = JSON.parse(data);
          this.isLoading = false;
        }).catch(error => {
          console.log('getRecords: entrou no erro!');
          console.log(error);
        });
      } else {       
        getAvailableData({
          clientId: this.clientId,
          conditionId: this.conditionId,
          filter: this.searchValue,
          checkType : this.checkType
        }).then(data => {
            console.log(data);
            this.recordsList = JSON.parse(data);
            this.isLoading = false;
            
          })
          .catch(error => {
            console.log(error);
          });
      }
    }
  }

  handleSelectRecordClick(event) {
    const { value } = event.target.dataset;
    this.handleSelectRecord(value)
  }
  handleSelectRecord(value) {
    const record = value == null ? null : this.recordsList.find(item => item.id === value);

    this.selectedRecord = record;
    console.log(record);

    // this.recordsList = null;

    this.dispatchEvent(
      new CustomEvent('selectrecord', {
        detail: {
          record: this.selectedRecord
        }
      })
    );
  }

  handleClearSelectedClose() {
    this.handleClearSelected();
    this.handleSelectRecord(null);
  }

  @api
  handleClearSelected() {
    console.log(null);
    this.selectedRecord = null;
    this.searchValue = null;
    this.recordsList = null;
  }
}