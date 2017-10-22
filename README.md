![Master Google sheets documents icon](https://github.com/brendena/MathEquationsGoogleSlide/blob/master/image/96x96.png?raw=true)

# MathEquationsGoogleSlide
  Allows you to create beatiful images from layout scripting languages.

## Supported Languages
 * Latex
 * AsciiMath
 * MathML

![Example UI Layout](https://github.com/brendena/MathEquationsGoogleSlide/blob/master/image/Example.png?raw=true)

## How it works
  Most of the app is build with Elm.  It has a few ports to manage interaction with Google Script and to work with MathJax.
  
## ToDo
  - Currently if you delete a image the equations information is still save storage.  On everload i need to check internal storage and compare the images inisde of the internal storage with the one's inside of the slideshow.
  - Cleaner Error Messages
  - Make sure that the Google Auth is set up properly
  - Add google analytics 
