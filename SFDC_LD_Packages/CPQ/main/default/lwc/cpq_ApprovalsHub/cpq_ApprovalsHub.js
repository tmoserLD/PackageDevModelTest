import { LightningElement, api, track } from 'lwc';

// Query Method
import queryApprovals from '@salesforce/apex/cpq_ApprovalsHubClass.queryApprovals';

export default class CPQ_ApprovalsHub extends LightningElement {

    // Approval Category picklist options
    @track approvalCategories = [
        {
            label: 'Submitted by',
            value: 'Submitted by'
        },
        {
            label: 'Assigned to',
            value: 'Assigned to'
        }
    ];

    // Selected approval category
    @track approvalCategory = 'Submitted by';

    // Approval Status picklist options
    @track approvalStatuses = [
        {
            label: 'Submitted',
            value: 'Submitted'
        },
        {
            label: 'Approved',
            value: 'Approved'
        },
        {
            label: 'Rejected',
            value: 'Rejected'
        }
    ];

    // Selected approval status
    @track approvalStatus = 'Submitted';

    // Info for current user
    @track currentUser;

    // Default currency for org
    @track defaultCurrency;

    // Loading spinner
    @track loading = false;

    // Approval data by Opportunity
    @track opportunities = [];

    // Selected 'since' date
    @track sinceDate;

    // User to show approvals for
    @track userId;

    // Fields for SOSL search
    @track userFields = ["Name"];

    // Fields for display
    @track userDisplayFields = 'Name';

    // On Mount
    connectedCallback() {

        // Set Since date to 7 days ago
        let today = new Date();
        today.setUTCDate(new Date().getUTCDate() - 7);
        let newYear = today.getUTCFullYear().toString();
        let newMonth = (today.getUTCMonth() + 1).toString();
        if ((today.getUTCMonth() + 1) < 10) {
            newMonth = '0' + newMonth;
        }
        let newDay = today.getUTCDate().toString();
        if (today.getUTCDate() < 10) {
            newDay = '0' + newDay;
        }
        this.sinceDate = newYear + '-' + newMonth + '-' + newDay;

        this.getApprovals();
    }

    get disableSearch() {
        return false;
    }

    // Query Data
    async getApprovals() {

        this.loading = true;

        try {
            let data = await queryApprovals(
                {
                    relationship: this.approvalCategory,
                    status: this.approvalStatus,
                    userId: this.userId,
                    sinceDate: this.sinceDate
                }
            );

            data.opportunities.forEach(function(opp) {
                if (opp.CurrencyIsoCode === undefined) {
                    opp.CurrencyIsoCode = data.defaultCurrency;
                }
            }, this);

            // Show selected user in search
            this.template.querySelector('c-search-component').selectFromParent(data.userObj);

            this.currentUser = data.currentUser;
            this.defaultCurrency = data.defaultCurrency;
            this.userId = data.userObj.Id;
            this.opportunities = data.opportunities;
        } catch (e) {
            console.error(e);
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to query the approvals',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Category Changed
    categoryChange(event) {
        this.approvalCategory = event.detail.value;
        if (this.userId !== undefined &&
            this.userId !== null &&
            this.userId !== ''
        ) {
            this.getApprovals();
        } else {
            this.opportunities = [];
            this.userId = undefined;
        }
    }

    // Since Date Changed
    sinceDateChange(event) {
        this.sinceDate = event.detail.value;
        if (this.userId !== undefined &&
            this.userId !== null &&
            this.userId !== ''
        ) {
            this.getApprovals();
        } else {
            this.opportunities = [];
            this.userId = undefined;
        }
    }

    // Status Changed
    statusChange(event) {
        this.approvalStatus = event.detail.value;
        if (this.userId !== undefined &&
            this.userId !== null &&
            this.userId !== ''
        ) {
            this.getApprovals();
        } else {
            this.opportunities = [];
            this.userId = undefined;
        }
    }

    // User Changed
    userChange(event) {
        this.userId = event.detail;
        if (this.userId !== undefined &&
            this.userId !== null &&
            this.userId !== ''
        ) {
            this.getApprovals();
        } else {
            this.opportunities = [];
            this.userId = undefined;
        }
    }

}