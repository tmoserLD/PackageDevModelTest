import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/TerritoryMapping.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/TerritoryMapping.deleteRecords';

export default class TerritoryMappingConditionSetForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Set
    @api set;

    // Set Id
    @api setId;

    // Object containing selections for all levels
    @api selected;

    // Spinner
    @track loading = false;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this condition set?';

    get hasId() {
        return this.set !== undefined;
    }

    get mappingId() {
        return this.selected.mapping;
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
                records: [this.set]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Condition Set was deleted',
                            variant: 'success'
                        },
                        selected: {
                            mapping: this.selected.mapping,
                            mappingTab: 'conditionSets',
                            conditionSet: undefined,
                            conditionSetTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the condition set',
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

    // Saved Set
    savedSet(event) {

        this.loading = false;

        // Send saved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Condition Set was saved',
                        variant: 'success'
                    },
                    selected: {
                        mapping: this.selected.mapping,
                        mappingTab: 'conditionSets',
                        conditionSet: event.detail.id,
                        conditionSetTab: 'set'
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the condition set',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Clone record
    async cloneSet() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.set.Id,
                objectAPI: 'Territory_Mapping_Condition_Set__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Condition Set was cloned',
                            variant: 'success'
                        },
                        selected: {
                            mapping: this.selected.mapping,
                            mappingTab: 'conditionSets',
                            conditionSet: newRecord.Id,
                            conditionSetTab: 'set'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the condition set',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Submit
    submitSet() {
        this.loading = true;
    }

    cancel() {
        // Send cancel event to parent
        const cancelEvent = new CustomEvent(
            'cancel'
        );
        this.dispatchEvent(cancelEvent);
    }

}