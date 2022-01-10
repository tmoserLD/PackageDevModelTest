import { LightningElement, api, track } from 'lwc';

export default class CPQ_ContractListItem extends LightningElement {

    // All Contracts on opp's account
    @api allContracts = [];

    // Contract record
    @api contract;

    // Opportunity Info
    @api oppInfo;

    // Can replace
    get canReplace() {
        if (this.oppInfo.Lock_CPQ__c ||
            this.contract.Contract_Status__c == 'Past'  
        ) {
            return false;
        } else {
            return true;
        }
    }

    // Replace button title
    get replaceTitle() {
        let title = 'Replace Contract';
        if (this.oppInfo.Lock_CPQ__c) {
            title = 'Cannot Replace. Opportunity is locked';
        }
        else if (this.contract.Contract_Status__c == 'Past') {
            title = 'Cannot Replace. Contract in past';
        }
        return title;
    }

    // Can renew
    get canRenew() {
        if (this.oppInfo.Lock_CPQ__c) {
            return false;
        } else {
            return true;
        }
    }

    // Renew button title
    get renewTitle() {
        let title = 'Renew Contract';
        if (this.oppInfo.Lock_CPQ__c) {
            title = 'Cannot Renew. Opportunity is locked';
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

    // Opp Link
    get oppLink() {
        return '/' + this.contract.Opportunity__c;
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

}