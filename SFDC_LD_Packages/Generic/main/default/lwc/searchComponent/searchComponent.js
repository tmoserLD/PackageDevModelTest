import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import search from '@salesforce/apex/SearchController.search';
const DELAY = 300;
export default class SearchComponent extends LightningElement {

    @api valueId;
    @api valueName;
    @api objName = 'Account';
    @api iconName = 'standard:account';
    @api labelName;
    @api readOnly = false;
    @api currentRecordId;
    @api placeholder = 'Search';
    @api createRecord;
    @api fields = ['Name'];
    @api displayFields = 'Name, Rating, AccountNumber';

    @track error;

    searchTerm;
    delayTimeout;

    searchRecords;
    selectedRecord;
    objectLabel;
    isLoading = false;

    field;
    field1;
    field2;

    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';

    connectedCallback(){

        let icons           = this.iconName.split(':');
        this.ICON_URL       = this.ICON_URL.replace('{0}',icons[0]);
        this.ICON_URL       = this.ICON_URL.replace('{1}',icons[1]);
        if(this.objName.includes('__c')){
            let obj = this.objName.substring(0, this.objName.length-3);
            this.objectLabel = obj.replaceAll('_',' ');
        }else{
            this.objectLabel = this.objName;
        }
        this.objectLabel    = this.titleCase(this.objectLabel);
        let fieldList;
        if( !Array.isArray(this.displayFields)){
            fieldList       = this.displayFields.split(',');
        }else{
            fieldList       = this.displayFields;
        }
        
        if(fieldList.length > 1){
            this.field  = fieldList[0].trim();
            this.field1 = fieldList[1].trim();
        }
        if(fieldList.length > 2){
            this.field2 = fieldList[2].trim();
        }
        let combinedFields = [];
        fieldList.forEach(field => {
            if( !this.fields.includes(field.trim()) ){
                combinedFields.push( field.trim() );
            }
        });

        this.fields = combinedFields.concat( JSON.parse(JSON.stringify(this.fields)) );
        
    }

    handleInputChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.isLoading = true;
        this.delayTimeout = setTimeout(() => {
            if(searchKey.length >= 2){
                search({ 
                    objectName : this.objName,
                    fields     : this.fields,
                    searchTerm : searchKey 
                })
                .then(result => {
                    let stringResult = JSON.stringify(result);
                    let allResult    = JSON.parse(stringResult);
                    allResult.forEach( record => {
                        if (this.field !== undefined &&
                            this.field.split('.').length > 1    
                        ) {
                            record.FIELD1 = record[this.field.split('.')[0]][this.field.split('.')[1]];
                        } else {
                            record.FIELD1 = record[this.field];
                        }
                        if (this.field1 !== undefined &&
                            this.field1.split('.').length > 1    
                        ) {
                            record.FIELD2 = record[this.field1.split('.')[0]][this.field1.split('.')[1]];
                        } else {
                            record.FIELD2 = record[this.field1];
                        }
                        if (this.field2 !== undefined &&
                            this.field2.split('.').length > 1    
                        ) {
                            record.FIELD3 = record[this.field2.split('.')[0]][this.field2.split('.')[1]];
                        } else {
                            record.FIELD3 = record[this.field2];
                        }
                    }, this);
                    this.searchRecords = allResult;
                    
                })
                .catch(error => {
                    console.error('Error:', error);
                })
                .finally( ()=>{
                    this.isLoading = false;
                });
            } else {
                this.searchRecords = [];
                this.isLoading = false;
            }
        }, DELAY);
    }

    handleSelect(event){
        
        let recordId = event.currentTarget.dataset.recordId;
        
        let selectRecord = this.searchRecords.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord;
        
        const selectedEvent = new CustomEvent('lookup', {
            detail: recordId
        });
        this.dispatchEvent(selectedEvent);
    }

    handleClose(){
        this.selectedRecord = undefined;
        this.searchRecords  = undefined;
        const selectedEvent = new CustomEvent('lookup', {
            detail: undefined
        });
        this.dispatchEvent(selectedEvent);
    }

    titleCase(string) {
        var sentence = string.toLowerCase().split(" ");
        for(var i = 0; i< sentence.length; i++){
            sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
        }
        return sentence;
    }

    @api selectFromParent(record) {
        let selectedRecord = JSON.parse(JSON.stringify(record));
        if (this.field !== undefined &&
            this.field.split('.').length > 1    
        ) {
            selectedRecord.FIELD1 = selectedRecord[this.field.split('.')[0]][this.field.split('.')[1]];
        } else {
            selectedRecord.FIELD1 = selectedRecord[this.field];
        }
        if (this.field1 !== undefined &&
            this.field1.split('.').length > 1    
        ) {
            selectedRecord.FIELD2 = selectedRecord[this.field1.split('.')[0]][this.field1.split('.')[1]];
        } else {
            selectedRecord.FIELD2 = selectedRecord[this.field1];
        }
        if (this.field2 !== undefined &&
            this.field2.split('.').length > 1    
        ) {
            selectedRecord.FIELD3 = selectedRecord[this.field2.split('.')[0]][this.field2.split('.')[1]];
        } else {
            selectedRecord.FIELD3 = selectedRecord[this.field2];
        }
        this.selectedRecord = selectedRecord;
    }
}