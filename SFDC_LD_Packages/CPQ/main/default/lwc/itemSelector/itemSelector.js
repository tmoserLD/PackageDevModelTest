import { LightningElement, api, track } from 'lwc';

export default class ItemSelector extends LightningElement {

    @api items;
    @api selectedValue;
    @api selectedAttribute;
    @api listStyle;
    @api objAccessor;
    @api headerAttribute;
    @api footerAttribute1;
    @api footerLabel1;
    @api footerAttribute2;
    @api footerLabel2;
    @api iconName;
    @api showSearch;
    @api showCreate;
    @api header;

    @track searchTerm;

    get filteredItems() {
        if (this.searchTerm !== undefined &&
            this.searchTerm !== null &&
            this.searchTerm !== ''    
        ) {
            if (this.objAccessor !== undefined) {
                return this.items.filter(
                    item => item[this.objAccessor][this.headerAttribute]?.toLowerCase().includes(this.searchTerm.toLowerCase())
                );
            } else {
                return this.items.filter(
                    item => item[this.headerAttribute]?.toLowerCase().includes(this.searchTerm.toLowerCase())
                );
            }
        } else {
            return this.items;
        }
    }

    get hasHeader() {
        return this.header !== undefined;
    }

    get itemCSS() {
        let CSS = 'slds-col';
        if (this.listStyle === 'column') {
            CSS += ' slds-size_1-of-1';
        }
        else if (this.listStyle === 'row') {
            CSS += ' slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_4-of-12';
        }
        return CSS;
    }

    get noFilteredItems() {
        let filteredItems = [];
        if (this.items !== undefined) {
            if (this.searchTerm !== undefined &&
                this.searchTerm !== null &&
                this.searchTerm !== ''    
            ) {
                if (this.objAccessor !== undefined) {
                    filteredItems = this.items.filter(
                        item => item[this.objAccessor][this.headerAttribute]?.toLowerCase().includes(this.searchTerm.toLowerCase())
                    );
                } else {
                    filteredItems = this.items.filter(
                        item => item[this.headerAttribute]?.toLowerCase().includes(this.searchTerm.toLowerCase())
                    );
                }
            } else {
                filteredItems = this.items;
            }
        }
        return filteredItems.length === 0;
    }

    get searchCSS() {
        let CSS = 'width:';
        if (this.listStyle === 'column') {
            CSS += ' 100%';
        }
        else if (this.listStyle === 'row') {
            CSS += ' 425px;';
        }
        return CSS;
    }

    get showCreateButton() {
        return this.showCreate === 'true';
    }

    get showSearchBar() {
        return this.showSearch === 'true';
    }

    searchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    selectItem(event) {
        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: event.detail
            }
        );
        this.dispatchEvent(selectEvent);
    }

    createNew(event) {
        // Send create event to parent
        const createEvent = new CustomEvent(
            'create', {
                detail: event.detail
            }
        );
        this.dispatchEvent(createEvent);
    }
}