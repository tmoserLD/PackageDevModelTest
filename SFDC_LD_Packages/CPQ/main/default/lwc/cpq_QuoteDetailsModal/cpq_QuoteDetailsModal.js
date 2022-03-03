import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CPQ_QuoteDetailsModal extends NavigationMixin(LightningElement) {

    // Quote
    @api quote;

    // Opportunity Info
    @api oppInfo;

    get sourceContractName() {
        if (this.quote.Adjustment_of_Contract__c !== undefined) {
            return this.quote.Adjustment_of_Contract__r.ContractNumber;
        } else {
            return '';
        }
    }

    // Close clicked
    closeClick() {

        // Send Hide Details call to parent
        const hideDetailsEvent = new CustomEvent('hidedetails');
        this.dispatchEvent(hideDetailsEvent);
    }

    navToQuote() {
        // Navigate to the Quote home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.quote.Id,
                objectApiName: 'Quote',
                actionName: 'view',
            },
        });
    }
}