import { LightningElement } from 'lwc';

export default class AutomationParent extends LightningElement {
    showConfig = true;
    showPath = false;

    recordId;
    templateType;

    handleNavigate(event) {
        const { page, recordId, templateType } = event.detail;
        
        this.showConfig = page === 'config';
        this.showPath = page === 'path';

        this.recordId = recordId || null;
        this.templateType = templateType || null;
    }
}