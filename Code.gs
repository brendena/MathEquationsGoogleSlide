/*
Notes
https://developers.google.com/apps-script/guides/slides/presentations

https://developers.google.com/apps-script/reference/slides/slides-app
*/
/*            
very cool example             
https://chrome.google.com/webstore/detail/equatio-math-made-digital/hjngolefdpdnooamgdldlkjgmdcmcjnc            
*/
/**
 * @OnlyCurrentDoc
 */

function PropertiesTypes(){
  return {
     "imageProperties":{}
   }
}

function onOpen() {
  SlidesApp.getUi().createMenu('Math Equations')
      .addItem('Menu', 'showSidebar')
      //.addItem('Refresh Data', 'loadDataToSpreadSheet')
      .addToUi();
   Logger.log("started");
}


function showSidebar() {
  
  var html = doGet().setTitle('Math Solver').setWidth(300);
  SlidesApp.getUi() // Or DocumentApp or FormApp.
      .showSidebar(html);
  
   //everTime you open the slide show it will look
   //through all images and delete the saved data
   //on images that have been manually deleted
   deleteDeletedEquations()
}

function showEquationEditingMenu(){            
    var html = HtmlService            
    .createTemplateFromFile('editEquationMenu')            
    .evaluate().setWidth(600).setHeight(425);            
    SlidesApp.getUi().showModalDialog(html, 'Equation Editor');            
}

function onInstall(){
  onOpen();
}


function doGet() {
  return HtmlService
      .createTemplateFromFile('index')
      .evaluate();
}

function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename)
      .getContent();
}

