import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CPQ_ContractDetailsModal extends NavigationMixin(LightningElement) {

    // Contract
    @api contract;

    get adjustedByContractName() {
        if (this.contract.Adjusted_by_Contract__c != undefined) {
            return this.contract.Adjusted_by_Contract__r.ContractNumber;
        } else {
            return '';
        }
    }

    get sourceContractName() {
        if (this.contract.Source_Contracts__r != undefined &&
            this.contract.Source_Contracts__r.length > 0    
        ) {
            return this.contract.Source_Contracts__r[0].ContractNumber;
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

    navToOpp() {
        // Navigate to the Opportunity home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contract.Opportunity__c,
                objectApiName: 'Opportunity',
                actionName: 'view',
            },
        });
    }
}