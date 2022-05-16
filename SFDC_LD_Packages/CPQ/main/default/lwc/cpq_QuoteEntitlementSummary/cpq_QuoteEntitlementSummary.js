import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteEntitlementSummary extends LightningElement {

    // Contract Currency
    @api contractCurrency;

    // Currency Conversion Map
    @api currencyMap = {};

    // Entitlements from contract being adjusted
    @api entitlements = [];

    // Columns to show for Entitlement Summary
    @api entitlementColumns = [];

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Default group/sort columns
    @api defaultGroupBy;
    @api defaultSortBy;

    // Collapse toggle
    @track collapsed = false;

    // Group by field
    @track groupByField;

    // Group by field type
    @track groupByFieldType;

    // Group by field label
    @track groupByFieldLabel;

    // Current Sort Column
    @track sortCol = {};

    // On Mount
    connectedCallback() {
        if (this.entitlements.length > 0) {
            if (this.defaultGroupBy !== undefined) {
                this.groupByField = this.defaultGroupBy;
                this.groupByFieldType = this.groupByColumns.find(col => col.value === this.defaultGroupBy).type;
                this.groupByFieldLabel = this.groupByColumns.find(col => col.value === this.defaultGroupBy).label;
            }
            if (this.defaultSortBy !== undefined) {
                this.sortCol = {
                    field: this.defaultSortBy,
                    sort: 'Down'
                };
            }
        }
    }

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

    get contractNumber() {
        if (this.entitlements.length > 0) {
            return this.entitlements[0].Contract__r.ContractNumber;
        } else {
            return '';
        }
    }

    get groupByColumns() {
        let columns = [];

        columns.push({
            label: '-- Select Field --',
            value: undefined,
            type: undefined
        });

        JSON.parse(JSON.stringify(this.entitlementColumns)).forEach(function(col) {
            let colToAdd;

            colToAdd = {
                label: col.label,
                value: col.field,
                type: col.type
            }

            columns.push(colToAdd);

        }, this);

        return columns;
    }

    // Grouped entitlements
    get entitlementGroups() {
        let groups = [];

        if (this.groupByField !== undefined) {

            // Find all unique values for field
            let uniqueValues = [];
            this.sorter(
                this.entitlements,
                {
                    field: this.groupByField,
                    sort: 'Down'
                }
            ).forEach(function(ent) {
                if (!uniqueValues.includes(ent[this.groupByField]?.toString())) {
                    uniqueValues.push(ent[this.groupByField]?.toString());
                }
            }, this);

            // Sort each group by sort col
            uniqueValues.forEach(function(val) {
                groups.push(
                    {
                        value: val,
                        entitlements: this.sorter(
                            this.entitlements.filter(
                                ent => ent[this.groupByField]?.toString() === val
                            ),
                            this.sortCol
                        )
                    }
                );
            }, this);
        } else {
            // All products in 1 group
            groups.push(
                {
                    value: undefined,
                    entitlements: this.sorter(
                        this.entitlements,
                        this.sortCol
                    )
                }
            );
        }

        return groups;
    }

    // Sorter
    sorter(entitlements, sortCol) {
        return JSON.parse(JSON.stringify(entitlements)).sort(function(entA, entB) {

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
            totalPrice += this.convertCurrency((ent.Unit_Price__c * ent.Quantity__c), this.contractCurrency, this.oppCurrency);
        }, this);
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
                if (this.sortCol.sort === 'Down') {
                    this.sortCol = {
                        field: event.target.id.split('-')[0],
                        sort: 'Up'
                    }
                } else {
                    this.sortCol = {}
                }
            } else {
                this.sortCol = {
                    field: event.target.id.split('-')[0],
                    sort: 'Down'
                };
            }
        } else {
            this.sortCol = {
                field: event.target.id.split('-')[0],
                sort: 'Down'
            };
        }
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

    // Group by field change
    groupByChange(event) {
        if (event.detail.value === null) {
            this.groupByField = undefined;
            this.groupByFieldType = undefined;
            this.groupByFieldLabel = undefined;
        } else {
            this.groupByField = event.detail.value;
            this.groupByFieldType = this.groupByColumns.find(col => col.value === event.detail.value).type;
            this.groupByFieldLabel = this.groupByColumns.find(col => col.value === event.detail.value).label;
        }
    }
}