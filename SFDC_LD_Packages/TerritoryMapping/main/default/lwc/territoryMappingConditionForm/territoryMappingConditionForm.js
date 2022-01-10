import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/TerritoryMapping.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/TerritoryMapping.deleteRecords';

export default class TerritoryMappingConditionForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Condition
    @api condition;

    // Condition Id
    @api conditionId;

    // Object containing selections for all levels
    @api selected;

    // Spinner
    @track loading = false;

    // Eligible Values
    @track eligibleValues;

    // Ineligible Values
    @track ineligibleValues;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this condition?';

    // On Mount
    connectedCallback() {
        if (this.condition !== undefined) {
            this.eligibleValues = this.condition.Eligible_Values__c;
            this.ineligibleValues = this.condition.Ineligible_Values__c;
        }
    }

    get hasId() {
        return this.condition !== undefined;
    }

    get setId() {
        return this.selected.conditionSet;
    }

    // Eligible Values Change
    eligibleValuesChange(event) {
        let vals = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            vals = selectedOptions.join(';');
        }

        this.eligibleValues = vals;
    }

    // Inligible Values Change
    ineligibleValuesChange(event) {
        let vals = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            vals = selectedOptions.join(';');
        }

        this.ineligibleValues = vals;
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
                records: [this.condition]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Condition was deleted',
                            variant: 'success'
                        },
                        selected: {
                            mapping: this.selected.mapping,
                            mappingTab: 'conditionSets',
                            conditionSet: this.selected.conditionSet,
                            conditionSetTab: 'conditions'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the condition',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteCondition() {
        this.showConfirmDelete = true;
    }

    // Saved Condition
    savedCondition(event) {

        this.loading = false;

        // Send saved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Condition was saved',
                        variant: 'success'
                    },
                    selected: {
                        mapping: this.selected.mapping,
                        mappingTab: 'conditionSets',
                        conditionSet: this.selected.conditionSet,
                        conditionSetTab: 'conditions',
                        condition: event.detail.id,
                        conditionTab: 'condition'
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the condition',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Clone record
    async cloneCondition() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.condition.Id,
                objectAPI: 'Territory_Mapping_Condition__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Condition was cloned',
                            variant: 'success'
                        },
                        selected: {
                            mapping: this.selected.mapping,
                            mappingTab: 'conditionSets',
                            conditionSet: this.selected.conditionSet,
                            conditionSetTab: 'conditions',
                            condition: newRecord.Id,
                            conditionTab: 'condition'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the condition',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Submit
    submitCondition() {
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