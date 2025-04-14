import { LightningElement } from 'lwc';

export default class AutomationParent extends LightningElement {
    showConfig = true;
    showPath = false;

    recordId;
    templateType;

    handleNavigate(event) {
        console.log('handleNavigate');
        const { page, recordId, templateType } = event.detail;
        
        this.showConfig = page === 'config';
        console.log('showConfig', this.showConfig);
        this.showPath = page === 'path';
        console.log('showPath', this.showPath);

        this.recordId = recordId || null;
        this.templateType = templateType || null;
        console.log('recordId', this.recordId);
        console.log('templateType', this.templateType);
    }
}