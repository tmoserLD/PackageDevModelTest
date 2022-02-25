import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProductSummary extends LightningElement {
    
    // Products added to Quote
    @api quoteProducts = [];

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Pricebook Info
    @api pricebook;

    // Columns to show for Product Summary
    @api productColumns = [];

    // Collapse toggle
    @track collapsed = false;

    // Add Products Modal Toggle
    @track showAddProductsModal = false;

    // Current Sort Column
    @track sortCol = {};

    // Columns to display
    get columnsToDisplay() {
        let columns = [];

        JSON.parse(JSON.stringify(this.productColumns)).forEach(function(col) {
            let colToAdd;
            // Standard
            if (col.type === undefined) {
                
                if (col.field === 'Product_Name') {
                    colToAdd = {
                        label: 'Product',
                        field: 'Product_Name',
                        type: 'Text'
                    };
                }
                else if (col.field === 'Start_Date') {
                    colToAdd = {
                        label: 'Start Date',
                        field: 'Start_Date',
                        type: 'Date'
                    };
                }
                else if (col.field === 'End_Date') {
                    colToAdd = {
                        label: 'End Date',
                        field: 'End_Date',
                        type: 'Date'
                    };
                }
                else if (col.field === 'Quantity') {
                    colToAdd = {
                        label: 'Quantity',
                        field: 'Quantity',
                        type: 'Number'
                    };
                }
                else if (col.field === 'Unit_Price') {
                    colToAdd = {
                        label: 'Quoted Price',
                        field: 'Unit_Price',
                        type: 'Currency'
                    };
                }
                else if (col.field === 'List_Price') {
                    colToAdd = {
                        label: 'List Price',
                        field: 'List_Price',
                        type: 'Currency'
                    };
                }
                else if (col.field === 'Sub_Total_Price') {
                    colToAdd = {
                        label: 'Subtotal Price',
                        field: 'Sub_Total_Price',
                        type: 'Currency'
                    };
                }
                else if (col.field === 'Total_Price') {
                    colToAdd = {
                        label: 'Total Price',
                        field: 'Total_Price',
                        type: 'Currency'
                    };
                }
                else if (col.field === 'Discount') {
                    colToAdd = {
                        label: 'Discount',
                        field: 'Discount',
                        type: 'Percent'
                    };
                }
            }

            // Custom
            else {
                colToAdd = col;
            }

            if (colToAdd !== undefined) {

                // Sort
                if (this.sortCol.field === colToAdd.field) {
                    colToAdd.sortUp = this.sortCol.sort === 'Up';
                    colToAdd.sortDown = this.sortCol.sort === 'Down';
                }

                columns.push(colToAdd);
            }
        }, this);

        return columns;
    }

    // CSS class names string for component
    get colCSS() {
        let colCSS = 'slds-col slds-p-horizontal_x-small slds-p-bottom_xx-small';
        if (this.productColumns.length >= 6) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-6';
        }
        else if (this.productColumns.length >= 5) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-5';
        }
        else if (this.productColumns.length >= 4) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-4 slds-large-size_1-of-4';
        }
        else if (this.productColumns.length >= 3) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-3 slds-large-size_1-of-3';
        }
        return colCSS;
    }

    // Determine if any Products are currently on quote
    get showProductSummary() {
        let hasProductsToAdd = false;
        if (this.pricebook !== undefined &&
            this.pricebook.PricebookEntries !== undefined    
        ) {
            let addibleProducts = this.pricebook.PricebookEntries.filter(
                pbe => pbe.Manually_Addible === true
            );
            if (addibleProducts.length > 0) {
                addibleProducts.forEach(function(prod) {
                    if (this.quoteProducts.filter(
                        product => product.addedByAction === undefined && product.Product2Id === prod.Product2Id
                        ).length === 0
                    ) {
                        hasProductsToAdd = true;
                    }
                }, this);
            }
        }
        
        return this.quoteProducts.length > 0 || hasProductsToAdd;
    }

    // Determine if Products are available to add manually
    get hasProductsToAdd() {
        let hasProductsToAdd = false;
        if (this.pricebook !== undefined &&
            this.pricebook.PricebookEntries !== undefined    
        ) {
            let addibleProducts = this.pricebook.PricebookEntries.filter(
                pbe => pbe.Manually_Addible === true
            );
            if (addibleProducts.length > 0) {
                addibleProducts.forEach(function(prod) {
                    if (this.quoteProducts.filter(
                        product => product.addedByAction === undefined && product.Product2Id === prod.Product2Id
                        ).length === 0
                    ) {
                        hasProductsToAdd = true;
                    }
                }, this);
            }
        }
        return hasProductsToAdd;
    }

    // Sorted Quote Products
    get sortedQuoteProducts() {
        return this.sorter(this.sortCol);
    }

    // Sorter
    sorter(sortCol) {
        return JSON.parse(JSON.stringify(this.quoteProducts)).sort(function(productA, productB) {

            // Sort by sort col
            if (sortCol.field !== undefined) {
                // Sort Up
                if (sortCol.sort === 'Up') {
                    if (productA[sortCol.field] > productB[sortCol.field]) {
                        return -1;
                    }
                    if (productA[sortCol.field] < productB[sortCol.field]) {
                        return 1;
                    }
                }

                // Sort Down
                else if (sortCol.sort === 'Down') {
                    if (productA[sortCol.field] < productB[sortCol.field]) {
                        return -1;
                    }
                    if (productA[sortCol.field] > productB[sortCol.field]) {
                        return 1;
                    }
                }
            }

            // Otherwise, treat as the same
            return 0;
        });
    }

    // Total Price of Quote based on added Quote Products
    get totalPrice() {
        let totalPrice = 0;
        this.quoteProducts.forEach(function(product) {
            totalPrice += (product.Unit_Price * product.Quantity)
        });
        return totalPrice;
    }

    // Remove Product event
    removeProduct(event) {

        const removeEvent = new CustomEvent(
            'remove', {
                detail: event.detail 
            });
        this.dispatchEvent(removeEvent);

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

    // Update Product event
    updateProduct(event) {

        const updateEvent = new CustomEvent(
            'update', {
                detail: event.detail
            });
        this.dispatchEvent(updateEvent);
    }

    // Show Add Products Modal
    showAddProducts() {
        this.showAddProductsModal = true;
    }

    // Cancel Add Products event
    cancelAddProducts() {
        this.showAddProductsModal = false;
    }

    // Save add product event
    addProducts(event) {

        this.showAddProductsModal = false;

        const addProductsEvent = new CustomEvent(
            'addproducts', {
                detail: event.detail
            });
        this.dispatchEvent(addProductsEvent);
    }
}