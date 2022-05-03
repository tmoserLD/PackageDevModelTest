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

export default class CPQ_AdminCalculationItemForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Item
    @api item;

    // Item Id
    @api itemId;

    // Object containing selections for all levels
    @api selected;

    // Source Type
    @track source;

    // Entitlement Field
    @track entitlementField;

    // Product Field
    @track productField;

    // Product Field Type
    @track productFieldType;

    // Entitlement Type
    @track entitlement = false;

    // Record Lookup Field
    @track recordLookupField;

    // Record Lookup Field Type
    @track recordLookupType;

    // Spinner
    @track loading = false;

    // Question Id
    @track questionId;

    // Question Type
    @track questionType;

    // Static Type
    @track staticType;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this calculation item?';


    connectedCallback() {
        if (this.item !== undefined) {
            this.source = this.item.itemInfo.Calculation_Source__c;
            this.entitlement = this.item.itemInfo.Product_Is_Entitlement__c;
            this.productFieldType = this.item.itemInfo.Product_Calculation_Field_Type__c;
            this.productField = this.item.itemInfo.Product_Calculation_Field__c;
            this.entitlementField = this.item.itemInfo.Entitlement_Calculation_Field__c;
            this.staticType = this.item.itemInfo.Static_Value_Type__c;
            this.questionId = this.item.itemInfo.CPQ_Playbook_Question__c;
            if (this.item.itemInfo.CPQ_Playbook_Question__c !== undefined) {
                this.questionType = this.item.itemInfo.CPQ_Playbook_Question__r.Answer_Type__c;
            }
            this.recordLookupType = this.item.itemInfo.Record_Lookup_Field_Type__c;
            this.recordLookupField = this.item.itemInfo.Record_Lookup_Field__c;
        }
    }

    get hasId() {
        return this.item !== undefined;
    }

    get actionId() {
        return this.selected.ruleAction.split('-')[0];
    }

    // Source Types
    get lookupSource() {
        return this.source === 'Question' && this.questionType === 'Record Lookup';
    }

    get productSource() {
        return this.source === 'Product';
    }

    get questionSource() {
        return this.source === 'Question';
    }

    get staticSource() {
        return this.source === 'Static Value';
    }

    // Static Value Types
    // Boolean input type
    get isBoolean() {
        return this.staticType === 'Boolean';
    }

    // Currency input type
    get isCurrency() {
        return this.staticType === 'Currency';
    }

    // Date input type
    get isDate() {
        return this.staticType === 'Date';
    }

    // Decimal input type
    get isDecimal() {
        return this.staticType === 'Decimal';
    }

    // Integer input type
    get isInteger() {
        return this.staticType === 'Integer';
    }

    // Text input type
    get isText() {
        return this.staticType === 'Text';
    }

    // Entitlement Type
    get prodEntitlement() {
        return this.entitlement;
    }


    // Product Field changed
    async productFieldChange(event) {
        if (this.entitlement === true) {
            this.entitlementField = event.target.value;
        } else {
            this.productField = event.target.value;
        }

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
            this.entitlement !== true    
        ) {
            this.productFieldType = cpqFields[this.productField];
        } else {

            if (event.target.value !== undefined &&
                event.target.value !== null &&
                event.target.value !== ''    
            ) {
                this.loading = true;

                let valid = true;
                let obj;
                let field;
                if (this.entitlement === true) {
                    obj = 'Contract_Entitlement__c';
                    if (event.target.value.split('.').length > 1) {
                        obj = 'Product2';
                        field = event.target.value.split('.')[1];

                        if (!['Product__r'].includes(event.target.value.split('.')[0]) ||
                            event.target.value.split('.').length > 2
                        ) {
                            valid = false;
                        }
                    }
                } else {
                    obj = 'QuoteLineItem';
                    if (event.target.value.split('.').length > 1) {
                        obj = event.target.value.split('.')[0];
                        field = event.target.value.split('.')[1];

                        if (!['Product2', 'PricebookEntry'].includes(event.target.value.split('.')[0]) ||
                            event.target.value.split('.').length > 2
                        ) {
                            valid = false;
                        }
                    }
                }
                if (obj === undefined ||
                    obj === null ||
                    obj === ''
                ) {
                    valid = false;
                }
                if (valid) {
                    try {
                        this.productFieldType = await getFieldType({
                            field: field,
                            objectName: obj
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
                } else {
                    this.productFieldType = undefined;
                }
                this.loading = false;
            } else {
                this.productFieldType = undefined;
            }
        }
    }

    // Entitlement change
    entitlementChange(event) {
        this.entitlement = event.target.value;

        this.entitlementField = undefined;
        this.productField = undefined;
        this.productFieldType = undefined;
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
                records: [this.item.itemInfo]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Calculation Item was deleted',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'rules',
                            rule: this.selected.rule,
                            ruleName: this.selected.ruleName,
                            ruleTab: 'actions',
                            ruleAction: this.selected.ruleAction,
                            ruleActionName: this.selected.ruleActionName,
                            ruleActionTab: 'calculationItems',
                            ruleActionCalculationItem: undefined,
                            ruleActionCalculationItemName: undefined,
                            ruleActionCalculationItemTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the calculation item',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteItem() {
        this.showConfirmDelete = true;
    }

    // Saved Item
    savedItem(event) {

        this.loading = false;

        // Send childsaved event to parent
        const childSavedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Rule Calculation Item was saved',
                        variant: 'success'
                    },
                    selected: {
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'rules',
                        rule: this.selected.rule,
                        ruleName: this.selected.ruleName,
                        ruleTab: 'actions',
                        ruleAction: this.selected.ruleAction,
                        ruleActionName: this.selected.ruleActionName,
                        ruleActionTab: 'calculationItems',
                        ruleActionCalculationItem: event.detail.id,
                        ruleActionCalculationItemTab: 'item'
                    }
                }
            });
        this.dispatchEvent(childSavedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the calculation item',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Submit
    submitItem() {
        this.loading = true;
    }

    // Clone record
    async cloneItem() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.item.itemInfo.Id,
                objectAPI: 'CPQ_Playbook_Rule_Calculation_Item__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Rule Calculation Item was cloned',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'rules',
                            rule: this.selected.rule,
                            ruleName: this.selected.ruleName,
                            ruleTab: 'actions',
                            ruleAction: this.selected.ruleAction,
                            ruleActionName: this.selected.ruleActionName,
                            ruleActionTab: 'calculationItems',
                            ruleActionCalculationItem: newRecord.Id,
                            ruleActionCalculationItemName: newRecord.Name,
                            ruleActionCalculationItemTab: 'item'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the calculation item',
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

    // Source changed
    sourceChange(event) {
        this.source = event.target.value;
    }

    // Product Is Entitlement changed
    entitlementChange(event) {
        this.entitlement = event.target.value;
    }

    // Static Value Type change
    staticChange(event) {
        this.staticType = event.target.value;
    }

}