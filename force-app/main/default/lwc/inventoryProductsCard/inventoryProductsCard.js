import { LightningElement, api } from 'lwc';

export default class InventoryProductsCard extends LightningElement {
    @api prod;
    @api selected;

    handleClick(event) {
        console.log('handleClick');
        this.dispatchEvent(new CustomEvent('select', {
            detail: this.prod.id
        }));
    }

    get divClass() {
        let cls = '';
        if (this.selected) {
            cls += 'bear-tile-selected';
        } else if(!this.selected) {
            cls += 'bear-tile'
        }
        return cls;
    }
}