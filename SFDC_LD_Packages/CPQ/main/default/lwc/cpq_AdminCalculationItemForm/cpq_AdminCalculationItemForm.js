import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

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

    // Entitlement Type
    @track entitlement = false;

    // Spinner
    @track loading = false;

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
            this.staticType = this.item.itemInfo.Static_Value_Type__c;
        }
    }

    get hasId() {
        return this.item !== undefined;
    }

    get actionId() {
        return this.selected.ruleAction.split('-')[0];
    }

    // Source Types
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
        return ['Picklist', 'Multi-Select Picklist', 'Text', 'Text Area'].includes(this.staticType);
    }

    // Entitlement Type
    get prodEntitlement() {
        return this.entitlement;
    }

    // Product Change
    productChange(event) {
        this.hasProduct = (event.target.value !== undefined && event.target.value !== '' && event.target.value !== null);
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