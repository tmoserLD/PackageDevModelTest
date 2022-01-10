import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminReferencedByRecord extends LightningElement {

    // Record
    @api record;

    // All Records
    @api allRecords;

    // Sobject type
    @api sobjectType;

    // Fields to show
    @api fields;

    get mainCSS() {
        let mainCSS = 'slds-grid slds-p-vertical_small';
        if (this.allRecords.indexOf(this.record) % 2 === 1
        ) {
            mainCSS += ' slds-theme_shade';
        }

        return mainCSS;
    }

    get fieldCSS() {
        let fieldCSS = 'slds-col slds-p-horizontal_x-small';
        if (this.fields.length >= 6) {
            fieldCSS += ' slds-size_1-of-6';
        }
        else if (this.fields.length === 5) {
            fieldCSS += ' slds-size_1-of-5';
        }
        else if (this.fields.length === 4) {
            fieldCSS += ' slds-size_1-of-4';
        }
        else if (this.fields.length === 3) {
            fieldCSS += ' slds-size_1-of-3';
        }
        else if (this.fields.length === 2) {
            fieldCSS += ' slds-size_1-of-2';
        }
        else if (this.fields.length === 1) {
            fieldCSS += ' slds-size_1-of-1';
        }
        return fieldCSS;
    }

}