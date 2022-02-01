import { LightningElement, track } from 'lwc';

// Recently Viewed Query Method
import getRecentlyViewed from '@salesforce/apex/cpq_AnyOppContainerClass.getRecentlyViewed';

// Opp Query Method
import queryOpp from '@salesforce/apex/cpq_AnyOppContainerClass.queryOpp';

export default class CPQ_AnyOppContainer extends LightningElement {

    // Fields for SOSL search
    @track fields = ["Name"];

    // Fields for display
    @track displayFields = 'Name, Account.Name, Owner.Name';

    // Id for Opp to show CPQ
    @track oppId;

    // Recently viewed opportunity records
    @track recentlyViewed = [];

    // On Mount
    connectedCallback() {
        this.queryRecentlyViewed();
    }

    get hasOppId() {
        return (this.oppId !== undefined && this.oppId !== null && this.oppId !== '');
    }

    async handleLookup(event){
        if (event.detail !== undefined &&
            event.detail !== null &&
            event.detail !== ''    
        ) {
            try {
                await queryOpp(
                    {
                        oppId: event.detail
                    }
                );
            } catch (e) {
                console.error(e);
                this.template.querySelector('c-error-modal').showError(
                    {
                        title: 'An error occurred while trying to query the selected opportunity',
                        body: JSON.stringify(e),
                        forceRefresh: false
                    }
                );
            }
        }
        this.oppId = event.detail;
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
                    title: 'An error occurred while trying to query the recently viewed opportunities',
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
                accountName: rv.Account.Name,
                Account: {
                    Name: rv.Account.Name
                },
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

        // Select opp
        this.handleLookup(
            {
                detail: event.detail.item.Id
            }
        );

        // Show selected opp in search
        this.template.querySelector('c-search-component').selectFromParent(event.detail.item);
    }

}