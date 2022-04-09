**Localized static files**

This directory contains the localized static files, one per language.

The static files contains policies and GDPR stuff that is linked inside the App.

CREDIT: The file github.css has been plainly stolen from https://github.com/otsaloma/markdown-css

In order to generate the html files:
````
pandoc it/privacy.md --output=privacy.html --css=github.css --self-contained
pandoc it/terms.md --output=terms.html --css=github.css --self-contained
````

