import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

export default class CPQ_AdminQuestionForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Question
    @api question;

    // Question Id
    @api questionId;

    // Answer Type
    @track answerType;

    // Spinner
    @track loading = false;

    // Object containing selections for all levels
    @api selected;

    // Picklist Values for picklist answer type
    @track picklistValues;

    // Display Field API names for record lookup answer type
    @track recordDisplayFields;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this question?';
    

    // On Mount
    connectedCallback() {
        if (this.question !== undefined) {
            this.answerType = this.question.questionInfo.Answer_Type__c;
            this.picklistValues = this.question.questionInfo.Picklist_Answers__c;
            this.recordDisplayFields = this.question.questionInfo.Record_Display_Fields__c;
        }
    }

    get groupId() {
        return this.selected.questionGroup.split('-')[0];
    }

    get hasId() {
        return this.question !== undefined;
    }

    // Boolean input type
    get isBoolean() {
        return this.answerType === 'Boolean';
    }

    // Currency input type
    get isCurrency() {
        return this.answerType === 'Currency';
    }

    // Date input type
    get isDate() {
        return this.answerType === 'Date';
    }

    // Decimal input type
    get isDecimal() {
        return this.answerType === 'Decimal';
    }

    // Integer input type
    get isInteger() {
        return this.answerType === 'Integer';
    }

    // Currency, Decimal or Integer input type
    get isNumber() {
        return ['Currency','Decimal','Integer'].includes(this.answerType);
    }

    // Picklist (either) input type
    get isPicklist() {
        return ['Picklist', 'Multi-Select Picklist'].includes(this.answerType);
    }

    // Record Lookup input type
    get isRecordLookup() {
        return this.answerType === 'Record Lookup';
    }

    // Text input type
    get isText() {
        return ['Picklist', 'Multi-Select Picklist', 'Text', 'Text Area', 'Record Lookup'].includes(this.answerType);
    }

    // Answer Type Changed
    answerTypeChange(event) {
        this.answerType = event.target.value;
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
                records: [this.question.questionInfo]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Question was deleted',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'questionGroups',
                            questionGroup: this.selected.questionGroup,
                            questionGroupName: this.selected.questionGroupName,
                            questionGroupTab: 'questions',
                            question: undefined,
                            questionName: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the question',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteQuestion() {
        this.showConfirmDelete = true;
    }

    // Saved Question
    savedQuestion(event) {

        this.loading = false;

        // Send saved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Question was saved',
                        variant: 'success'
                    },
                    selected: {
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'questionGroups',
                        questionGroup: this.selected.questionGroup,
                        questionGroupName: this.selected.questionGroupName,
                        questionGroupTab: 'questions',
                        question: event.detail.id
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the question',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Submit
    submitQuestion() {
        this.loading = true;
    }

    // Picklist Values Change
    picklistValuesChange(event) {
        let vals = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            vals = selectedOptions.join(';');
        }

        this.picklistValues = vals;
    }

    // Display Fields Change
    recordDisplayFieldsChange(event) {
        let fields = '';
        if (event.detail.length > 0) {
            let selectedFields = [];
            event.detail.forEach(function(field) {
                selectedFields.push(field);
            });
            fields = selectedFields.join(';');
        }

        this.recordDisplayFields = fields;
    }

    // Clone record
    async cloneQuestion() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.question.questionInfo.Id,
                objectAPI: 'CPQ_Playbook_Question__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Question was cloned',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'questionGroups',
                            questionGroup: this.selected.questionGroup,
                            questionGroupName: this.selected.questionGroupName,
                            questionGroupTab: 'questions',
                            question: newRecord.Id,
                            questionName: newRecord.Name
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the question',
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