import { LightningElement, api, track } from 'lwc';

export default class CPQ_ContractList extends LightningElement {

    // Source Object Info
    @api sourceInfo;

    // Loading / Show Spinner
    @track loading = false;

    // Current Sort Column
    @track sortCol = {};

    // Boolean indicator if any exist on Account
    get noContractsToDisplay() {
        if (this.sourceInfo.Contracts) {
            return this.sourceInfo.Contracts.length <= 0;
        } else {
            return true;
        }
    }

    // Number of Contracts currently associated to Account
    get numberOfContracts() {
        if (this.sourceInfo.Contracts) {
            return this.sourceInfo.Contracts.length;
        } else {
            return 0;
        }
    }

    // Columns to display
    get columnsToDisplay() {
        let columns = [];

        JSON.parse(JSON.stringify(this.sourceInfo.ContractTableColumns)).forEach(function(col) {
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
        if (this.sourceInfo.ContractTableColumns.length >= 6) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-6';
        }
        else if (this.sourceInfo.ContractTableColumns.length >= 5) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-5';
        }
        else if (this.sourceInfo.ContractTableColumns.length >= 4) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-4 slds-large-size_1-of-4';
        }
        else if (this.sourceInfo.ContractTableColumns.length >= 3) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-3 slds-large-size_1-of-3';
        }
        return colCSS;
    }

    // Sorted Contracts
    get sortedContracts() {
        return this.sorter(this.sortCol);
    }

    // Sorter
    sorter(sortCol) {
        return JSON.parse(JSON.stringify(this.sourceInfo.Contracts)).sort(function(contractA, contractB) {

            // Sort by sort col
            if (sortCol.field !== undefined) {
                // Sort Up
                if (sortCol.sort === 'Up') {
                    if (contractA[sortCol.field] > contractB[sortCol.field]) {
                        return -1;
                    }
                    if (contractA[sortCol.field] < contractB[sortCol.field]) {
                        return 1;
                    }
                }

                // Sort Down
                else if (sortCol.sort === 'Down') {
                    if (contractA[sortCol.field] < contractB[sortCol.field]) {
                        return -1;
                    }
                    if (contractA[sortCol.field] > contractB[sortCol.field]) {
                        return 1;
                    }
                }
            }

            // Otherwise, treat as the same
            return 0;
        });
    }

    // Amend Contract event
    amendContract(event) {
        // Send Amend Contract call to parent
        const amendContractEvent = new CustomEvent(
            'amendcontract', {
                detail: event.detail
            });
        this.dispatchEvent(amendContractEvent);
    }

    // Replace Contract event
    replaceContract(event) {
        // Send Replace Contract call to parent
        const replaceContractEvent = new CustomEvent(
            'replacecontract', {
                detail: event.detail
            });
        this.dispatchEvent(replaceContractEvent);
    }

    // Renew Contract event
    renewContract(event) {
        // Send Renew Contract call to parent
        const renewContractEvent = new CustomEvent(
            'renewcontract', {
                detail: event.detail
            });
        this.dispatchEvent(renewContractEvent);
    }

    // Void Contract event
    voidContract(event) {
        // Send Void Contract call to parent
        const voidContractEvent = new CustomEvent(
            'voidcontract', {
                detail: event.detail
            });
        this.dispatchEvent(voidContractEvent);
    }

    // View Contract event
    viewContract(event) {
        // Send Void Contract call to parent
        const viewContractEvent = new CustomEvent(
            'viewcontract', {
                detail: event.detail
            });
        this.dispatchEvent(viewContractEvent);
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