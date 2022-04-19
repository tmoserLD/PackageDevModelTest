import { LightningElement, api } from 'lwc';

export default class CPQ_QuoteListItemColumn extends LightningElement {

    // Column
    @api column;

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Quote
    @api quote;

    // Value
    get value() {
        return this.quote[this.column.field];
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