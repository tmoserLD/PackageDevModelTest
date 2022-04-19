import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteListItem extends LightningElement {

    // All Quotes on opp
    @api allQuotes = [];

    // Quote Columns
    @api columnsToDisplay;

    // Opportunity Info
    @api oppInfo;

    // Quote record
    @api quote;

    // CSS class names string for component
    get colCSS() {
        let colCSS = 'slds-col slds-p-left_xx-small';
        if (this.allQuotes.indexOf(
            this.allQuotes.find(
                quote => quote.Id === this.quote.Id
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