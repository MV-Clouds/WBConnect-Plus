import { LightningElement, track, api } from 'lwc';
import logoImg from '@salesforce/resourceUrl/WBConnectplusLogo';
import homePageBGImg from '@salesforce/resourceUrl/homePageBG';

export default class Wbc_homepage extends LightningElement {
    logoUrl = logoImg;
    backgroundStyle = `background-image: url(${homePageBGImg});`;
    @track activeTab = 'ChatWindow'; // Default tab
    loginUrl = '/login';

    handleActive(event) {
        this.activeTab = event.currentTarget.dataset.name;
    }

    get isConfiguration() {
        return this.activeTab === 'Configuration';
    }
    
    get isChatWindow(){
        return this.activeTab === 'ChatWindow';
    }

    get isTemplate() {
        return this.activeTab === 'Template';
    }
    
    get isBroadcast() {
        return this.activeTab === 'Broadcast';
    }
    
    get isBroadcastGroups() {
        return this.activeTab === 'BroadcastGroups';
    }
    
    get isFlows(){
        return this.activeTab === 'Flows';
    }

    get isAWS(){
        return this.activeTab === 'AWS';
    }
    
    get isAutomation() {
        return this.activeTab === 'Automation';
    }
    
    get isImportData() {
        return this.activeTab === 'ImportData';
    }
}