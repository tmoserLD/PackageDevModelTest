import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Cpq_ContractDetailsEntitlement extends NavigationMixin(LightningElement) {

    // All Entitlements on Contract
    @api allEntitlements = [];

    // Contract Entitlement comes from
    @api contract;

    // Entitlement
    @api entitlement

    get mainCSS() {
        let CSS = 'slds-col slds-grid slds-p-around_x-small';
        if (this.allEntitlements.indexOf(this.entitlement) % 2 === 1) {
            CSS += ' slds-theme_shade';
        } else {
            CSS += ' slds-theme_default';
        }
        return CSS;
    }

    navToEntitlement() {
        // Navigate to the Entitlement home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.entitlement.Id,
                objectApiName: 'Contract_Entitlement__c',
                actionName: 'view',
            },
        });
    }
}