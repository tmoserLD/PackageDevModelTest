import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

export default class CPQ_AdminPricingThresholdForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Pricing Threshold
    @api pricingThreshold;

    // Threshold Id
    @api pricingThresholdId;

    // Spinner
    @track loading = false;

    // Object containing selections for all levels
    @api selected;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this pricing threshold?';


    get hasId() {
        return this.pricingThreshold !== undefined;
    }

    get setId() {
        return this.selected.pricingSet.split('-')[0];
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
                records: [this.pricingThreshold]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Pricing Threshold was deleted',
                            variant: 'success'
                        },
                        selected: {
                            pricebook: this.selected.pricebook,
                            pricebookName: this.selected.pricebookName,
                            pricebookTab: 'pricingSets',
                            pricingSet: this.selected.pricingSet,
                            pricingSetName: this.selected.pricingSetName,
                            pricingSetTab: 'pricingThresholds',
                            pricingThreshold: undefined,
                            pricingThresholdName: undefined,
                            pricingThresholdTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the pricing threshold',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteThreshold() {
        this.showConfirmDelete = true;
    }

    // Saved Entry
    savedThreshold(event) {

        this.loading = false;

        // Send saved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Pricing Threshold was saved',
                        variant: 'success'
                    },
                    selected: {
                        pricebook: this.selected.pricebook,
                        pricebookName: this.selected.pricebookName,
                        pricebookTab: 'pricingSets',
                        pricingSet: this.selected.pricingSet,
                        pricingSetName: this.selected.pricingSetName,
                        pricingSetTab: 'pricingThresholds',
                        pricingThreshold: event.detail.id,
                        pricingThresholdTab: 'pricingThreshold'
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the pricing threshold',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Submit
    submitThreshold() {
        this.loading = true;
    }

    // Clone record
    async cloneThreshold() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.pricingThreshold.Id,
                objectAPI: 'CPQ_Pricing_Threshold__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Pricing Threshold was cloned',
                            variant: 'success'
                        },
                        selected: {
                            pricebook: this.selected.pricebook,
                            pricebookName: this.selected.pricebookName,
                            pricebookTab: 'pricingSets',
                            pricingSet: this.selected.pricingSet,
                            pricingSetName: this.selected.pricingSetName,
                            pricingSetTab: 'pricingThresholds',
                            pricingThreshold: newRecord.Id,
                            pricingThresholdTab: 'pricingThreshold'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the pricing threshold',
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