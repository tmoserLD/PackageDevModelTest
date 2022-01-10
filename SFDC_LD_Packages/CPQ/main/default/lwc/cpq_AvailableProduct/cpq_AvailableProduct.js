import { LightningElement, api, track } from 'lwc';

export default class CPQ_AvailableProduct extends LightningElement {

    // Pricebook Entry
    @api entry;

    // Hover "Shade"
    @track shade = false;

    get mainCSS() {
        let mainCSS = 'slds-m-bottom_x-small';
        if (this.shade) {
            mainCSS += ' slds-theme_shade';
        } else {
            mainCSS += ' slds-theme_default';
        }
        return mainCSS;
    }

    // Product clicked
    addProduct() {
        const addEvent = new CustomEvent(
            'add', {
                detail: this.entry 
            });
        this.dispatchEvent(addEvent);
    }

    // Mouse event
    toggleShade() {
        this.shade = !this.shade;
    }
}