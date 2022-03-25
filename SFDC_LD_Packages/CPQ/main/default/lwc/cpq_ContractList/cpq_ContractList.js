import { LightningElement, api, track } from 'lwc';

export default class CPQ_ContractList extends LightningElement {

    // Source Object Info
    @api sourceInfo;

    // Loading / Show Spinner
    @track loading = false;

    // Boolean indicator if Active/Upcoming Contracts exist on Account
    get noActiveContractsToDisplay() {
        if (this.sourceInfo.Contracts) {
            return this.sourceInfo.Contracts.filter(
                contract => ['Active', 'Upcoming', 'Awaiting Renewal'].includes(contract.Contract_Status__c)
            ).length <= 0;
        } else {
            return true;
        }
    }

    get activeContracts() {
        let activeContracts = [];
        if (this.sourceInfo.Contracts) {
            activeContracts = this.sourceInfo.Contracts.filter(
                contract => ['Active', 'Upcoming', 'Awaiting Renewal'].includes(contract.Contract_Status__c)
            );
        }
        return activeContracts;
    }

    // Boolean indicator if Past Contracts exist on Account
    get noPastContractsToDisplay() {
        if (this.sourceInfo.Contracts) {
            return this.sourceInfo.Contracts.filter(
                contract => !['Active', 'Upcoming', 'Awaiting Renewal'].includes(contract.Contract_Status__c)
            ).length <= 0;
        } else {
            return true;
        }
    }

    get pastContracts() {
        let pastContracts = [];
        if (this.sourceInfo.Contracts) {
            pastContracts = this.sourceInfo.Contracts.filter(
                contract => !['Active', 'Upcoming', 'Awaiting Renewal'].includes(contract.Contract_Status__c)
            );
        }
        return pastContracts;
    }

    // Number of Contracts currently associated to Account
    get numberOfContracts() {
        if (this.sourceInfo.Contracts) {
            return this.sourceInfo.Contracts.length;
        } else {
            return 0;
        }
    }

    // Amend Contract event
    amendContract(event) {
        // Send Amend Contract call to parent
        const amendContractEvent = new CustomEvent(
            'amendcontract', {
                detail: event.detail
            });
        this.dispatchEvent(amendContractEvent);
    }

    // Replace Contract event
    replaceContract(event) {
        // Send Replace Contract call to parent
        const replaceContractEvent = new CustomEvent(
            'replacecontract', {
                detail: event.detail
            });
        this.dispatchEvent(replaceContractEvent);
    }

    // Renew Contract event
    renewContract(event) {
        // Send Renew Contract call to parent
        const renewContractEvent = new CustomEvent(
            'renewcontract', {
                detail: event.detail
            });
        this.dispatchEvent(renewContractEvent);
    }

    // Void Contract event
    voidContract(event) {
        // Send Void Contract call to parent
        const voidContractEvent = new CustomEvent(
            'voidcontract', {
                detail: event.detail
            });
        this.dispatchEvent(voidContractEvent);
    }

    // View Contract event
    viewContract(event) {
        // Send Void Contract call to parent
        const viewContractEvent = new CustomEvent(
            'viewcontract', {
                detail: event.detail
            });
        this.dispatchEvent(viewContractEvent);
    }

}