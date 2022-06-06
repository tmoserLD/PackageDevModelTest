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

    // Quantity
    get isQuantity() {
        return this.column.field === 'Quantity';
    }

    // Value
    get value() {
        let val = this.entitlement[this.column.field];
        if (val !== undefined &&
            val !== null &&
            val !== ''    
        ) {
            if (this.column.type === 'Currency') {
                val = this.convertCurrency(val, this.contractCurrency, this.oppCurrency);
            }
            else if (this.column.type === 'Percent') {
                val = val / 100;
            }
        }
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

    // Currency Conversion
    convertCurrency(value, fromISO, toISO) {
        let rate = 1;
        if (this.currencyMap[toISO] !== undefined &&
            this.currencyMap[fromISO] !== undefined
        ) {
            this.currencyMap[toISO] / this.currencyMap[fromISO]
        }
        return value * rate;
    }
}