import { LightningElement, api, track } from 'lwc';

export default class CPQ_PlaybookQuestionAnswer extends LightningElement {

    // Question
    @api questionInfo;

    // Configuration Type
    @api configType;

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Toggle for Record Lookup modal
    @track showRecordLookupModal = false;

    @api
    get actionSet() {
        return this.questionInfo.actionSet;
    }
    set actionSet(value) {
        if (this.questionInfo !== undefined) {
            this.template.querySelectorAll('lightning-input').forEach(function(input) {
                input.value = this.questionInfo.answer;
                if (input.type === 'checkbox') {
                    input.checked = this.questionInfo.answer;
                }
            }, this);
            this.template.querySelectorAll('lightning-textarea').forEach(function(input) {
                input.value = this.questionInfo.answer;
            }, this);
            this.template.querySelectorAll('lightning-combobox').forEach(function(input) {
                input.value = this.questionInfo.answer;
            }, this); 
        }
    }

    // Answer Field Info
    get answerFieldInfo() {
        let info = '';
        // Numeric inputs
        if (['Currency','Decimal','Integer'].includes(this.questionInfo.Answer_Type__c)) {
            if (this.questionInfo.Minimum_Value__c !== undefined) {
                info += 'Min Value: ' + this.questionInfo.Minimum_Value__c;
            }
            if (this.questionInfo.Maximum_Value__c !== undefined) {
                if (this.questionInfo.Minimum_Value__c !== undefined) {
                    info += ' | ';
                }
                info += 'Max Value: ' + this.questionInfo.Maximum_Value__c;
            }
            if (this.questionInfo.Step_Value__c !== undefined) {
                if (this.questionInfo.Minimum_Value__c !== undefined ||
                    this.questionInfo.Maximum_Value__c !== undefined
                ) {
                    info += ' | ';
                }
                info += 'Step/Increment: ' + this.questionInfo.Step_Value__c;
            }
        }
        // Record Lookup input
        else if (this.questionInfo.Answer_Type__c === 'Record Lookup') {
            if (this.questionInfo.Maximum_Record_Selections__c !== undefined) {
                info += 'Max Selections: ' + this.questionInfo.Maximum_Record_Selections__c;
            }
        }

        return info;
    }

    // Can answer be modified?
    get isReadOnly() {
        let readOnly = false;
        if (this.questionInfo.IsReadOnly__c === true &&
            this.configType !== 'Admin Edit' &&
            this.configType !== 'Admin New'    
        ) {
            readOnly = true;
        }
        if (this.configType.includes('View')) {
            readOnly = true;
        }
        return readOnly;
    }

    // Boolean input type
    get isBoolean() {
        return this.questionInfo.Answer_Type__c === 'Boolean';
    }

    // Currency input type
    get isCurrency() {
        return this.questionInfo.Answer_Type__c === 'Currency';
    }

    // Date input type
    get isDate() {
        return this.questionInfo.Answer_Type__c === 'Date';
    }

    // Decimal input type
    get isDecimal() {
        return this.questionInfo.Answer_Type__c === 'Decimal';
    }

    // Integer input type
    get isInteger() {
        return this.questionInfo.Answer_Type__c === 'Integer';
    }

    // Number input type
    get isNumber() {
        return ['Integer', 'Decimal', 'Currency'].includes(this.questionInfo.Answer_Type__c);
    }

    // Picklist (either) input type
    get isPicklist() {
        return ['Picklist', 'Multi-Select Picklist'].includes(this.questionInfo.Answer_Type__c);
    }

    // Record Lookup input type
    get isRecordLookup() {
        return this.questionInfo.Answer_Type__c === 'Record Lookup';
    }

    // Mulit-Select Picklist options
    get mulitPicklistOptions() {
        let mulitPicklistOptions = [];
        let key = 0;
        this.questionInfo.Picklist_Answers__c.split(';').forEach(function(option) {
            let obj = {
                value: option,
                key: key + 1
            }
            if (this.questionInfo.answer !== undefined) {
                if (this.questionInfo.answer.split(';').includes(option)) {
                    obj.selected = true;
                }
            }
            mulitPicklistOptions.push(
                obj
            );
            key += 1;
        }, this);
        return mulitPicklistOptions;
    }

    // Picklist options
    get picklistOptions() {
        let picklistOptions = [];
        this.questionInfo.Picklist_Answers__c.split(';').forEach(function(option) {
            picklistOptions.push(
                {
                    label: option,
                    value: option
                }
            );
        });
        return picklistOptions;
    }

    // # of records selected for record lookup
    get recordsSelectedText() {
        if (this.questionInfo.Answer_Type__c === 'Record Lookup') {
            if (this.questionInfo.answer !== undefined &&
                this.questionInfo.answer !== null &&
                this.questionInfo.answer !== ''
            ) {
                let recordsSelected = this.questionInfo.answer.split(';').length;
                if (recordsSelected === 1) {
                    return '1 record selected';
                } else {
                    return recordsSelected + ' records selected';
                }
            } else {
                return '0 records selected';
            }
        } else {
            return '0 records selected';
        }
    }

