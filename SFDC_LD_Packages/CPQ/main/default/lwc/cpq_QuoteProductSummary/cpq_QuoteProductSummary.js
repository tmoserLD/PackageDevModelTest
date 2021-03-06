import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProductSummary extends LightningElement {
    
    // Configuration Type
    @api configType;

    // Products added to Quote
    @api quoteProducts = [];

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Pricebook Info
    @api pricebook;

    // Columns to show for Product Summary
    @api productColumns = [];

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

    // Add Products Modal Toggle
    @track showAddProductsModal = false;

    // Current Sort Column
    @track sortCol = {};

    // On Mount
    connectedCallback() {
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
                        label: 'Unit Price',
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

    get groupByColumns() {
        let columns = [];

        columns.push({
            label: '-- Select Field --',
            value: undefined,
            type: undefined
        });

        JSON.parse(JSON.stringify(this.productColumns)).forEach(function(col) {
            let colToAdd;

            // Standard
            if (col.type === undefined) {
                
                if (col.field === 'Product_Name') {
                    colToAdd = {
                        label: 'Product',
                        value: 'Product_Name',
                        type: 'Text'
                    };
                }
                else if (col.field === 'Start_Date') {
                    colToAdd = {
                        label: 'Start Date',
                        value: 'Start_Date',
                        type: 'Date'
                    };
                }
                else if (col.field === 'End_Date') {
                    colToAdd = {
                        label: 'End Date',
                        value: 'End_Date',
                        type: 'Date'
                    };
                }
                else if (col.field === 'Quantity') {
                    colToAdd = {
                        label: 'Quantity',
                        value: 'Quantity',
                        type: 'Number'
                    };
                }
                else if (col.field === 'Unit_Price') {
                    colToAdd = {
                        label: 'Unit Price',
                        value: 'Unit_Price',
                        type: 'Currency'
                    };
                }
                else if (col.field === 'List_Price') {
                    colToAdd = {
                        label: 'List Price',
                        value: 'List_Price',
                        type: 'Currency'
                    };
                }
                else if (col.field === 'Sub_Total_Price') {
                    colToAdd = {
                        label: 'Subtotal Price',
                        value: 'Sub_Total_Price',
                        type: 'Currency'
                    };
                }
                else if (col.field === 'Total_Price') {
                    colToAdd = {
                        label: 'Total Price',
                        value: 'Total_Price',
                        type: 'Currency'
                    };
                }
                else if (col.field === 'Discount') {
                    colToAdd = {
                        label: 'Discount',
                        value: 'Discount',
                        type: 'Percent'
                    };
                }
            } else {
                colToAdd = {
                    label: col.label,
                    value: col.field,
                    type: col.type
                }
            }

            columns.push(colToAdd);

        }, this);

        return columns;
    }

    get hasActions() {
        let hasActions = false;
        if (!this.configType.includes('View')) {
            this.quoteProducts.forEach(function(product) {
                if (product.Removable === true ||
                    this.configType === 'Admin Edit' ||
                    this.configType === 'Admin New'    
                ) {
                    hasActions = true;
                }
            }, this);
        }
        return hasActions;
    }

    get tableCSS() {
        let tableCSS = 'slds-col slds-size_12-of-12 slds-grid_vertical scroll-shadows';
        let hasActions = false;
        if (!this.configType.includes('View')) {
            this.quoteProducts.forEach(function(product) {
                if (product.Removable === true ||
                    this.configType === 'Admin Edit' ||
                    this.configType === 'Admin New'    
                ) {
                    hasActions = true;
                }
            }, this);
        }
        if (hasActions === true) {
            tableCSS = 'slds-col slds-size_5-of-6 slds-medium-size_11-of-12 slds-large-size_11-of-12 slds-grid_vertical scroll-shadows';
        }
        return tableCSS;
    }

    get viewMode() {
        return this.configType.includes('View');
    }

    // Determine if any Products are currently on quote
    get showProductSummary() {
        let hasProductsToAdd = false;
        if (this.pricebook !== undefined &&
            this.pricebook.entries !== undefined &&
            this.pricebook.entries.length > 0
        ) {
            let addibleProducts = this.pricebook.entries.filter(
                pbe => pbe.Manually_Addible === true
            );
            if (addibleProducts.length > 0 ||
                this.configType === 'Admin Edit' ||
                this.configType === 'Admin New'    
            ) {
                hasProductsToAdd = true;
            }
        }
        
        return this.quoteProducts.length > 0 || hasProductsToAdd;
    }

    // Determine if Products are available to add manually
    get hasProductsToAdd() {
        let hasProductsToAdd = false;
        if (this.pricebook !== undefined &&
            this.pricebook.entries !== undefined &&
            this.pricebook.entries.length > 0
        ) {
            let addibleProducts = this.pricebook.entries.filter(
                pbe => pbe.Manually_Addible === true
            );
            if (addibleProducts.length > 0 ||
                this.configType === 'Admin Edit' ||
                this.configType === 'Admin New'    
            ) {
                hasProductsToAdd = true;
            }
        }
        return hasProductsToAdd;
    }

    // Grouped products
    get productGroups() {
        let groups = [];

        if (this.groupByField !== undefined) {

            // Find all unique values for field
            let uniqueValues = [];
            this.sorter(
                this.quoteProducts,
                {
                    field: this.groupByField,
                    sort: 'Down'
                }
            ).forEach(function(prod) {
                if (!uniqueValues.includes(prod[this.groupByField]?.toString())) {
                    uniqueValues.push(prod[this.groupByField]?.toString());
                }
            }, this);

            // Sort each group by sort col
            uniqueValues.forEach(function(val) {
                groups.push(
                    {
                        value: val,
                        products: this.sorter(
                            this.quoteProducts.filter(
                                prod => prod[this.groupByField]?.toString() === val
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
                    products: this.sorter(
                        this.quoteProducts,
                        this.sortCol
                    )
                }
            );
        }

        return groups;
    }

    // Sorter
    sorter(products, sortCol) {
        return JSON.parse(JSON.stringify(products)).sort(function(productA, productB) {

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