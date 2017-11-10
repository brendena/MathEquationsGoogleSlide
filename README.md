![Master Google sheets documents icon](https://github.com/brendena/MathEquationsGoogleSlide/blob/master/image/96x96.png?raw=true)

# ![MathEquationsGoogleSlide](https://chrome.google.com/webstore/detail/math-equations/edbiogkpgmbdkmgmdcdmgminoahbcdml?hl=en)
  Allows you to create beatiful images from layout scripting languages.

## Supported Languages
 * Latex
 * AsciiMath
 * MathML

![Example UI Layout](https://github.com/brendena/MathEquationsGoogleSlide/blob/master/image/Example.png?raw=true)

## How it works

 ![diagram on how it works](https://github.com/brendena/MathEquationsGoogleSlide/blob/master/readmeImages/diagram.png?raw=true)
  

### Elm version - 0.18

  * **Compilling** Elm code its compiled to SelectInput.js.  Then i use a bash script to convert it to SelectInput.html which i include in index.html
  
Good Resources on Elm
  * [quick examples](http://elm-lang.org/examples)
  * [great book](https://www.elm-tutorial.org/en/05-resources/02-models.html)

### Index.html
  * **css** - All css is inside of the index.html page.  This is because for the size of the app, it was easier to have it inside of the index.html page then to have it inside of elm.  It is inside of the html page because you can't import css style sheets in google extensions.  So the styles would need to be in a html page and included with a ["google appscript Scriptlets"](https://developers.google.com/apps-script/guides/html/templates) which would make it impossible to test the app local.
  * **MathJax** - Elm can't handle normal javascript so all the code that hanldes mathJax has to be handled handled inside of the index.html
  * **Canvas'/creating image** - There are two canvas.  One to display the equation to the user.  This is inside of the elm code.  Then there is a canvas outside of the elm script.  This secondary canvas is used to create a image that you will be send to google app script.  This canvas is hidden and is large, so when you convert it to a image it will look sharp on your slide.


### Google app script
  * **image** - the image is send as a blob and this can be easily converted to a image with this Utilities.newBlob(Utilities.base64Decode(blob), MimeType.PNG);  
  * **reloading images** - To reload a equation, so you can edit it you have load it into a saved property.  I have a dictonary in the saved property called **imageProperties** where they key is the ObjectId and the value is a string of the equation.  You have to save the information as a saved property because there is no way of storing data inside of the image.  There no alternative text section or attribute to put the equation data into so the only way, so saving it inside of saved property was the second best option.
  * **savedProperties** - i have a seperate file to make using saved propertys easier.  I save all the properties into a single key called **savedProperties** which is also a dictionary which make working with saved data as easy as working with a dictionary object.



## Build
### Local Development
  * remove any **<\?!= include('Text'); ?>**  -index.html
  * make sure **<script src="SelectInput.js"></script>** is included -index.html
  * elm-make SelectInput.elm --output=SelectInput.js
  * Then you can open the index.html page
  
### Google Extension Development
  * Use this [extension](https://chrome.google.com/webstore/detail/google-apps-script-github/lfjcgcmkmjjlieihflfhjopckgpelofo) to pull the latest code from a github repo
  * add **<\?!= include('Text'); ?>** -index.html
  * remove **<script src="SelectInput.js"></script>** -index.html
  
## Pushing Code
### Local Development
  1. run ElmbBuid.bash
  2. git push
### Google Extension Development
  1. use this [extension](https://chrome.google.com/webstore/detail/google-apps-script-github/lfjcgcmkmjjlieihflfhjopckgpelofo) and hit the push button.  

## ToDo
  - Cleaner Error Messages
  - Minify the output of the elm script
