import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProductGroup extends LightningElement {

    // Group
    @api group;

    // Columns
    @api columnsToDisplay;

    // Config Type
    @api configType;

    // Field being grouped
    @api fieldLabel;

    // Type of field being grouped
    @api fieldType;

    // Opp Currency
    @api oppCurrency;


    // Value
    get value() {
        let val = this.group.value;
        if (val !== undefined &&
            val !== null &&
            val !== ''    
        ) {
            if (this.fieldType === 'Percent') {
                val = val / 100;
            }
        }
        return val;
    }

    // Determine if groupings exist
    get hasField() {
        return this.fieldLabel !== undefined;
    }

    // Boolean type
    get isBoolean() {
        return this.fieldType === 'Boolean';
    }

    // Currency type
    get isCurrency() {
        return this.fieldType === 'Currency';
    }

    // Date type
    get isDate() {
        return this.fieldType === 'Date';
    }

    // Number type
    get isNumber() {
        return this.fieldType === 'Number';
    }

    // Percent type
    get isPercent() {
        return this.fieldType === 'Percent';
    }

    // Text type
    get isText() {
        return this.fieldType === 'Text';
    }


    // Remove Product event
    removeProduct(event) {

        const removeEvent = new CustomEvent(
            'remove', {
                detail: event.detail 
            });
        this.dispatchEvent(removeEvent);

    }

    // Update Product event
    updateProduct(event) {

        const updateEvent = new CustomEvent(
            'update', {
                detail: event.detail
            });
        this.dispatchEvent(updateEvent);
    }
}