    // If manual record selection/deselection is allowed for record lookup
    get manualRecordSelection() {
        if (this.questionInfo.Record_Selection_Behavior__c === 'Automatic Record Selection (With Deselection)' ||
            this.questionInfo.Record_Selection_Behavior__c === 'Manual Record Selection' ||
            this.configType === 'Admin Edit' ||
            this.configType === 'Admin New'
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Single Value Picklist input type
    get isSinglePicklist() {
        return this.questionInfo.Answer_Type__c === 'Picklist';
    }

    // Text input type
    get isText() {
        return this.questionInfo.Answer_Type__c === 'Text';
    }

    // Text Area input type
    get isTextArea() {
        return this.questionInfo.Answer_Type__c === 'Text Area';
    }

    // Answer change event
    answerChange(event) {

        let answer;
        let selectedRecords;

        // Not on blur event
        if (event.detail) {
            if (this.questionInfo.Answer_Type__c === 'Record Lookup') {
                answer = event.detail.answer;
                selectedRecords = event.detail.selectedRecords;
            }
            else if (this.questionInfo.Answer_Type__c === 'Boolean') {
                answer = event.detail.checked;
            }
            else if (this.questionInfo.Answer_Type__c === 'Multi-Select Picklist') {
                if (event.detail.length === 0) {
                    answer = undefined;
                } else {
                    answer = '';
                    let selectedOptions = [];
                    event.detail.forEach(function(option) {
                        selectedOptions.push(option.value);
                    });
                    answer = selectedOptions.join(';');
                }
            }
            else {
                answer = event.detail.value;
            }
        }
        // on Blur event
        else {
            this.template.querySelectorAll('lightning-input').forEach(function(input) {
                answer = input.value;
            }, this);
            this.template.querySelectorAll('lightning-textarea').forEach(function(input) {
                answer = input.value;
            }, this);
            this.template.querySelectorAll('lightning-combobox').forEach(function(input) {
                answer = input.value;
            }, this);
        }

        if (['Integer', 'Decimal', 'Currency'].includes(this.questionInfo.Answer_Type__c) &&
            answer !== '' &&
            answer !== null &&
            answer !== undefined
        ) {
            answer = Number(answer);

            // Cannot be below Min
            if (this.questionInfo.Minimum_Value__c !== undefined &&
                answer < this.questionInfo.Minimum_Value__c
            ) {
                answer = this.questionInfo.Minimum_Value__c;
            }

            // Cannot be above Max
            if (this.questionInfo.Maximum_Value__c !== undefined &&
                answer > this.questionInfo.Maximum_Value__c
            ) {
                answer = this.questionInfo.Maximum_Value__c;
            }

            // Cannot be out of Step
            if (this.questionInfo.Step_Value__c !== undefined &&
                this.questionInfo.Step_Value__c != 0
            ) {

                let defaultValue = 0;
                // Has default value
                if (this.questionInfo.Default_Value_Currency__c !== undefined &&
                    this.questionInfo.Answer_Type__c === 'Currency'
                ) {
                    defaultValue = this.questionInfo.Default_Value_Currency__c;
                }
                else if (this.questionInfo.Default_Value_Decimal__c !== undefined &&
                    this.questionInfo.Answer_Type__c === 'Decimal'
                ) {
                    defaultValue = this.questionInfo.Default_Value_Decimal__c;
                }
                else if (this.questionInfo.Default_Value_Integer__c !== undefined &&
                    this.questionInfo.Answer_Type__c === 'Integer'
                ) {
                    defaultValue = this.questionInfo.Default_Value_Integer__c;
                }

                // Determine if difference between current value and default value is in Step
                let remainder = Math.abs((defaultValue - answer) % this.questionInfo.Step_Value__c);
                if (remainder !== 0) {

                    // Closer to step above
                    if ((remainder/this.questionInfo.Step_Value__c) >= 0.5) {
                        answer = answer + (this.questionInfo.Step_Value__c - remainder);
                    } else {
                        answer = answer - remainder;
                    }

                    // Cannot be below Min
                    if (this.questionInfo.Minimum_Value__c !== undefined &&
                        answer < this.questionInfo.Minimum_Value__c
                    ) {
                        answer = this.questionInfo.Minimum_Value__c;
                    }

                    // Cannot be above Max
                    if (this.questionInfo.Maximum_Value__c !== undefined &&
                        answer > this.questionInfo.Maximum_Value__c
                    ) {
                        answer = this.questionInfo.Maximum_Value__c;
                    }
                }
            }

            // Update UI
            this.template.querySelectorAll('lightning-input').forEach(function(input) {
                input.value = answer;
            }, this);
        }

        const touchEvent = new CustomEvent(
            'touch', {
                detail: {
                    answer: answer,
                    selectedRecords: selectedRecords
                }
            });
        this.dispatchEvent(touchEvent);

        this.showRecordLookupModal = false;
    }

    decrease() {
        let newAnswer = 0;
        let currVal = this.questionInfo.answer;
        if (currVal !== undefined) {
            if (this.questionInfo.Step_Value__c !== undefined &&
                this.questionInfo.Step_Value__c != 0
            ) {
                newAnswer = currVal -= this.questionInfo.Step_Value__c;
            }
            else {
                newAnswer = currVal - 1;
            }
        }

        this.answerChange({
            detail: {
                value: newAnswer
            }
        });
    }

    increase() {
        let newAnswer = 0;
        let currVal = this.questionInfo.answer;
        if (currVal !== undefined) {
            if (this.questionInfo.Step_Value__c !== undefined &&
                this.questionInfo.Step_Value__c != 0
            ) {
                newAnswer = currVal += this.questionInfo.Step_Value__c;
            }
            else {
                newAnswer = currVal + 1;
            }
        }

        this.answerChange({
            detail: {
                value: newAnswer
            }
        });
    }

    showRecords() {
        this.showRecordLookupModal = true;
    }

    hideRecords() {
        this.showRecordLookupModal = false;
    }
}