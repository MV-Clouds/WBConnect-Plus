import { LightningElement, track, api } from 'lwc';
import logoImg from '@salesforce/resourceUrl/WBConnectplusLogo';
import PROFILE from '@salesforce/resourceUrl/defaultProfile';
import homePageBGImg from '@salesforce/resourceUrl/homePageBG';

export default class Wbc_homepage extends LightningElement {
    logoUrl = logoImg;
    backgroundStyle = `background-image: url(${homePageBGImg});`;
    @track profileUrl = PROFILE;
    @track activeTab = 'ChatWindow'; // Default tab
    @track isdropdownOpen = false;

    @track tabClasses = {
        ChatWindow: 'barchild active-tab',
        Configuration: 'barchild',
        Template: 'barchild',
        Broadcast: 'barchild',
        BroadcastGroups: 'barchild',
        Flows: 'barchild',
        AWS: 'barchild',
        Automation: 'barchild',
        ImportData: 'barchild'
    };


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
    
    connectedCallback() {
        document.addEventListener('click', this.handleOutsideClick);
    }

    renderedCallback() {
        if (!this._listenersAttached) {
            document.addEventListener('click', this.handleOutsideClick);
            this._listenersAttached = true;
        }
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.handleOutsideClick);
    }

    handleToggleDropdown(event) {
        event.stopPropagation();
        this.isdropdownOpen = !this.isdropdownOpen;
    }

    handleOutsideClick = (event) => {
        // Check if the click is outside the dropdown and profile picture
        const dropdown = this.template.querySelector('.profile-dropdown');
        const profileToggle = this.template.querySelector('.profileToggle');

        if (
            dropdown &&
            profileToggle &&
            !dropdown.contains(event.target) &&
            !profileToggle.contains(event.target)
        ) {
            this.isdropdownOpen = false;
        }
    };

    handleActive(event) {
        this.activeTab = event.currentTarget.dataset.name;

        // Update tab classes dynamically
        Object.keys(this.tabClasses).forEach((tab) => {
            this.tabClasses[tab] = tab === this.activeTab ? 'barchild active-tab' : 'barchild';
        });
    }

    // handleDropdownButtonClick(event) {
    //     event.stopPropagation();

    //     let textContent = event.target.textContent;
    //     if(textContent == 'My Profile'){
    //         window.location.href = '#';
    //     } else if(textContent == 'Reset Password') {
    //         // window.location.href = '/s/ForgotPassword';
    //         window.open("/wbconnectplus/s/ForgotPassword","_self")
    //     } else if(textContent == 'Logout') {
    //         // window.location.href = '/s/login';
    //         window.open("wbconnectplus/s/login","_self")
    //     }
    // }

    handleDropdownButtonClick(event) {
        event.stopPropagation();

        let textContent = event.target.textContent;
        if(textContent == 'My Profile'){
            window.location.href = '#';
        } else if(textContent == 'Reset Password') {
            window.location.href = '/wbconnectplus/s/ForgotPassword';
        } else if(textContent == 'Logout') {
            window.location.href = '/wbconnectplus/s/login';
        }
    }
}