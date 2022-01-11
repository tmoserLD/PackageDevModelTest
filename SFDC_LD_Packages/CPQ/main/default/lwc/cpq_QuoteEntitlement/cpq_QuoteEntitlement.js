import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteEntitlement extends LightningElement {

    // Entitlement
    @api entitlement;

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Entitlements sorted by sort rules
    @api sortedEntitlements;

    // Columns to display
    @api columnsToDisplay;

    // CSS class names string for component
    get colCSS() {
        let colCSS = 'slds-col';
        if (this.sortedEntitlements.indexOf(
            this.sortedEntitlements.find(
                entitlement => entitlement.Id === this.entitlement.Id
                )
            ) % 2 === 1
        ) {
            colCSS += ' slds-theme_shade';
        }
        if (this.columnsToDisplay.length > 5) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-6';
        }
        else if (this.columnsToDisplay.length === 5) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-5';
        }
        else if (this.columnsToDisplay.length === 4) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-4 slds-large-size_1-of-4';
        }
        else if (this.columnsToDisplay.length === 3) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-3 slds-large-size_1-of-3';
        }
        return colCSS;
    }

}