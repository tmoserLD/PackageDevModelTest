import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

// Initial Query Method
import getCPQInfo from '@salesforce/apex/cpq_ContainerClass.getCPQInfo';

export default class Cpq_Container extends NavigationMixin(LightningElement) {

    // Opportunity Id
    @api recordId;

    // Type of Quote configuration
    @track configType;
    // Default Currency
    @track defaultCurrency;
    // User has access to opp
    @track hasOppAccess;
    // Loading / Show Spinner
    @track loading = true;
    // Opportunity Info
    @track oppInfo = {};
    // Quote going into quote configuration
    @track quoteForConfig = {};
    // UI toggle for quote configuration
    @track showQuoteConfig = false;
    // User Info
    @track userInfo = {};
    // Record URLs
    @track oppURL = '/';
    @track acctURL = '/';

    // On Mount
    connectedCallback() {
        this.reload();
    }

    // Determine if System Settings include Proposal
    get allowProposal() {
        if (this.oppInfo.SystemSettings !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c.split(';').includes('Proposal')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Create Quote event received
    createQuote() {
        this.configType = 'New';
        this.quoteForConfig = {};
        this.showQuoteConfig = true;
    }

    // Edit Quote event received
    editQuote(event) {
        this.configType = 'Edit';
        this.quoteForConfig = this.oppInfo.Quotes.find(
            quote => quote.Id === event.detail
        );
        this.showQuoteConfig = true;
    }

    // View Quote event received
    viewQuote(event) {
        this.configType = 'View';
        this.quoteForConfig = this.oppInfo.Quotes.find(
            quote => quote.Id === event.detail
        );
        this.showQuoteConfig = true;
    }

    // Amend Contract event received
    amendContract(event) {
        this.configType = 'New';
        
        // Contract
        let tempQuoteObj = this.oppInfo.Contracts.find(
            contract => contract.Id === event.detail
        );

        // Set 'Quote' data
        tempQuoteObj.Name = 'Amendment of Contract #' + tempQuoteObj.ContractNumber;
        tempQuoteObj.QuoteLineItems = [];
        tempQuoteObj.CPQ_Playbook_Answers__r = tempQuoteObj.Contract_Playbook_Answers__r;
        tempQuoteObj.Adjustment_of_Contract__c = tempQuoteObj.Id;
        tempQuoteObj.Adjustment_Type__c = 'Amendment';

        // Remove Id -- since not quote
        tempQuoteObj.contractId = tempQuoteObj.Id;
        tempQuoteObj.Id = undefined;

        this.quoteForConfig = tempQuoteObj;
        this.showQuoteConfig = true;
    }

    // Replace Contract event received
    replaceContract(event) {
        this.configType = 'New';
        
        // Contract
        let tempQuoteObj = this.oppInfo.Contracts.find(
            contract => contract.Id === event.detail
        );

        // Set 'Quote' data
        tempQuoteObj.Name = 'Replacement of Contract #' + tempQuoteObj.ContractNumber;
        tempQuoteObj.QuoteLineItems = tempQuoteObj.Contract_Entitlements__r;
        tempQuoteObj.CPQ_Playbook_Answers__r = tempQuoteObj.Contract_Playbook_Answers__r;
        tempQuoteObj.Adjustment_of_Contract__c = tempQuoteObj.Id;
        tempQuoteObj.Adjustment_Type__c = 'Replacement';

        // Remove Id -- since not quote
        tempQuoteObj.contractId = tempQuoteObj.Id;
        tempQuoteObj.Id = undefined;

        this.quoteForConfig = tempQuoteObj;
        this.showQuoteConfig = true;
    }

    // Renew Contract event received
    renewContract(event) {
        this.configType = 'New';

        // Contract
        let tempQuoteObj = this.oppInfo.Contracts.find(
            contract => contract.Id === event.detail
        );

        // Set 'Quote' data
        tempQuoteObj.Name = 'Renewal of Contract #' + tempQuoteObj.ContractNumber;
        tempQuoteObj.QuoteLineItems = tempQuoteObj.Contract_Entitlements__r;
        tempQuoteObj.CPQ_Playbook_Answers__r = tempQuoteObj.Contract_Playbook_Answers__r;
        tempQuoteObj.Adjustment_of_Contract__c = tempQuoteObj.Id;
        tempQuoteObj.Adjustment_Type__c = 'Renewal';

        // Adjust dates on line items
        if (tempQuoteObj.QuoteLineItems !== undefined) {
            tempQuoteObj.QuoteLineItems.forEach(function(qli) {

                // Get term
                let Difference_In_Time = new Date(qli.End_Date__c).getTime() - new Date(qli.Start_Date__c).getTime();
                let Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);

                // Set Start Date one day after End Date
                let newStart = new Date(qli.End_Date__c);
                newStart.setUTCDate(new Date(qli.End_Date__c).getUTCDate() + 1);
                let newYear = newStart.getUTCFullYear().toString();
                let newMonth = (newStart.getUTCMonth() + 1).toString();
                if ((newStart.getUTCMonth() + 1) < 10) {
                    newMonth = '0' + newMonth;
                }
                let newDay = newStart.getUTCDate().toString();
                if (newStart.getUTCDate() < 10) {
                    newDay = '0' + newDay;
                }
                qli.Start_Date__c = newYear + '-' + newMonth + '-' + newDay;

                // Set End Date to match same line term
                let newEnd = new Date(qli.Start_Date__c);
                newEnd.setUTCDate(new Date(qli.Start_Date__c).getUTCDate() + Difference_In_Days);
                let year = newEnd.getUTCFullYear().toString();
                let month = (newEnd.getUTCMonth() + 1).toString();
                if ((newEnd.getUTCMonth() + 1) < 10) {
                    month = '0' + month;
                }
                let day = newEnd.getUTCDate().toString();
                if (newEnd.getUTCDate() < 10) {
                    day = '0' + day;
                }
                qli.End_Date__c = year + '-' + month + '-' + day;
            }, this);
        }

        // Remove Id -- since not quote
        tempQuoteObj.contractId = tempQuoteObj.Id;
        tempQuoteObj.Id = undefined;

        this.quoteForConfig = tempQuoteObj;
        this.showQuoteConfig = true;
    }

    // View Contract event received
    viewContract(event) {
        this.configType = 'View';
        
        // Contract
        let tempQuoteObj = this.oppInfo.Contracts.find(
            contract => contract.Id === event.detail
        );

        // Set 'Quote' data
        tempQuoteObj.Name = 'Contract #' + tempQuoteObj.ContractNumber;
        tempQuoteObj.QuoteLineItems = tempQuoteObj.Contract_Entitlements__r;
        tempQuoteObj.CPQ_Playbook_Answers__r = tempQuoteObj.Contract_Playbook_Answers__r;

        // Remove Id -- since not quote
        tempQuoteObj.contractId = tempQuoteObj.Id;
        tempQuoteObj.Id = undefined;

        this.quoteForConfig = tempQuoteObj;
        this.showQuoteConfig = true;
    }

    // Reload data
    async reload(event) {

        // Show Toast
        if (event) {
            if (event.detail) {
                if (event.detail.toast) {
                    const toastEvent = new ShowToastEvent({
                        title: event.detail.toast.title,
                        message: event.detail.toast.message,
                        variant: event.detail.toast.variant,
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        }

        this.showQuoteConfig = false;
        this.configType = undefined;
        this.loading = true;

        // Get data
        let queriedCPQInfo;
        
        try {
            queriedCPQInfo = await getCPQInfo(
                { oppId: this.recordId }
            );
            this.hasOppAccess = queriedCPQInfo.hasOppAccess;

            // User has access to CPQ on this opp
            if (queriedCPQInfo.hasOppAccess == true) {

                // Opp Info obj to hold child records
                let restructuredOppInfo = queriedCPQInfo.oppInfo;
                restructuredOppInfo.Contracts = queriedCPQInfo.contracts;
                restructuredOppInfo.Quotes = queriedCPQInfo.quotes;
                restructuredOppInfo.SystemSettings = queriedCPQInfo.systemSettings;
                restructuredOppInfo.QuoteTableColumns = queriedCPQInfo.quoteTableColumns;
                restructuredOppInfo.ContractTableColumns = queriedCPQInfo.contractTableColumns;

                // Currency for non-MultiCurrency orgs
                this.defaultCurrency = queriedCPQInfo.defaultCurrency;
                if (restructuredOppInfo.CurrencyIsoCode === undefined) {
                    restructuredOppInfo.CurrencyIsoCode = queriedCPQInfo.defaultCurrency;
                }
                restructuredOppInfo.Contracts.forEach(function(contract) {
                    if (contract.CurrencyIsoCode === undefined) {
                        contract.CurrencyIsoCode = queriedCPQInfo.defaultCurrency;
                    }
                }, this);

                // "Parent" approval records
                queriedCPQInfo.approvalSteps.forEach(function(step) {
                    restructuredOppInfo.Quotes.forEach(function(quote) {
                        if (quote.Id === step.CPQ_Quote_Approval__r.Quote__c &&
                            quote.CPQ_Quote_Approvals__r    
                        ) {
                            quote.CPQ_Quote_Approvals__r.forEach(function(approval) {
                                if (approval.Id === step.CPQ_Quote_Approval__c) {
                                    if (!approval.CPQ_Quote_Approval_Steps__r) {
                                        approval.CPQ_Quote_Approval_Steps__r = [];
                                    }
                                    approval.CPQ_Quote_Approval_Steps__r.push(JSON.parse(JSON.stringify(step)));
                                }
                            }, this);
                        }
                    }, this);
                }, this);
                this.oppInfo = restructuredOppInfo;
                this.userInfo = queriedCPQInfo.userInfo;
            }
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to retrieve the opportunity CPQ data',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    navToOpp() {
        // Navigate to the Opportunity home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.oppInfo.Id,
                objectApiName: 'Opportunity',
                actionName: 'view',
            },
        });
    }

    navToAcct() {
        // Navigate to the Account home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.oppInfo.Account.Id,
                objectApiName: 'Account',
                actionName: 'view',
            },
        });
    }

    // Notes update
    updateApproverNotes(event) {

        this.oppInfo.Quotes.find(
            quote => quote.Id === event.detail.quoteId
        ).CPQ_Quote_Approvals__r.find(
            approval => approval.Id === event.detail.approvalId
        ).Notes_for_Approvers__c = event.detail.notes;
    }
}