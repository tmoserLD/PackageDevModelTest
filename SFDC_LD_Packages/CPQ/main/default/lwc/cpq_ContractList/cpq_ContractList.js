import { LightningElement, api, track } from 'lwc';

export default class CPQ_ContractList extends LightningElement {

    // Opportunity Info
    @api oppInfo;

    // Loading / Show Spinner
    @track loading = false;

    // Boolean indicator if Active/Upcoming Contracts exist on Account
    get noActiveContractsToDisplay() {
        if (this.oppInfo.Contracts) {
            return this.oppInfo.Contracts.filter(
                contract => ['Active', 'Upcoming'].includes(contract.Contract_Status__c)
            ).length <= 0;
        } else {
            return true;
        }
    }

    get activeContracts() {
        let activeContracts = [];
        if (this.oppInfo.Contracts) {
            activeContracts = this.oppInfo.Contracts.filter(
                contract => ['Active', 'Upcoming'].includes(contract.Contract_Status__c)
            );
        }
        return activeContracts;
    }

    // Boolean indicator if Past Contracts exist on Account
    get noPastContractsToDisplay() {
        if (this.oppInfo.Contracts) {
            return this.oppInfo.Contracts.filter(
                contract => ['Past'].includes(contract.Contract_Status__c)
            ).length <= 0;
        } else {
            return true;
        }
    }

    get pastContracts() {
        let pastContracts = [];
        if (this.oppInfo.Contracts) {
            pastContracts = this.oppInfo.Contracts.filter(
                contract => ['Past'].includes(contract.Contract_Status__c)
            );
        }
        return pastContracts;
    }

    // Number of Contracts currently associated to Account
    get numberOfContracts() {
        if (this.oppInfo.Contracts) {
            return this.oppInfo.Contracts.length;
        } else {
            return 0;
        }
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

}