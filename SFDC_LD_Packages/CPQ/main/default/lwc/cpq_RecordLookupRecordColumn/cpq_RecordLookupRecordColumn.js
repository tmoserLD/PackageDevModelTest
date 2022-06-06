import { LightningElement, api, track } from 'lwc';

export default class CPQ_RecordLookupRecordColumn extends LightningElement {

    // Column
    @api column;

    // Currency Iso Code
    @api currency;

    // Record
    @api record;

    // Value
    get value() {
        let val = this.record[this.column.field];
        if (val !== undefined &&
            val !== null &&
            val !== ''
        ) {
            if (this.column.type === 'Percent') {
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
}