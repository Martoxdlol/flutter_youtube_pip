# Dev certificate

msix package requires to be signed and windows must trust the certificate used to sign the package.

Official docs: https://learn.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing?source=recommendations

Instructions copied from stack overflow (https://stackoverflow.com/questions/23812471/installing-appx-without-trusted-certificate):

> 1. Generate a signed MSIX file
>
> 1. Right click on MSIX file
>
> 1. Click Properties
>
> 1. Click Digital Signatures
>
> 1. Select Signature from the list
>
> 1. Double-tap the certificate file in the folder and then tap Install Certificate. This displays the Certificate Import Wizard.
>
> 1. In the Store Location group, tap the radio button to change the selected option to Local Machine.
>
> 1. Click Next. Tap OK to confirm the UAC dialog.
>
> 1. In the next screen of the Certificate Import Wizard, change the selected option to Place all certificates in the following store.
>
> 1. Tap the Browse button. In the Select Certificate Store pop-up window, scroll down and select Trusted People, and then tap OK.
>
> 1. Tap the Next button; a new screen appears. Tap the Finish button.
>
> 1. A confirmation dialog should appear; if so, click OK. (If a different dialog indicates that there is some problem with the certificate, you may need to do some certificate troubleshooting. However, describing what to do in that case is beyond the scope of this topic.)