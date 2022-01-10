import { LightningElement, api, track } from 'lwc';

export default class CPQ_Playbook extends LightningElement {

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Playbook Info
    @api playbook;

    // Pricebook Info
    @api pricebook;

    // Approvals needed for Quote
    @api quoteApprovals = [];

    // Products added to Quote
    @api quoteProducts = [];

    // Entitlements from contract being adjusted
    @api entitlements = [];

    // User Info
    @api userInfo;

    // Columns to show for Product Summary
    @api productColumns = [];

    // Columns to show for Entitlement Summary
    @api entitlementColumns = [];

    // If playbook has approvals for this playbook
    get hasApprovals() {
        return this.quoteApprovals.length > 0;
    }

    // Answer "Touched" Event
    answerTouch(event) {

        const touchEvent = new CustomEvent(
            'touch', {
                detail: {
                    playbookId: this.playbook.playbookInfo.Id,
                    groupId:  event.detail.groupId,
                    questionId: event.detail.questionId,
                    answer: event.detail.answer
                }
            });
        this.dispatchEvent(touchEvent);
    }

    // Remove Product event
    removeProduct(event) {

        const removeProductEvent = new CustomEvent(
            'removeproduct', {
                detail: event.detail 
            });
        this.dispatchEvent(removeProductEvent);

    }

    // Update Product event
    updateProduct(event) {

        const updateProductEvent = new CustomEvent(
            'updateproduct', {
                detail: event.detail
            });
        this.dispatchEvent(updateProductEvent);
    }

    // Sdd products event
    addProducts(event) {

        const addProductsEvent = new CustomEvent(
            'addproducts', {
                detail: event.detail
            });
        this.dispatchEvent(addProductsEvent);
    }
}