import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

// Get Question Type Method
import getQuestionType from '@salesforce/apex/cpq_AdminContainerClass.getQuestionType';
export default class CPQ_AdminApprovalCriterionForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Criterion
    @api criterion;

    // Criterion Id
    @api criterionId;

    // Evaluation Logic
    @track evalLogic;

    // Spinner
    @track loading = false;

    // Question Type
    @track questionType;

    // Source Type
    @track source;

    // Product Field
    @track prodField;

    // Manual target
    @track manualTarget = false;

    // Object containing selections for all levels
    @api selected;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this criteria group?';

    connectedCallback() {
        if (this.criterion !== undefined) {
            this.evalLogic = this.criterion.criterionInfo.Evaluation_Logic__c;
            this.source = this.criterion.criterionInfo.Criterion_Source__c;
            if (this.criterion.criterionInfo.CPQ_Playbook_Question__c !== undefined) {
                this.questionType = this.criterion.criterionInfo.CPQ_Playbook_Question__r.Answer_Type__c;
            }
            this.prodField = this.criterion.criterionInfo.Product_Field__c;
            this.manualTarget = this.criterion.criterionInfo.Target_Manual_Addition_Only__c;
        }
    }

    get hasId() {
        return this.criterion !== undefined;
    }

    // N Evaluation Type
    get n_Eval() {
        if (this.evalLogic !== undefined) {
            return this.evalLogic.includes('N required');
        } else {
            return false;
        }
    }

    get groupId() {
        return this.selected.approvalCriteriaGroup.split('-')[0];
    }

    // Source Types
    get questionSource() {
        return this.source === 'Question';
    }

    get productSource() {
        return this.source === 'Product';
    }

    get systemSource() {
        return this.source === 'System Value';
    }

    // Question Types
    // Boolean input type
    get isBoolean() {
        return this.questionType === 'Boolean';
    }

    // Currency input type
    get isCurrency() {
        return (this.questionType === 'Currency' || ['List Price', 'Unit Price', 'Total Price'].includes(this.prodField));
    }

    // Date input type
    get isDate() {
        return (this.questionType === 'Date' || ['Start Date', 'End Date'].includes(this.prodField));
    }

    // Decimal input type
    get isDecimal() {
        return (this.questionType === 'Decimal' || ['Discount'].includes(this.prodField));
    }

    // Integer input type
    get isInteger() {
        return (this.questionType === 'Integer' || ['Quantity'].includes(this.prodField));
    }

    // Text input type
    get isText() {
        return ['Picklist', 'Multi-Select Picklist', 'Text', 'Text Area'].includes(this.questionType);
    }

    // Evaluation Logic Change
    evalLogicChange(event) {
        this.evalLogic = event.target.value;
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
                records: [this.criterion.criterionInfo]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Criterion was deleted',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'approvals',
                            approval: this.selected.approval,
                            approvalName: this.selected.approvalName,
                            approvalTab: 'criteriaGroups',
                            approvalCriteriaGroup: this.selected.approvalCriteriaGroup,
                            approvalCriteriaGroupName: this.selected.approvalCriteriaGroupName,
                            approvalCriteriaGroupTab: 'criteria',
                            approvalCriteriaGroupCriterion: undefined,
                            approvalCriteriaGroupCriterionName: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the criterion',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteCriterion() {
        this.showConfirmDelete = true;
    }

    // Saved Criterion
    savedCriterion(event) {

        this.loading = false;

        // Send childsaved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Criterion was saved',
                        variant: 'success'
                    },
                    selected: {
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'approvals',
                        approval: this.selected.approval,
                        approvalName: this.selected.approvalName,
                        approvalTab: 'criteriaGroups',
                        approvalCriteriaGroup: this.selected.approvalCriteriaGroup,
                        approvalCriteriaGroupName: this.selected.approvalCriteriaGroupName,
                        approvalCriteriaGroupTab: 'criteria',
                        approvalCriteriaGroupCriterion: event.detail.id
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the criterion',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Submit
    submitCriterion() {
        this.loading = true;
    }

    // Clone record
    async cloneCriterion() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.criterion.criterionInfo.Id,
                objectAPI: 'CPQ_Playbook_Approval_Criterion__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Criterion was cloned',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'approvals',
                            approval: this.selected.approval,
                            approvalName: this.selected.approvalName,
                            approvalTab: 'criteriaGroups',
                            approvalCriteriaGroup: this.selected.approvalCriteriaGroup,
                            approvalCriteriaGroupName: this.selected.approvalCriteriaGroupName,
                            approvalCriteriaGroupTab: 'criteria',
                            approvalCriteriaGroupCriterion: newRecord.Id,
                            approvalCriteriaGroupCriterionName: newRecord.Name,
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the criterion',
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

    // Product Field changed
    prodFieldChange(event) {
        this.prodField = event.target.value;
    }

    // Source Changed
    sourceChange(event) {
        this.source = event.target.value;
        if (this.source !== 'Question') {
            this.questionType = undefined;
        }
        if (this.source !== 'Product') {
            this.prodField = undefined;
        }
    }

    // Question Changed
    async questionChange(event) {
        if (event.target.value !== undefined &&
            event.target.value !== null &&
            event.target.value !== ''    
        ) {
            this.loading = true;
            try {
                this.questionType = await getQuestionType({
                    questionId: event.target.value
                });
            } catch (e) {
                this.template.querySelector('c-error-modal').showError(
                    {
                        title: 'An error occurred while trying to retrieve the new question answer type',
                        body: JSON.stringify(e),
                        forceRefresh: false
                    }
                );
            }
            this.loading = false;
        } else {
            this.questionType = undefined;
        }
    }

    // Manual Target Changed
    manualTargetChange(event) {
        this.manualTarget = !this.manualTarget;
    }
}