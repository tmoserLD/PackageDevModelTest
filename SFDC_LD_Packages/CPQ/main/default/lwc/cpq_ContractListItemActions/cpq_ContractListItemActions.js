import { LightningElement, api, track } from 'lwc';

export default class CPQ_ContractListItemActions extends LightningElement {

    // All Contracts with source
    @api allContracts = [];

    // Contract record
    @api contract;

    // Source Info
    @api sourceInfo;

    // Void Confirmation Modal toggle
    @track showConfirmVoid = false;

    // Prompt to show in Void Confirmation Modal
    @track confirmVoidPrompt = 'Are you sure you want to void this contract?';

    // Account Source
    get accountSource() {
        return this.sourceInfo.sourceType === 'Account';
    }

    // Determine if System Settings include Amend
    get allowAmend() {

        if (this.sourceInfo.SystemSettings !== undefined &&
            this.sourceInfo.SystemSettings.Contract_Table_Actions__c !== undefined &&
            this.sourceInfo.SystemSettings.Contract_Table_Actions__c.split(';').includes('Amend')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if System Settings include Replace
    get allowReplace() {

        if (this.sourceInfo.SystemSettings !== undefined &&
            this.sourceInfo.SystemSettings.Contract_Table_Actions__c !== undefined &&
            this.sourceInfo.SystemSettings.Contract_Table_Actions__c.split(';').includes('Replace')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if System Settings include Renew
    get allowRenew() {

        if (this.sourceInfo.SystemSettings !== undefined &&
            this.sourceInfo.SystemSettings.Contract_Table_Actions__c !== undefined &&
            this.sourceInfo.SystemSettings.Contract_Table_Actions__c.split(';').includes('Renew')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if System Settings include View
    get allowView() {

        if (this.sourceInfo.SystemSettings !== undefined &&
            this.sourceInfo.SystemSettings.Contract_Table_Actions__c !== undefined &&
            this.sourceInfo.SystemSettings.Contract_Table_Actions__c.split(';').includes('View')
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if System Settings include Void
    get allowVoid() {

        if (this.sourceInfo.SystemSettings !== undefined &&
            this.sourceInfo.SystemSettings.Contract_Table_Actions__c !== undefined &&
            this.sourceInfo.SystemSettings.Contract_Table_Actions__c.split(';').includes('Void') &&
            this.sourceInfo.isContractAdmin === true
        ) {
            return true;
        } else {
            return false;
        }
    }

    // CSS class names string for component
    get colCSS() {
        let colCSS = 'slds-list_horizontal slds-wrap';
        if (this.allContracts.indexOf(
            this.allContracts.find(
                contract => contract.Id === this.contract.Id
                )
            ) % 2 === 1
        ) {
            colCSS += ' slds-theme_shade';
        }
        return colCSS;
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
        this.showConfirmVoid = true;
    }

    // Cancel void
    cancelVoid() {
        this.showConfirmVoid = false;
    }

    // Confirmation received to void
    async confirmVoid() {

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

}