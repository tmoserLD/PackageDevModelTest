import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteEntitlementColumn extends LightningElement {

    // Column
    @api column;

    // Contract Currency
    @api contractCurrency;

    // Currency Conversion Map
    @api currencyMap = {};

    // Entitlement
    @api entitlement;

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Value
    get value() {
        let val = this.entitlement[this.column.field];
        return val;
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
}