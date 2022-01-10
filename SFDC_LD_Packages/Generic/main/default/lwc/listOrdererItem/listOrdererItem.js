import { LightningElement, api, track } from 'lwc';

export default class ListOrdererItem extends LightningElement {

    @api option;
    @api allOptions;

    @track allOptionsOrdered = [];

    get firstItem() {
        return this.allOptions.indexOf(this.option) === 0;
    }

    get lastItem() {
        return this.allOptions.indexOf(this.option) === this.allOptions.length - 1;
    }

    moveUp() {
        let options = JSON.parse(JSON.stringify(this.allOptions));
        let index = options.indexOf(this.option);
        options = options.filter(
            o => o !== this.option
        );
        options.splice(index - 1, 0, this.option);

        this.allOptionsOrdered = options;
        this.updateOrder();
    }

    moveDown() {
        let options = JSON.parse(JSON.stringify(this.allOptions));
        let index = options.indexOf(this.option);
        options = options.filter(
            o => o !== this.option
        );
        options.splice(index + 1, 0, this.option);

        this.allOptionsOrdered = options;
        this.updateOrder(options);
    }

    updateOrder(options) {
        const updateEvent = new CustomEvent(
            'update', {
                detail: this.allOptionsOrdered
            });
        this.dispatchEvent(updateEvent);
    }
}