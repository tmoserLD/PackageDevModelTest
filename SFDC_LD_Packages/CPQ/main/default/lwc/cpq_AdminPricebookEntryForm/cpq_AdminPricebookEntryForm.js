import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

export default class CPQ_AdminPricebookEntryForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Entry
    @api entry

    // Entry Id
    @api entryId;

    // Spinner
    @track loading = false;

    // Object containing selections for all levels
    @api selected;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this pricebook entry?';

    get hasId() {
        return this.entry !== undefined;
    }

    get pricebookId() {
        return this.selected.pricebook.split('-')[0];
    }

    // Cancel delete
    cancelDelete() {
        this.showConfirmDelete = false;
    }

    // Confirmation received to delete
    async confirmDelete() {
        this.showConfirmDelete = false;

        this.loading = true;

        try {
            await deleteRecords({
                records: [this.entry]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Pricebook Entry was deleted',
                            variant: 'success'
                        },
                        selected: {
                            pricebook: this.selected.pricebook,
                            pricebookName: this.selected.pricebookName,
                            pricebookTab: 'entries',
                            pricebookEntry: undefined,
                            pricebookEntryName: undefined,
                            pricebookEntryTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the pricebook entry',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteEntry() {
        this.showConfirmDelete = true;
    }

    // Saved Entry
    savedEntry(event) {

        this.loading = false;

        // Send saved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Pricebook Entry was saved',
                        variant: 'success'
                    },
                    selected: {
                        pricebook: this.selected.pricebook,
                        pricebookName: this.selected.pricebookName,
                        pricebookTab: 'entries',
                        pricebookEntry: event.detail.id,
                        pricebookEntryTab: 'entry'
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the pricebook entry',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Submit
    submitEntry() {
        this.loading = true;
    }

    // Clone record
    async cloneEntry() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.entry.Id,
                objectAPI: 'PricebookEntry'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Pricebook Entry was cloned',
                            variant: 'success'
                        },
                        selected: {
                            pricebook: this.selected.pricebook,
                            pricebookName: this.selected.pricebookName,
                            pricebookTab: 'entries',
                            pricebookEntry: newRecord.Id,
                            pricebookEntryTab: 'entry'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the pricebook entry',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    cancel() {
        // Send cancel event to parent
        const cancelEvent = new CustomEvent(
            'cancel'
        );
        this.dispatchEvent(cancelEvent);
    }

}