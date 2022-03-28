import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

// Account/Contracts Query Method
import queryAccountWithContracts from '@salesforce/apex/cpq_ContractsByAccountClass.queryAccountWithContracts';

// Sobject records update
import updateRecords from '@salesforce/apex/cpq_ContractsByAccountClass.updateRecords';

export default class CPQ_AccountContracts extends NavigationMixin(LightningElement) {

    @api acctId;

    @track acct = {};

    // Contract object to pass in as quote to CPQ Config
    @track contractForConfig;

    // Config objects
    @track oppForConfig;
    @track userForConfig;

    @track loading = false;

    // Toggle to display CPQ Config
    @track showConfig = false;

    connectedCallback() {
        this.queryContractRecords();
    }

    async queryContractRecords() {

        this.loading = true;

        let acctQueried = [];
        try {
            acctQueried = await queryAccountWithContracts(
                {
                    acctId : this.acctId
                }
            );
            acctQueried.sourceType = 'Account';

            // Currency for non-MultiCurrency orgs
            acctQueried.Contracts.forEach(function(contract) {
                if (contract.CurrencyIsoCode === undefined) {
                    contract.CurrencyIsoCode = acctQueried.defaultCurrency;
                }
            }, this);

        } catch (e) {
            console.error(e);
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to query the account contracts',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.acct = acctQueried;

        this.loading = false;
    }

    navToAcct() {
        // Navigate to the Account home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.acctId,
                objectApiName: 'Account',
                actionName: 'view',
            },
        });
    }

    // Hide Config event received
    hideConfig(event) {
        this.showConfig = false;
    }

    // View Contract event received
    viewContract(event) {
        
        // Contract
        let tempQuoteObj = JSON.parse(JSON.stringify(this.acct.Contracts.find(
            contract => contract.Id === event.detail
        )));

        // Set 'Quote' data
        tempQuoteObj.Name = 'Contract #' + tempQuoteObj.ContractNumber;
        tempQuoteObj.QuoteLineItems = tempQuoteObj.Contract_Entitlements__r;
        tempQuoteObj.CPQ_Playbook_Answers__r = tempQuoteObj.Contract_Playbook_Answers__r;

        // Remove Id -- since not quote
        tempQuoteObj.contractId = tempQuoteObj.Id;
        tempQuoteObj.Id = undefined;

        this.contractForConfig = tempQuoteObj;
        this.oppForConfig = {CurrencyIsoCode : tempQuoteObj.CurrencyIsoCode};
        this.userForConfig = {};
        this.showConfig = true;
    }

    // Void contract event
    async voidContract(event) {
        this.loading = true;

        try {
            await updateRecords(
                {
                    records : [
                        {
                            sobjectType: 'Contract',
                            Id: event.detail,
                            IsVoid__c: true
                        }
                    ]
                }
            );
            const toastEvent = new ShowToastEvent({
                title: 'Success!',
                message: 'Contract was voided',
                variant: 'success',
            });
            this.dispatchEvent(toastEvent);
        } catch (e) {
            console.error(e);
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to void the contract',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;

        this.queryContractRecords();
    }
}