import { LightningElement, api, track } from 'lwc';

export default class CPQ_RecordLookupRecord extends LightningElement {

    // All Records
    @api allRecords = [];

    // Account Columns
    @api columnsToDisplay;

    // Record record
    @api record;

    // CSS class names string for component
    get colCSS() {
        let colCSS = 'slds-col slds-p-left_xx-small';
        if (this.allRecords.indexOf(
            this.allRecords.find(
                record => record.Id === this.record.Id
                )
            ) % 2 === 1
        ) {
            colCSS += ' slds-theme_shade';
        }
        if (this.columnsToDisplay.length > 5) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-6';
        }
        else if (this.columnsToDisplay.length === 5) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-5';
        }
        else if (this.columnsToDisplay.length === 4) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-4 slds-large-size_1-of-4';
        }
        else if (this.columnsToDisplay.length === 3) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-3 slds-large-size_1-of-3';
        }
        return colCSS;
    }

}