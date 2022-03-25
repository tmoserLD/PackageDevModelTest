import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CPQ_ContractListItem extends NavigationMixin(LightningElement) {

    // All Contracts with source
    @api allContracts = [];

    // Contract record
    @api contract;

    // Source Info
    @api sourceInfo;

    // Account Sourec
    get accountSource() {
        return this.sourceInfo.sourceType === 'Account';
    }

    // Can amend
    get canAmend() {
        if (this.sourceInfo.Lock_CPQ__c ||
            !['Active', 'Upcoming'].includes(this.contract.Contract_Status__c)
        ) {
            return false;
        } else {
            return true;
        }
    }

    // Amend button title
    get amendTitle() {
        let title = 'Amend Contract';
        if (this.sourceInfo.Lock_CPQ__c) {
            title = 'Cannot Amend. Opportunity is locked';
        }
        else if (!['Active', 'Upcoming'].includes(this.contract.Contract_Status__c)) {
            title = 'Cannot Amend. Contract already past, void and/or adjusted';
        }
        return title;
    }

    // Can replace
    get canReplace() {
        if (this.sourceInfo.Lock_CPQ__c ||
            !['Active', 'Upcoming'].includes(this.contract.Contract_Status__c)
        ) {
            return false;
        } else {
            return true;
        }
    }

    // Replace button title
    get replaceTitle() {
        let title = 'Replace Contract';
        if (this.sourceInfo.Lock_CPQ__c) {
            title = 'Cannot Replace. Opportunity is locked';
        }
        else if (!['Active', 'Upcoming'].includes(this.contract.Contract_Status__c)) {
            title = 'Cannot Replace. Contract already past, void and/or adjusted';
        }
        return title;
    }

    // Can renew
    get canRenew() {
        if (this.sourceInfo.Lock_CPQ__c ||
            !['Active', 'Upcoming', 'Past'].includes(this.contract.Contract_Status__c)    
        ) {
            return false;
        } else {
            return true;
        }
    }

    // Renew button title
    get renewTitle() {
        let title = 'Renew Contract';
        if (this.sourceInfo.Lock_CPQ__c) {
            title = 'Cannot Renew. Opportunity is locked';
        } else if (!['Active', 'Upcoming', 'Past'].includes(this.contract.Contract_Status__c)) {
            title = 'Cannot Renew. Contract void and/or already adjusted';
        }
        return title;
    }

    // Can void
    get canVoid() {
        if (!['Active', 'Upcoming'].includes(this.contract.Contract_Status__c)) {
            return false;
        } else {
            return true;
        }
    }

    // Void button title
    get voidTitle() {
        let title = 'Void Contract';
        if (!['Active', 'Upcoming'].includes(this.contract.Contract_Status__c)) {
            title = 'Cannot Void. Contract already past, void and/or adjusted';
        }
        return title;
    }

    // CSS classes for main div
    get mainCSS() {
        let mainCSS = 'slds-grid slds-p-around_x-small';
        if (this.allContracts.indexOf(this.contract) % 2 === 1) {
            mainCSS += ' slds-theme_shade';
        }
        return mainCSS;
    }

    // Amend clicked
    amendContract() {
        // Send Amend Contract call to parent
        const amendContractEvent = new CustomEvent(
            'amendcontract', {
                detail: this.contract.Id
            });
        this.dispatchEvent(amendContractEvent);
    }

    // Replace clicked
    replaceContract() {
        // Send Replace Contract call to parent
        const replaceContractEvent = new CustomEvent(
            'replacecontract', {
                detail: this.contract.Id
            });
        this.dispatchEvent(replaceContractEvent);
    }

    // Renew clicked
    renewContract() {
        // Send Renew Contract call to parent
        const renewContractEvent = new CustomEvent(
            'renewcontract', {
                detail: this.contract.Id
            });
        this.dispatchEvent(renewContractEvent);
    }

    // Void clicked
    voidContract() {
        // Send Void Contract call to parent
        const voidContractEvent = new CustomEvent(
            'voidcontract', {
                detail: this.contract.Id
            });
        this.dispatchEvent(voidContractEvent);
    }

    // View clicked
    viewContract() {
        // Send View Contract call to parent
        const viewContractEvent = new CustomEvent(
            'viewcontract', {
                detail: this.contract.Id
            });
        this.dispatchEvent(viewContractEvent);
    }

    navToContract() {
        // Navigate to the Contract home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contract.Id,
                objectApiName: 'Contract',
                actionName: 'view',
            },
        });
    }
}