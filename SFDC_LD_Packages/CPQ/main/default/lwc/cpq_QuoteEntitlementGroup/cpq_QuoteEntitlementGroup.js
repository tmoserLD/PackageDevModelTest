import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteEntitlementGroup extends LightningElement {

    // Group
    @api group;

    // Columns
    @api columnsToDisplay;

    // Contract Currency
    @api contractCurrency;

    // Currency Conversion Map
    @api currencyMap = {};

    // Field being grouped
    @api fieldLabel;

    // Type of field being grouped
    @api fieldType;

    // Opp Currency
    @api oppCurrency;

    // Value
    get value() {
        let val = this.group.value;
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

}