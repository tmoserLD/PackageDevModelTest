import { LightningElement, api, track } from 'lwc';

// Clone Quote Method
import cloneQuoteData from '@salesforce/apex/cpq_ContainerClass.cloneQuoteData'; 

// Delete Records Method
import deleteRecords from '@salesforce/apex/cpq_ContainerClass.deleteRecords';

// Update Records Method
import updateRecords from '@salesforce/apex/cpq_ContainerClass.updateRecords';

export default class CPQ_QuoteList extends LightningElement {

    // Opportunity Info
    @api oppInfo;

    // User Info
    @api userInfo;

    // Loading / Show Spinner
    @track loading = false;

    // Determine if quote can be created
    get cannotCreateQuote() {
        return this.oppInfo.Lock_CPQ__c;
    }

    // Boolean indicator if Quotes exist on Opp
    get noQuotesToDisplay() {
        if (this.oppInfo.Quotes) {
            return this.oppInfo.Quotes.length <= 0;
        } else {
            return true;
        }
    }

    // Number of Quotes currently associated to Opp
    get numberOfQuotes() {
        if (this.oppInfo.Quotes) {
            return this.oppInfo.Quotes.length;
        } else {
            return 0;
        }
    }

    // User clicked "Create Quote" button
    clickCreateQuote() {
        const createQuoteEvent = new CustomEvent(
            'createquote', {
                detail: '' 
            });
        this.dispatchEvent(createQuoteEvent);
    }

    // Clone Quote
    async cloneQuote(event) {

        this.loading = true;
        try {
            await cloneQuoteData({
                quoteId: event.detail
            });

            const reloadEvent = new CustomEvent(
                'reload', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Quote was cloned',
                            variant: 'success'
                        }
                    }
                });
            this.dispatchEvent(reloadEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the quote',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }
    }

    // Delete Quote
    async deleteQuote(event) {

        this.loading = true;
        try {
            await deleteRecords({
                records: [this.oppInfo.Quotes.find(
                    quote => quote.Id === event.detail
                )]
            });

            const reloadEvent = new CustomEvent(
                'reload', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Quote was deleted',
                            variant: 'success'
                        }
                    }
                });
            this.dispatchEvent(reloadEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the quote',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }
    }

    // Edit Quote
    async editQuote(event) {
        const editQuoteEvent = new CustomEvent(
            'editquote', {
                detail: event.detail
            });
        this.dispatchEvent(editQuoteEvent);
    }

    // View Quote
    async viewQuote(event) {
        const viewQuoteEvent = new CustomEvent(
            'viewquote', {
                detail: event.detail
            });
        this.dispatchEvent(viewQuoteEvent);
    }

    recallApproval(event) {
        const reloadEvent = new CustomEvent(
            'reload', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Approval was recalled',
                        variant: 'success'
                    }
                }
            });
        this.dispatchEvent(reloadEvent);
    }

    savedProposal(event) {
        const reloadEvent = new CustomEvent(
            'reload', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Proposal was created and linked to the Opportunity',
                        variant: 'success'
                    }
                }
            });
        this.dispatchEvent(reloadEvent);
    }

    submittedApprovals(event) {
        const reloadEvent = new CustomEvent(
            'reload', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Approvals were submitted for the quote',
                        variant: 'success'
                    }
                }
            });
        this.dispatchEvent(reloadEvent);
    }

    // Sync Quote
    async syncQuote(event) {

        this.loading = true;

        let oppObj = JSON.parse(JSON.stringify(this.oppInfo));
        oppObj.SyncedQuoteId = event.detail;

        try {
            await updateRecords({
                records: [oppObj]
            });

            const reloadEvent = new CustomEvent(
                'reload', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Quote was synced',
                            variant: 'success'
                        }
                    }
                });
            this.dispatchEvent(reloadEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to sync the quote',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
            this.loading = false;
        }
    }

    // Unsync Quote
    async unsyncQuote(event) {

        this.loading = true;

        let oppObj = JSON.parse(JSON.stringify(this.oppInfo));
        oppObj.SyncedQuoteId = null;

        try {
            await updateRecords({
                records: [oppObj]
            });

            const reloadEvent = new CustomEvent(
                'reload', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Quote was unsynced',
                            variant: 'success'
                        }
                    }
                });
            this.dispatchEvent(reloadEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to unsync the quote',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }
    }

    // Notes update
    updateApproverNotes(event) {
        // Send approvernoteupdate event to parent
        const approvernoteupdateEvent = new CustomEvent(
            'approvernoteupdate', {
                detail: event.detail
            });
        this.dispatchEvent(approvernoteupdateEvent);
    }
}