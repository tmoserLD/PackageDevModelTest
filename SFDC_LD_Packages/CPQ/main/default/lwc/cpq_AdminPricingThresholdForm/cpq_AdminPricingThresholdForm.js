import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

// Update Method
import updateRecords from '@salesforce/apex/cpq_AdminContainerClass.updateRecords';

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

    // Unit Price
    @track unitPrice;

    // Unit Price trimmed to 2 decimal places
    @track unitPriceTrimmed;

    // On Mount
    connectedCallback() {
        if (this.pricingThreshold !== undefined) {
            this.unitPrice = this.pricingThreshold.Unit_Price__c;
            this.unitPriceTrimmed = Math.round(this.unitPrice * 100) / 100;
        }
    }


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
    async savedThreshold(event) {

        // Send update DML for unit price since SFDC is not allowing more than 2 decimal places
        // But the field is setup to accept up to 6......

        try {
            await updateRecords({
                records: [{
                    Id: this.pricingThreshold.Id,
                    Unit_Price__c: this.unitPrice
                }]
            });

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
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to save the pricing threshold',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
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

    // Unit Price Changed
    unitPriceChange(event) {
        this.unitPrice = event.target.value;
        this.unitPriceTrimmed = Math.round(this.unitPrice * 100) / 100;
    }

}