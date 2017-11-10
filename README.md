![Master Google sheets documents icon](https://github.com/brendena/MathEquationsGoogleSlide/blob/master/image/96x96.png?raw=true)

# ![MathEquationsGoogleSlide](https://chrome.google.com/webstore/detail/math-equations/edbiogkpgmbdkmgmdcdmgminoahbcdml?hl=en)
  Allows you to create beatiful images from layout scripting languages.

## Supported Languages
 * Latex
 * AsciiMath
 * MathML

![Example UI Layout](https://github.com/brendena/MathEquationsGoogleSlide/blob/master/image/Example.png?raw=true)

## How it works
  Most of the app is build with Elm.  It has a few ports to manage interaction with Google Script and to work with MathJax.
 
 ![diagram on how it works](https://github.com/brendena/MathEquationsGoogleSlide/blob/master/readmeImages/diagram.png?raw=true)
  

### Elm
There nothing really fancy.  But if your new to elm here are some resources
  * [quick examples](http://elm-lang.org/examples)
  * [great book](https://www.elm-tutorial.org/en/05-resources/02-models.html)

### Index.html
  * **css** - All css is inside of the index.html page.  This is because for the size of the app it was easier to have it external then to have it inside of elm.  It is inside of the html page because you can't import css style sheets in google extensions.  So the styles would need to be in a html page and included with a ["google appscript Scriptlets"](https://developers.google.com/apps-script/guides/html/templates) which would make it impossible to test the app local.
  * **MathJax** - Elm can't handle normal javascript so all the code that hanldes mathJax has to be handled handled inside of the index.html
  * **Canvases/creating image** - There are two canvases.  One to display the equation to the user.  This is inside of the elm code.  Then there is a canvas outside of the elm script.  This secondary canvas is used to create a image that you will send to google app script.  This canvas is hidden and is extremely large, so when you convert it to a image it will look sharp on your slide.


### Google app script
  * **image** - the image is send as a blob and this can be easily converted to a image with this Utilities.newBlob(Utilities.base64Decode(blob), MimeType.PNG);  
  * **reloading images** - To reload a equation, so you can edit it you have load it into a saved property.  I have a dictonary in the saved property called **imageProperties** where they key is the ObjectId and the value is a string of the equation.  You have to save the information as a saved property because there is no way of storing data inside of the image.  There no alternative text section or attribute to put the equation data into so the only way i you could probably save the data inside of the image is to munch the data inside of the image, which would make it hard to find the images that actually have the data inside of them. 

## ToDo
  - Cleaner Error Messages
  - Minify the output of the elm script
