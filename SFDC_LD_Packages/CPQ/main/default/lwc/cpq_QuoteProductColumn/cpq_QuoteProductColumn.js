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

        if (this.column.field === 'Quantity' &&
            this.product.Quantity_Editable === true
        ) {
            isEditable = true;
        }
        else if (this.column.field === 'Unit_Price' &&
            this.product.Discountable === true
        ) {
            isEditable = true;
        }
        else if (this.column.field === 'List_Price' &&
            this.product.List_Price_Editable === true
        ) {
            isEditable = true;
        }

        if (this.configType.includes('View')) {
            isEditable = false;
        }

        return isEditable;
    }

    // Quantity
    get isQuantity() {
        return this.column.field === 'Quantity';
    }

    // Unit Price
    get isUnitPrice() {
        return this.column.field === 'Unit_Price';
    }

    // List Price
    get isListPrice() {
        return this.column.field === 'List_Price';
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
            }, this);
        }
    }

    // Value change
    valueChange(event) {
        let newValue = event.detail.value;
        if (newValue &&
            newValue !== '' &&
            newValue >= 0
        ) {
            const updateEvent = new CustomEvent(
                'update', {
                    detail: {
                        key: this.product.key,
                        attribute: this.column.field,
                        newValue: newValue
                    }
                });
            this.dispatchEvent(updateEvent);
        } else {
            this.template.querySelectorAll('lightning-input').forEach(function(input) {
                input.value = this.product[this.column.field];
            });
        }
    }

}