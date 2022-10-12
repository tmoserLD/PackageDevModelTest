import { LightningElement, api, track } from 'lwc';

export default class CPQ_PlaybookViewFields extends LightningElement {

    @api configType;
    @api contractId;
    @api playbook;
    @api quoteEndDate;
    @api quoteStartDate;
    @api quoteTerm;
    @api quoteProducts;
    @api quoteId;
    @api quoteAdjustmentType;

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

    get hasProducts() {
        return this.quoteProducts.length > 0;
    }

    get startDateReadOnly() {
        return (
            !this.playbook.playbookInfo.Start_Date_Editable__c &&
            !this.configType.includes('Admin')
        );
    }

    get termReadOnly() {
        return (
            !this.playbook.playbookInfo.Term_Editable__c &&
            !this.configType.includes('Admin')
        );
    }

    get endDateReadOnly() {
        return (
            (
                this.quoteAdjustmentType === 'Amendment' ||
                !this.playbook.playbookInfo.End_Date_Editable__c
            ) &&
            !this.configType.includes('Admin')
        );
    }

    startDateChanged(event) {
        let newStartDate = event.target.value;
        if (newStartDate) {
            // Get new end date based on term and new start date
            let newEndDate = new Date(newStartDate);
            newEndDate.setMonth(new Date(newStartDate).getUTCMonth() + this.quoteTerm);
            newEndDate.setDate(newEndDate.getUTCDate() - 1);

            this.updateProductDates(newStartDate, this.quoteAdjustmentType === 'Amendment' ? this.quoteEndDate : this.convertDate(newEndDate));
        } else {
            this.template.querySelectorAll('lightning-input').forEach(function(input) {
                if (input.name === 'Start') {
                    input.value = this.quoteStartDate;
                }
            }, this);
        }
    }

    termChanged(event) {
        let newTerm = event.target.value;
        if (newTerm &&
            newTerm > 0    
        ) {
            if (this.quoteAdjustmentType === 'Amendment') {
                // Get new start date based on new term and end date
                let newStartDate = new Date(this.quoteEndDate);
                newStartDate.setMonth(new Date(this.quoteEndDate).getUTCMonth() - Number(newTerm));
                newStartDate.setDate(newStartDate.getUTCDate() + 1);

                this.updateProductDates(this.convertDate(newStartDate), this.quoteEndDate);
            } else {
                // Get new end date based on new term and start date
                let newEndDate = new Date(this.quoteStartDate);
                newEndDate.setMonth(new Date(this.quoteStartDate).getUTCMonth() + Number(newTerm));
                newEndDate.setDate(newEndDate.getUTCDate() - 1);

                this.updateProductDates(this.quoteStartDate, this.convertDate(newEndDate));
            }
        } else {
            this.template.querySelectorAll('lightning-input').forEach(function(input) {
                if (input.name === 'Term') {
                    input.value = this.quoteTerm;
                }
            }, this);
        }
    }

    endDateChanged(event) {
        let newEndDate = event.target.value;
        if (newEndDate) {
            // Get new start date based on term and new end date
            let newStartDate = new Date(newEndDate);
            newStartDate.setMonth(new Date(newEndDate).getUTCMonth() - this.quoteTerm);
            newStartDate.setDate(newStartDate.getUTCDate() + 1);

            this.updateProductDates(this.convertDate(newStartDate), newEndDate);
        } else {
            this.template.querySelectorAll('lightning-input').forEach(function(input) {
                if (input.name === 'End') {
                    input.value = this.quoteEndDate;
                }
            }, this);
        }
    }

    updateProductDates(startDate, endDate) {

        let productsCopy = JSON.parse(JSON.stringify(this.quoteProducts));
        productsCopy.forEach(function(product) {

            if (product['Start_Date'] === this.quoteStartDate ||
                new Date(product['Start_Date']) < new Date(startDate)
            ) {
                product.prevValues['Start_Date'] = product['Start_Date'];
                product['Start_Date'] = startDate;
            }
            if (product['End_Date'] === this.quoteEndDate ||
                new Date(product['End_Date']) > new Date(endDate)
            ) {
                product.prevValues['End_Date'] = product['End_Date'];
                product['End_Date'] = endDate;
            }
        }, this);

        const datesupdateEvent = new CustomEvent(
            'datesupdate', {
                detail: {
                    updatedProducts: productsCopy
                }
            });
        this.dispatchEvent(datesupdateEvent);
    }

    convertDate(dateValue) {
        let year = dateValue.getFullYear().toString();
        let month = (dateValue.getMonth() + 1).toString();
        if ((dateValue.getMonth() + 1) < 10) {
            month = '0' + month;
        }
        let day = dateValue.getDate().toString();
        if (dateValue.getDate() < 10) {
            day = '0' + day;
        }
        return year + '-' + month + '-' + day;
    }
}