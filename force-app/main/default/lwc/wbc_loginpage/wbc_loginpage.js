import { LightningElement, track, api } from 'lwc';
import logoImg from '@salesforce/resourceUrl/WBConnectplusLogo'; // Logo image
import Login_BG from '@salesforce/resourceUrl/Login_BG'; // Logo image
import LoginIllustrationImg from '@salesforce/resourceUrl/LoginIllustration'; // Logo image
import poweredByMVCImg from '@salesforce/resourceUrl/poweredByMVC'; // Logo image
import login from '@salesforce/apex/LoginController.login';

export default class Wbc_loginpage extends LightningElement {
    @track email;
    @track password;
    @track error;
    @track isLoading = false;

    // Public properties configurable in Experience Builder
    @api startUrl = '/wbconnectplus/'; // Default redirect location after login
    @api forgotPasswordUrl = '/ForgotPassword'; // Default Forgot Password page URL
    @api selfRegisterUrl = '/SelfRegister'; // Default Self Registration page URL
    logoUrl = logoImg;
    LoginIllustration = LoginIllustrationImg;
    poweredByMVC = poweredByMVCImg
    backgroundStyle = `background-image: url(${Login_BG});`;

    get forgotPasswordUrlComputed() {
        return this.forgotPasswordUrl && this.forgotPasswordUrl.startsWith('/') ? this.forgotPasswordUrl : '/ForgotPassword';
    }

    get selfRegisterUrlComputed() {
        return this.selfRegisterUrl && this.selfRegisterUrl.startsWith('/') ? this.selfRegisterUrl : '/SelfRegister';
    }

    handleEmailChange(event) {
        this.email = event.target.value;
        this.error = undefined;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
        this.error = undefined;
    }

    handleLogin(event) {
        event.preventDefault(); 

        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            this.error = 'Please fill in all required fields.';
            return;
        }

        this.isLoading = true;
        this.error = undefined;

        login({ username: this.email, password: this.password })
            .then(result => {
                const destinationUrl = result || this.startUrl;
                window.location.href = destinationUrl;
            })
            .catch(error => {
                console.error('Login Error:', error);
                this.error = this.getErrorMessage(error);
                this.isLoading = false;
            });
    }

    getErrorMessage(error) {
        let message = 'Unknown error';
        
        if (error && error.body && error.body.message) {
            message = error.body.message;
        }
        
        else if (error && error.message) {
            message = error.message;
        } else if (typeof error === 'string') {
            message = error;
        }
        return message;
    }
}