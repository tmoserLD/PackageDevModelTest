import { LightningElement, api, track } from 'lwc';

// Get Question Type Method
import getQuestionType from '@salesforce/apex/cpq_AdminContainerClass.getQuestionType';

// Get Product Field Type Method
import getFieldType from '@salesforce/apex/cpq_AdminContainerClass.getFieldType';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

export default class CPQ_AdminRuleActionForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Action
    @api action;

    // Action Id
    @api actionId;

    // Object containing selections for all levels
    @api selected;

    // Action type
    @track actionType;

    // Spinner
    @track loading = false;

    // Question Type
    @track questionType;

    // Question Adjustment Field
    @track questionAdjustmentField;

    // Question Group Adjustment Field
    @track questionGroupAdjustmentField;

    // Text value for question
    @track questionText;

    // Source Type
    @track source;

    // Product Field
    @track productField;

    // Product Field Type
    @track productFieldType;

    // Manual Target
    @track manualTarget = false;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this rule action?';

    // On Mount
    connectedCallback() {
        if (this.action !== undefined) {
            this.actionType = this.action.actionInfo.Action_Type__c;
            this.source = this.action.actionInfo.Value_Source_Type__c;
            if (this.action.actionInfo.CPQ_Playbook_Question__c !== undefined) {
                this.questionType = this.action.actionInfo.CPQ_Playbook_Question__r.Answer_Type__c;
            }
            this.productField = this.action.actionInfo.Product_Adjustment_Field__c;
            this.productFieldType = this.action.actionInfo.Product_Adjustment_Field_Type__c;
            this.questionAdjustmentField = this.action.actionInfo.Question_Adjustment_Field__c;
            this.questionGroupAdjustmentField = this.action.actionInfo.Question_Group_Adjustment_Field__c;
            this.manualTarget = this.action.actionInfo.Target_Manual_Addition_Only__c;
            this.questionText = this.action.actionInfo.Question_Field_Value_Text__c;
        }
    }

    get hasId() {
        return this.action !== undefined;
    }

    // Action Types
    get adjustQuestionFieldType() {
        return this.actionType === 'Adjust question field';
    }

    get adjustQuestionGroupFieldType() {
        return this.actionType === 'Adjust question group field';
    }

    get questionFieldTypes() {
        return ['Adjust question field', 'Adjust question group field'].includes(this.actionType);
    }

    get productType() {
        return ['Adjust product field', 'Add product'].includes(this.actionType);
    }

    get adjustProductFieldType() {
        return this.actionType === 'Adjust product field';
    }

    get sourcedActions() {
        return ['Adjust product field', 'Adjust question field', 'Adjust question group field'].includes(this.actionType);
    }

    get ruleId() {
        return this.selected.rule.split('-')[0];
    }

    // Source Types
    get dynamicSource() {
        return this.source === 'Dynamic';
    }

    get staticSource() {
        return this.source === 'Static';
    }

    // Question Types
    // Boolean input type
    get isBoolean() {
        return (
                (
                    this.actionType === 'Adjust question field' &&
                    (
                        (
                            this.questionType === 'Boolean' &&
                            this.questionAdjustmentField === 'answer'
                        ) ||
                        this.questionAdjustmentField === 'IsHidden__c' ||
                        this.questionAdjustmentField === 'IsRequired__c' ||
                        this.questionAdjustmentField === 'IsReadOnly__c'
                    )
                ) ||
                (
                    this.actionType === 'Adjust question group field' &&
                    this.questionGroupAdjustmentField === 'IsHidden__c'
                )
        );
    }

    // Currency input type
    get isCurrency() {
        return (
            this.actionType === 'Adjust question field' &&
            this.questionType === 'Currency' &&
            this.questionAdjustmentField === 'answer'
        );
    }

    // Date input type
    get isDate() {
        return (
            this.actionType === 'Adjust question field' &&
            this.questionType === 'Date' &&
            this.questionAdjustmentField === 'answer'
        );
    }

    // Decimal input type
    get isDecimal() {
        return (
            this.actionType === 'Adjust question field' &&
            (
                (
                    this.questionType === 'Decimal' &&
                    this.questionAdjustmentField === 'answer'
                ) ||
                this.questionAdjustmentField === 'Minimum_Value__c' ||
                this.questionAdjustmentField === 'Maximum_Value__c' ||
                this.questionAdjustmentField === 'Maximum_Record_Selections__c' ||
                this.questionAdjustmentField === 'Step_Value__c'
            ) 
        );
    }

    // Integer input type
    get isInteger() {
        return (
            this.actionType === 'Adjust question field' &&
            this.questionType === 'Integer' &&
            this.questionAdjustmentField === 'answer'
        );
    }

    // Text input type
    get isText() {
        return (
            this.actionType === 'Adjust question field' &&
            (
                (
                    ['Picklist', 'Multi-Select Picklist', 'Text', 'Text Area'].includes(this.questionType) &&
                    this.questionAdjustmentField === 'answer'
                ) ||
                this.questionAdjustmentField === 'Quote_Save_Field__c' ||
                this.questionAdjustmentField === 'Query_String__c'
            )
        );
    }

    // Picklist Answers
    get isPicklistAnswer() {
        return (
            this.actionType === 'Adjust question field' &&
            this.questionAdjustmentField === 'Picklist_Answers__c'
        );
    }

    // Product Field Types
    // Boolean input type
    get isBooleanProd() {
        return (
            this.actionType === 'Adjust product field' &&
            this.productFieldType === 'Boolean'
        );
    }

    // Currency input type
    get isCurrencyProd() {
        return (
            this.actionType === 'Adjust product field' &&
            this.productFieldType === 'Currency'
        );
    }

    // Date input type
    get isDateProd() {
        return (
            this.actionType === 'Adjust product field' &&
            this.productFieldType === 'Date'
        );
    }

    // Decimal input type
    get isDecimalProd() {
        return (
            this.actionType === 'Adjust product field' &&
            this.productFieldType === 'Decimal'
        );
    }

    // Integer input type
    get isIntegerProd() {
        return (
            this.actionType === 'Adjust product field' &&
            this.productFieldType === 'Integer'
        );
    }

    // Text input type
    get isTextProd() {
        return (
            this.actionType === 'Adjust product field' &&
            this.productFieldType === 'Text'
        );
    }

    // Number type for prod and question
    get isNumber() {
        return (
            (
                this.actionType === 'Adjust product field' &&
                (
                    this.productFieldType === 'Currency' ||
                    this.productFieldType === 'Decimal' ||
                    this.productFieldType === 'Integer'
                 )
            ) ||
            (
                this.actionType === 'Adjust question field' &&
                (this.questionType === 'Integer' &&
                    this.questionAdjustmentField === 'answer'
                ) ||
                (
                    (
                        this.questionType === 'Decimal' &&
                        this.questionAdjustmentField === 'answer'
                    ) ||
                    this.questionAdjustmentField === 'Minimum_Value__c' ||
                    this.questionAdjustmentField === 'Maximum_Value__c' ||
                    this.questionAdjustmentField === 'Step_Value__c'   
                ) ||
                (this.questionType === 'Currency' &&
                    this.questionAdjustmentField === 'answer'
                )
            )
        );
    }

    // Action Type Change
    actionTypeChange(event) {
        this.actionType = event.target.value;
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
                records: [this.action.actionInfo]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Rule Action was deleted',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'rules',
                            rule: this.selected.rule,
                            ruleName: this.selected.ruleName,
                            ruleTab: 'actions',
                            ruleAction: undefined,
                            ruleActionName: undefined,
                            ruleActionTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the rule action',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteAction() {
        this.showConfirmDelete = true;
    }

    // Saved Action
    savedAction(event) {

        this.loading = false;

        // Send childsaved event to parent
        const childSavedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Rule Action was saved',
                        variant: 'success'
                    },
                    selected: {
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'rules',
                        rule: this.selected.rule,
                        ruleName: this.selected.ruleName,
                        ruleTab: 'actions',
                        ruleAction: event.detail.id,
                        ruleActionTab: 'action'
                    }
                }
            });
        this.dispatchEvent(childSavedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the rule action',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Submit
    submitAction() {
        this.loading = true;
    }

    // Clone record
    async cloneAction() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.action.actionInfo.Id,
                objectAPI: 'CPQ_Playbook_Rule_Action__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Rule Action was cloned',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'rules',
                            rule: this.selected.rule,
                            ruleName: this.selected.ruleName,
                            ruleTab: 'actions',
                            ruleAction: newRecord.Id,
                            ruleActionName: newRecord.Name,
                            ruleActionTab: 'action'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the rule action',
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

    // Source Changed
    sourceChange(event) {
        this.source = event.target.value;
    }

    // Product Field changed
    async productFieldChange(event) {
        this.productField = event.target.value;

        let cpqFields = {
            'Start_Date' : 'Date',
            'End_Date' : 'Date',
            'Quantity' : 'Decimal',
            'Discount' : 'Decimal',
            'Unit_Price' : 'Currency',
            'List_Price' : 'Currency',
            'Quantity_Editable' : 'Boolean',
            'Dates_Editable' : 'Boolean',
            'Discountable' : 'Boolean',
            'List_Price_Editable' : 'Boolean',
            'Manually_Addible' : 'Boolean',
            'Removable' : 'Boolean'
        };
        if (cpqFields[this.productField] !== undefined) {
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
                        objectName: 'QuoteLineItem'
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

    // Question Field change
    questionAdjustmentFieldChange(event) {
        this.questionAdjustmentField = event.target.value;
    }

    // Question Group Field change
    questionGroupAdjustmentFieldChange(event) {
        this.questionGroupAdjustmentField = event.target.value;
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

    // Manual Target Change
    manualTargetChange() {
        this.manualTarget = !this.manualTarget;
    }

    // Picklist Answers Change
    picklistAnswersChange(event) {
        let vals = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            vals = selectedOptions.join(';');
        }

        this.questionText = vals;
    }

    // Question Text Change
    questionTextChange(event) {
        this.questionText = event.target.value;
    }
}