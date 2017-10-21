/*
Notes
https://developers.google.com/apps-script/guides/slides/presentations

https://developers.google.com/apps-script/reference/slides/slides-app
*/

function PropertiesTypes(){
  return {
     "imageProperties":{}
   }
}

function onOpen() {
  SlidesApp.getUi().createMenu('Math Extension')
      .addItem('Menu', 'showSidebar')
      //.addItem('Refresh Data', 'loadDataToSpreadSheet')
      .addToUi();
   Logger.log("started");
}


function showSidebar() {
  /* old way of doing it
  var html = HtmlService.createHtmlOutputFromFile('Page')
      .setTitle('Fit Sync')
      .setWidth(300);
   */
  var html = doGet().setTitle('Math Solver').setWidth(300);
  SlidesApp.getUi() // Or DocumentApp or FormApp.
      .showSidebar(html);
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

function setImage(jsonImageData){
  var imageSlide = undefined;
  var imageProperties = getSpecificSavedProperties("imageProperties");
  var image = createImageFromBlob(jsonImageData["image"]);
  var slide = SlidesApp.getActivePresentation().getSlides()[0];
  if(jsonImageData["linkedMathEquation"] != ""){
    Logger.log("changing Image")
    var imageObjectId = jsonImageData["linkedMathEquation"];
    if( imageObjectId == undefined)
      throw "image does not exist";
    else{
      imageObject = imageProperties[imageObjectId]
      if(imageObject == undefined)
        throw "image is not part of this extension"
        
      imageSlide = findImageSlide(imageObjectId)
      imageSlide.replace(image)
    }
  }
  else{
    Logger.log("New Image")
    imageSlide = slide.insertImage(image);
  }

  
  imageProperties[imageSlide.getObjectId()] = {
    "equation": jsonImageData["mathEquation"]
  }
  
  savePropertie("imageProperties", imageProperties)
}

function createImageFromBlob(blob){
  return Utilities.newBlob(Utilities.base64Decode(blob), MimeType.PNG);  
}

function test(){
  Logger.log(getSpecificSavedProperties("imageProperties"))
}

function findImageSlide(imageObjectId){
  var slide = SlidesApp.getActivePresentation().getSlides()[0];
  var allImage = slide.getImages();
  var imageSlide = undefined;
  for(var i = 0; i < allImage.length; i++){
    if(allImage[i].getObjectId() == imageObjectId){
      imageSlide = allImage[i]
    }
  }
  if(imageSlide == undefined){
    throw "couldn't find the id on this slide"
  }
  return imageSlide;
}

function getLinkedToImage(){ 
  var imageProperties = getSpecificSavedProperties("imageProperties");
  var selection = SlidesApp.getActivePresentation().getSelection();
  var pageElements = selection.getPageElementRange().getPageElements();
  if(pageElements.length <= 0)
    throw "please select a item"
  else if(pageElements.length > 1)
    throw "can only select one item"
  var image = pageElements[0].asImage()
  Logger.log(image.getObjectId())
  var imageObjectFromImageProperties = imageProperties[image.getObjectId()]
  if(imageObjectFromImageProperties == undefined)
    throw "not a equation"
  return {
      "objectId": image.getObjectId(),
      "equation": imageObjectFromImageProperties["equation"]
  }
    
}