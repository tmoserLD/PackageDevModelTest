import { LightningElement, track } from 'lwc';

// Recently Viewed Query Method
import getRecentlyViewed from '@salesforce/apex/cpq_ContractsByAccountClass.getRecentlyViewed';

// Account Query Method
import queryAccount from '@salesforce/apex/cpq_ContractsByAccountClass.queryAccount';

export default class CPQ_ContractsByAccount extends LightningElement {

    // Fields for SOSL search
    @track fields = ["Name"];

    // Fields for display
    @track displayFields = 'Name, Owner.Name';

    // Id for Account to show CPQ
    @track acctId;

    // Recently viewed account records
    @track recentlyViewed = [];

    // On Mount
    connectedCallback() {
        this.queryRecentlyViewed();
    }

    get hasAcctId() {
        return (this.acctId !== undefined && this.acctId !== null && this.acctId !== '');
    }

    async handleLookup(event){
        if (event.detail !== undefined &&
            event.detail !== null &&
            event.detail !== ''    
        ) {
            try {
                await queryAccount(
                    {
                        acctId: event.detail
                    }
                );
            } catch (e) {
                console.error(e);
                this.template.querySelector('c-error-modal').showError(
                    {
                        title: 'An error occurred while trying to query the selected account',
                        body: JSON.stringify(e),
                        forceRefresh: false
                    }
                );
            }
        }
        this.acctId = event.detail;
        this.queryRecentlyViewed();
    }

    async queryRecentlyViewed() {
        let recentlyViewedQueried = [];
        try {
            recentlyViewedQueried = await getRecentlyViewed();
        } catch (e) {
            console.error(e);
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to query the recently viewed accounts',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }
        let recentlyViewed = [];
        recentlyViewedQueried.forEach(function(rv) {
            let record = {
                name: rv.Name,
                Name: rv.Name,
                ownerName: rv.Owner.Name,
                Owner: {
                    Name: rv.Owner.Name
                },
                Id: rv.Id
            };
            recentlyViewed.push(record);
        }, this);
        this.recentlyViewed = recentlyViewed;
    }

    // Record Selected event received
    recordSelected(event) {

        // Select acct
        this.handleLookup(
            {
                detail: event.detail.item.Id
            }
        );

        // Show selected acct in search
        this.template.querySelector('c-search-component').selectFromParent(event.detail.item);
    }

}