import { LightningElement, api, track } from 'lwc';

export default class CPQ_PlaybookViewFields extends LightningElement {

    @api configType;
    @api contractId;
    @api playbook;
    @api quoteEndDate;
    @api quoteStartDate;
    @api quoteId;

    get displayFieldSets() {
        let displayFieldSets = [];
        let currentFieldSet = {
            label: undefined,
            fields: [],
            index: 0
        };
        if (this.playbook !== undefined) {

            // Quote Display Fields
            if (this.recordId !== undefined &&
                this.recordId.startsWith('0Q0') &&
                this.playbook.playbookInfo.Quote_View_Display_Fields__c !== undefined
            ) {
                this.playbook.playbookInfo.Quote_View_Display_Fields__c.split(';').forEach(function(field) {
                    if (field.startsWith('#')) {
                        if (currentFieldSet.fields.length > 0) {
                            displayFieldSets.push(JSON.parse(JSON.stringify(currentFieldSet)));
                        }
                        if (field !== '#') {
                            currentFieldSet.label = field.substring(1);
                            currentFieldSet.hasBlankLabel = false;
                            currentFieldSet.hasLabel = true;
                        } else {
                            currentFieldSet.label = undefined;
                            currentFieldSet.hasBlankLabel = true;
                            currentFieldSet.hasLabel = false;
                        }
                        currentFieldSet.fields = [];
                        currentFieldSet.index = displayFieldSets.length;
                    } else {
                        currentFieldSet.fields.push(field);
                    }
                }, this);
            }

            // Contract Display Fields
            if (this.recordId !== undefined &&
                this.recordId.startsWith('800') &&
                this.playbook.playbookInfo.Contract_View_Display_Fields__c !== undefined
            ) {
                this.playbook.playbookInfo.Contract_View_Display_Fields__c.split(';').forEach(function(field) {
                    if (field.startsWith('#')) {
                        if (currentFieldSet.fields.length > 0) {
                            displayFieldSets.push(JSON.parse(JSON.stringify(currentFieldSet)));
                        }
                        if (field !== '#') {
                            currentFieldSet.label = field.substring(1);
                            currentFieldSet.hasBlankLabel = false;
                            currentFieldSet.hasLabel = true;
                        } else {
                            currentFieldSet.label = undefined;
                            currentFieldSet.hasBlankLabel = true;
                            currentFieldSet.hasLabel = false;
                        }
                        currentFieldSet.fields = [];
                        currentFieldSet.index = displayFieldSets.length;
                    } else {
                        currentFieldSet.fields.push(field);
                    }
                }, this);
            }

            if (currentFieldSet.fields.length > 0) {
                displayFieldSets.push(JSON.parse(JSON.stringify(currentFieldSet)));
            }
        }

        return displayFieldSets;
    }

    get displayObj() {
        let displayObj;

        // Quote
        if (this.recordId !== undefined &&
            this.recordId.startsWith('0Q0')
        ) {
            displayObj = 'Quote';
        }

        // Contract
        if (this.recordId !== undefined &&
            this.recordId.startsWith('800')
        ) {
            displayObj = 'Contract';
        }

        return displayObj;
    }

    get recordId() {
        return this.quoteId !== undefined ? this.quoteId : this.contractId;
    }

    get viewMode() {
        return this.configType.includes('View');
    }
}