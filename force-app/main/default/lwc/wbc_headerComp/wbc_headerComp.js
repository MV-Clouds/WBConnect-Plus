import { LightningElement, track } from 'lwc';
import logoImg from '@salesforce/resourceUrl/WBConnectplusLogo';
import PROFILE from '@salesforce/resourceUrl/MVC_Profile';
import homePageBGImg from '@salesforce/resourceUrl/homePageBG';
import { NavigationMixin } from "lightning/navigation";

export default class Wbc_headerComp extends NavigationMixin(LightningElement) {
    logoUrl = logoImg;
    backgroundStyle = `background-image: url(${homePageBGImg});`;
    @track profileUrl = PROFILE;
    @track isdropdownOpen = false;

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

    // handleDropdownButtonClick(event) {
    //     event.stopPropagation();

    //     let textContent = event.target.textContent;
    //     if(textContent == 'My Profile'){
    //         window.location.href = '#';
    //     } else if(textContent == 'Reset Password') {
    //         // window.location.href = '/s/ForgotPassword/';
    //         this[NavigationMixin.Navigate]({
    //             type: 'comm__namedPage',
    //             attributes: {
    //                 name: 'Forgot_Password',
    //             },
    //         });
    //     } else if(textContent == 'Logout') {
    //         // window.location.href = '/s/login/';
    //         this[NavigationMixin.Navigate]({
    //             type: 'comm__namedPage',
    //             attributes: {
    //                 name: 'Login',
    //             },
    //         });
    //     }
    // }

    handleResetPass(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Forgot_Password',
            },
        });
    }

    handleLogout(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Login',
            },
        });
    }
}