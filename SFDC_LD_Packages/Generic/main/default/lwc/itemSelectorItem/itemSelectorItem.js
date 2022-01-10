import { LightningElement, api, track } from 'lwc';

export default class ItemSelectorItem extends LightningElement {

    @api item;
    @api selectedValue;
    @api selectedAttribute;
    @api objAccessor;
    @api headerAttribute;
    @api footerAttribute1;
    @api footerLabel1;
    @api footerAttribute2;
    @api footerLabel2;
    @api iconName;
    @api searchTerm;

    get header() {
        if (this.objAccessor !== undefined) {
            return this.item[this.objAccessor][this.headerAttribute];
        } else {
            return this.item[this.headerAttribute];
        }
    }

    get itemCSS() {
        let CSS = 'slds-p-vertical_x-small slds-p-horizontal_medium slds-m-around_xx-small';
        if (this.selectedValue !== undefined &&
            this.selectedAttribute !== undefined    
        ) {
            let itemValue;
            if (this.objAccessor !== undefined) {
                itemValue = this.item[this.objAccessor][this.selectedAttribute];
            } else {
                itemValue = this.item[this.selectedAttribute];
            }

            if (itemValue === this.selectedValue) {
                CSS += ' selectedItem';
            }
        }

        if (!CSS.includes('selectedItem')) {
            CSS += ' item';
        }
        return CSS;
    }

    get footer1() {
        let footer = '';
        if (this.footerLabel1 !== undefined) {
            footer += this.footerLabel1;
            if (this.objAccessor !== undefined) {
                footer +=  this.item[this.objAccessor][this.footerAttribute1];
            } else {
                footer +=  this.item[this.footerAttribute1];
            }
        }
        return footer;
    }

    get footer2() {
        let footer = '';
        if (this.footerLabel2 !== undefined) {
            footer += this.footerLabel2;
            if (this.objAccessor !== undefined) {
                footer +=  this.item[this.objAccessor][this.footerAttribute2];
            } else {
                footer +=  this.item[this.footerAttribute2];
            }
        }
        return footer;
    }

    selectItem() {
        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    item: this.item,
                    searchTerm: this.searchTerm
                }
            });
        this.dispatchEvent(selectEvent);
    }

}