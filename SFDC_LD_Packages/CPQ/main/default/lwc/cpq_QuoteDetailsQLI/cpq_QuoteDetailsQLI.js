import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CPQ_QuoteDetailsQLI extends NavigationMixin(LightningElement) {

    // All Line Items on Quote
    @api allLines = [];

    // Opportunity Info
    @api oppInfo;

    // Line Item
    @api qli;

    get mainCSS() {
        let CSS = 'slds-col slds-grid slds-p-around_x-small';
        if (this.allLines.indexOf(this.qli) % 2 === 1) {
            CSS += ' slds-theme_shade';
        } else {
            CSS += ' slds-theme_default';
        }
        return CSS;
    }

    navToQLI() {
        // Navigate to the QLI home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.qli.Id,
                objectApiName: 'QuoteLineItem',
                actionName: 'view',
            },
        });
    }
}