import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProductColumn extends LightningElement {

    // Column
    @api column;

    // Configuration Type
    @api configType;

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Product
    @api product;

    // Editable
    get isEditable() {
        let isEditable = false;

        if (this.product.Adjustable_Product_Columns__c.includes(this.column.field)) {
            isEditable = true;
        }

        if (this.configType.includes('View')) {
            isEditable = false;
        }

        return isEditable;
    }

    // Value
    get value() {
        return this.product[this.column.field];
    }

    // Boolean type
    get isBoolean() {
        return this.column.type === 'Boolean';
    }

    // Currency type
    get isCurrency() {
        return this.column.type === 'Currency';
    }

    // Date type
    get isDate() {
        return this.column.type === 'Date';
    }

    // Number type
    get isNumber() {
        return this.column.type === 'Number';
    }

    // Percent type
    get isPercent() {
        return this.column.type === 'Percent';
    }

    // Text type
    get isText() {
        return this.column.type === 'Text';
    }

    // Parent update value
    @api updateValue(field, newValue) {
        if (field === this.column.field) {
            this.template.querySelectorAll('lightning-input').forEach(function(input) {
                input.value = newValue;
                if (this.column.type === 'Boolean') {
                    input.checked = newValue;
                }
            }, this);
        }
    }

    // Value change
    valueChange(event) {
        let value;
        this.template.querySelectorAll('lightning-input').forEach(function(input) {
            value = input.value;
            if (this.column.type === 'Boolean') {
                value = input.checked;
            }
        }, this);
        const updateEvent = new CustomEvent(
            'update', {
                detail: {
                    key: this.product.key,
                    attribute: this.column.field,
                    newValue: value
                }
            }
        );
        this.dispatchEvent(updateEvent);
    }

}