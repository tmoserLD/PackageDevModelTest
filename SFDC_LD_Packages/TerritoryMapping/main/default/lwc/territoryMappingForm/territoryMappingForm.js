import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/TerritoryMapping.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/TerritoryMapping.deleteRecords';

export default class TerritoryMappingForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Mapping
    @api mapping;

    // Mapping Id
    @api mappingId;

    // Object currently selected
    @api object;

    // Spinner
    @track loading = false;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this mapping?';

    get hasId() {
        return this.mapping !== undefined;
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
                records: [this.mapping.mapping]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Mapping was deleted',
                            variant: 'success'
                        },
                        selected: {
                            mapping: undefined,
                            mappingTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the mapping',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteMapping() {
        this.showConfirmDelete = true;
    }

    // Saved Mapping
    savedMapping(event) {

        this.loading = false;

        // Send saved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Mapping was saved',
                        variant: 'success'
                    },
                    selected: {
                        mapping: event.detail.id,
                        mappingTab: 'mapping'
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the mapping',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Clone record
    async cloneMapping() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.mapping.mapping.Id,
                objectAPI: 'Territory_Mapping__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Mapping was cloned',
                            variant: 'success'
                        },
                        selected: {
                            mapping: newRecord.Id,
                            mappingTab: 'mapping'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the mapping',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Submit
    submitMapping() {
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