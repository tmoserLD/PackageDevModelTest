import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

// Get Question Type Method
import getQuestionType from '@salesforce/apex/cpq_AdminContainerClass.getQuestionType';

// Get Product Field Type Method
import getFieldType from '@salesforce/apex/cpq_AdminContainerClass.getFieldType';

// Get Lookup Field Type Method
import getLookupFieldType from '@salesforce/apex/cpq_AdminContainerClass.getLookupFieldType';
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

    // Question Id
    @track questionId;

    // Question Type
    @track questionType;

    // Source Type
    @track source;

    // Product Field
    @track productField;

    // Product Field Type
    @track productFieldType;

    // Product is Entitlement value
    @track entitlementValue;

    // Record Lookup Field
    @track recordLookupField;

    // Record Lookup Field Type
    @track recordLookupType;

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
            this.questionId = this.criterion.criterionInfo.CPQ_Playbook_Question__c;
            if (this.criterion.criterionInfo.CPQ_Playbook_Question__c !== undefined) {
                this.questionType = this.criterion.criterionInfo.CPQ_Playbook_Question__r.Answer_Type__c;
            }
            this.productField = this.criterion.criterionInfo.Product_Field__c;
            this.productFieldType = this.criterion.criterionInfo.Product_Field_Type__c;
            this.entitlementValue = this.criterion.criterionInfo.Product_Is_Entitlement__c;
            this.recordLookupField = this.criterion.criterionInfo.Record_Lookup_Field__c;
            this.recordLookupType = this.criterion.criterionInfo.Record_Lookup_Field_Type__c;
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
        return (this.questionType === 'Boolean' || this.productFieldType === 'Boolean' || this.recordLookupType === 'Boolean');
    }

    // Currency input type
    get isCurrency() {
        return (this.questionType === 'Currency' || this.productFieldType === 'Currency' || this.recordLookupType === 'Currency');
    }

    // Date input type
    get isDate() {
        return (this.questionType === 'Date' || this.productFieldType === 'Date' || this.recordLookupType === 'Date');
    }

    // Decimal input type
    get isDecimal() {
        return (this.questionType === 'Decimal' || this.productFieldType === 'Decimal' || this.recordLookupType === 'Decimal');
    }

    // Integer input type
    get isInteger() {
        return (this.questionType === 'Integer' || this.productFieldType === 'Integer' || this.recordLookupType === 'Integer');
    }

    // Text input type
    get isText() {
        return (['Picklist', 'Multi-Select Picklist', 'Text', 'Text Area'].includes(this.questionType) || this.productFieldType === 'Text' || this.recordLookupType === 'Text');
    }

    // Record Lookup Type
    get isRecordLookup() {
        return this.questionType === 'Record Lookup';
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
    async prodFieldChange(event) {
        this.productField = event.target.value;

        let cpqFields = {
            'Product_Name' : 'Text',
            'Start_Date' : 'Date',
            'End_Date' : 'Date',
            'Quantity' : 'Decimal',
            'Discount' : 'Decimal',
            'Unit_Price' : 'Currency',
            'List_Price' : 'Currency',
            'Sub_Total_Price' : 'Currency',
            'Total_Price' : 'Currency'
        };
        if (cpqFields[this.productField] !== undefined &&
            this.entitlementValue !== true    
        ) {
            this.productFieldType = cpqFields[this.productField];
        } else {

            if (event.target.value !== undefined &&
                event.target.value !== null &&
                event.target.value !== ''    
            ) {
                this.loading = true;
                try {
                    this.productFieldType = await getFieldType({
                        field: this.productField,
                        objectName: this.entitlementValue === true ? 'Contract_Entitlement__c' : 'QuoteLineItem'
                    });
                } catch (e) {
                    this.template.querySelector('c-error-modal').showError(
                        {
                            title: 'An error occurred while trying to retrieve the new product field type',
                            body: JSON.stringify(e),
                            forceRefresh: false
                        }
                    );
                }
                this.loading = false;
            } else {
                this.productFieldType = undefined;
            }
        }
    }

    // Entitlement change
    entitlementChange(event) {
        this.entitlementValue = event.target.value;

        this.prodFieldChange(
            {
                target: {
                    value: this.productField
                }
            }
        );
    }

    // Record Lookup Field Type changed
    async recordLookupFieldChange(event) {
        this.recordLookupField = event.target.value;

        if (event.target.value !== undefined &&
            event.target.value !== null &&
            event.target.value !== ''    
        ) {
            this.loading = true;
            try {
                this.recordLookupType = await getLookupFieldType({
                    field: this.recordLookupField,
                    questionId: this.questionId
                });
            } catch (e) {
                this.template.querySelector('c-error-modal').showError(
                    {
                        title: 'An error occurred while trying to retrieve the new record lookup field type',
                        body: JSON.stringify(e),
                        forceRefresh: false
                    }
                );
            }
            this.loading = false;
        } else {
            this.recordLookupType = undefined;
        }
    }

    // Source Changed
    sourceChange(event) {
        this.source = event.target.value;
        if (this.source !== 'Question') {
            this.questionId = undefined;
            this.questionType = undefined;
            this.recordLookupType = undefined;
        } else {
            if (this.criterion !== undefined) {
                this.questionId = this.criterion.criterionInfo.CPQ_Playbook_Question__c;
                this.questionType = this.criterion.criterionInfo.CPQ_Playbook_Question__r?.Answer_Type__c;
                this.recordLookupType = this.criterion.criterionInfo.Record_Lookup_Field_Type__c;
            }
        }
        if (this.source !== 'Product') {
            this.productFieldType = undefined;
        } else {
            if (this.criterion !== undefined) {
                this.productFieldType = this.criterion.criterionInfo.Product_Field_Type__c;
            }
        }
    }

    // Question Changed
    async questionChange(event) {
        this.questionId = event.target.value;

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