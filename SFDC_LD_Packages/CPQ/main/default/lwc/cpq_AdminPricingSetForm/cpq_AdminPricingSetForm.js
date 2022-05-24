import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

export default class CPQ_AdminPricingSetForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Pricing Set
    @api pricingSet;

    // Set Id
    @api pricingSetId;

    // Spinner
    @track loading = false;

    // Object containing selections for all levels
    @api selected;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this pricing set?';


    get hasId() {
        return this.pricingSet !== undefined;
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
                records: [this.pricingSet]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Pricing Set was deleted',
                            variant: 'success'
                        },
                        selected: {
                            pricebook: this.selected.pricebook,
                            pricebookName: this.selected.pricebookName,
                            pricebookTab: 'pricingSets',
                            pricingSet: undefined,
                            pricingSetName: undefined,
                            pricingSetTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the pricing set',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteSet() {
        this.showConfirmDelete = true;
    }

    // Saved Entry
    savedSet(event) {

        this.loading = false;

        // Send saved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Pricing Set was saved',
                        variant: 'success'
                    },
                    selected: {
                        pricebook: this.selected.pricebook,
                        pricebookName: this.selected.pricebookName,
                        pricebookTab: 'pricingSets',
                        pricingSet: event.detail.id,
                        pricingSetTab: 'pricingSet'
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the pricing set',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Submit
    submitSet() {
        this.loading = true;
    }

    // Clone record
    async cloneSet() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.pricingSet.Id,
                objectAPI: 'CPQ_Pricing_Set__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Pricing Set was cloned',
                            variant: 'success'
                        },
                        selected: {
                            pricebook: this.selected.pricebook,
                            pricebookName: this.selected.pricebookName,
                            pricebookTab: 'pricingSets',
                            pricingSet: newRecord.Id,
                            pricingSetTab: 'pricingSet'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the pricing set',
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