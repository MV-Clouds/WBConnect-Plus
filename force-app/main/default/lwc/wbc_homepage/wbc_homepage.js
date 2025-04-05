import { LightningElement, track, api } from 'lwc';
import logoImg from '@salesforce/resourceUrl/WBConnectplusLogo';
import homePageBGImg from '@salesforce/resourceUrl/homePageBG';
import MenuIcons from '@salesforce/resourceUrl/MenuIcons';

export default class Wbc_homepage extends LightningElement {
    logoUrl = logoImg;
    backgroundStyle = `background-image: url(${homePageBGImg});`;
    @track activeTab = 'Home'; // Default tab
    automationIcon = MenuIcons + '/AutomationIcon.png';
    templateBuilderIcon = MenuIcons + '/TemplateBuilderIcon.png';
    chatWindowIcon = MenuIcons + '/ChatWindowIcon.png';
    broadcastIcon = MenuIcons + '/BroadcastIcon.png';
    configurationIcon = MenuIcons + '/ConfigurationIcon.png';
    importDataIcon = MenuIcons + '/ImportDataIcon.png';
    homeIcon = MenuIcons + '/HomeIcon.png';

    handleActive(event) {
        this.activeTab = event.currentTarget.dataset.name;
    }

    get isHome() {
        return this.activeTab === 'Home';
    }

    get isAutomation() {
        return this.activeTab === 'Automation';
    }

    get isTemplate() {
        return this.activeTab === 'Template';
    }

    get isChatWindow(){
        return this.activeTab === 'ChatWindow';
    }

    get isBroadcast() {
        return this.activeTab === 'Broadcast';
    }

    get isConfiguration() {
        return this.activeTab === 'Configuration';
    }

    get isImportData() {
        return this.activeTab === 'ImportData';
    }
}