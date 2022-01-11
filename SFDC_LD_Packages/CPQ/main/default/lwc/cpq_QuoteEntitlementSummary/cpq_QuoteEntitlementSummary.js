import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteEntitlementSummary extends LightningElement {

    // Entitlements from contract being adjusted
    @api entitlements = [];

    // Columns to show for Entitlement Summary
    @api entitlementColumns = [];

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Collapse toggle
    @track collapsed = false;

    // Current Sort Column
    @track sortCol = {};

    // Columns to display
    get columnsToDisplay() {
        let columns = [];

        JSON.parse(JSON.stringify(this.entitlementColumns)).forEach(function(col) {

            // Sort
            if (this.sortCol.field === col.field) {
                col.sortUp = this.sortCol.sort === 'Up';
                col.sortDown = this.sortCol.sort === 'Down';
            }

            columns.push(col);

        }, this);

        return columns;
    }

    // CSS class names string for component
    get colCSS() {
        let colCSS = 'slds-col slds-p-horizontal_x-small slds-p-bottom_xx-small';
        if (this.entitlementColumns.length >= 6) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-6';
        }
        else if (this.entitlementColumns.length >= 5) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-5';
        }
        else if (this.entitlementColumns.length >= 4) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-4 slds-large-size_1-of-4';
        }
        else if (this.entitlementColumns.length >= 3) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-3 slds-large-size_1-of-3';
        }
        return colCSS;
    }

    // Determine if any Entitlements are on contract being adjusted
    get hasEntitlements() {
        return this.entitlements.length > 0;
    }

    // Sorted Entitlements
    get sortedEntitlements() {
        return this.sorter(this.sortCol);
    }

    // Sorter
    sorter(sortCol) {
        return JSON.parse(JSON.stringify(this.entitlements)).sort(function(entA, entB) {

            // Sort by sort col
            if (sortCol.field !== undefined) {
                // Sort Up
                if (sortCol.sort === 'Up') {
                    if (entA[sortCol.field] > entB[sortCol.field]) {
                        return -1;
                    }
                    if (entA[sortCol.field] < entB[sortCol.field]) {
                        return 1;
                    }
                }

                // Sort Down
                else if (sortCol.sort === 'Down') {
                    if (entA[sortCol.field] < entB[sortCol.field]) {
                        return -1;
                    }
                    if (entA[sortCol.field] > entB[sortCol.field]) {
                        return 1;
                    }
                }
            }

            // Otherwise, treat as the same
            return 0;
        });
    }

    // Total Price of Contract based on existing Entitlements
    get totalPrice() {
        let totalPrice = 0;
        this.entitlements.forEach(function(ent) {
            totalPrice += (ent.Unit_Price__c * ent.Quantity__c);
        });
        return totalPrice;
    }

    // Toggle Collapse Value
    toggleCollapse() {
        this.collapsed = !this.collapsed;
    }

    // Sort column
    sortColumn(event) {
        if (this.sortCol.field !== undefined) {
            if (this.sortCol.field === event.target.id.split('-')[0]) {
                if (this.sortCol.sort === 'Up') {
                    this.sortCol = {
                        field: event.target.id.split('-')[0],
                        sort: 'Down'
                    }
                } else {
                    this.sortCol = {}
                }
            } else {
                this.sortCol = {
                    field: event.target.id.split('-')[0],
                    sort: 'Up'
                };
            }
        } else {
            this.sortCol = {
                field: event.target.id.split('-')[0],
                sort: 'Up'
            };
        }
    }
}