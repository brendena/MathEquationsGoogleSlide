function setImage(jsonImageData){
  var imageSlide = undefined;
  
  //var imageProperties = getSpecificSavedProperties("imageProperties");
  
  var image = createImageFromBlob(jsonImageData["image"]);
  var slide = SlidesApp.getActivePresentation().getSelection().getCurrentPage();
  
  // if the equation was not linked
  if(jsonImageData["linkedMathEquation"] != ""){
    var imageObjectId = jsonImageData["linkedMathEquation"];

    imageSlide = findImageSlide(imageObjectId)
    imageSlide.replace(image)
  }  // if the equation was linked
  else{
    Logger.log("New Image")
    imageSlide = slide.insertImage(image);
    


  }
  
  //set Image size
  var sizeEquationHeight = jsonImageData["mathEquationSize"];

  imageSlide.setWidth(sizeEquationHeight * jsonImageData["ratio"] );
  imageSlide.setHeight(sizeEquationHeight );

  return imageSlide.getObjectId();
  
}

function addAltText(jsonImageData, objectId) 
{
  var image = findImageSlide(objectId);

  var requests = [{
    updatePageElementAltText: 
    {
      objectId: image.getObjectId(),
      title: createAltTitle(jsonImageData),
      description: jsonImageData["mathEquation"],
    }
    
  }];
  try {
    var batchUpdateResponse = Slides.Presentations.batchUpdate({
      requests: requests
    },SlidesApp.getActivePresentation().getId());
    setImage = true;
  } catch (e) {
    throw ("BatchUpdateError -  " + e);
  }
}

function createImageFromBlob(blob){
  return Utilities.newBlob(Utilities.base64Decode(blob), MimeType.PNG);  
}

function findImageSlide(imageObjectId){
  var slide = SlidesApp.getActivePresentation().getSelection().getCurrentPage();
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
  var selectionRange = selection.getPageElementRange();
 
  if(selectionRange == null)            
    throw "you need to select a image to reload the equation back into the text box"    
    
  var pageElements = selectionRange.getPageElements();
  
  if(pageElements.length <= 0)
    throw "please select a item"
  else if(pageElements.length >= 2)
    throw "can only select one item"
    
    
  var image = pageElements[0].asImage()
  
  
  var imageProperties;
  {
    //old way of loading image
    imageProperties = imageProperties[image.getObjectId()]
    if(imageProperties == undefined)
    {
      
      var altTextTitle = image.getTitle();
      imageProperties = getAltTextData(altTextTitle);
      imageProperties["equation"] = image.getDescription();
    }
  }

  if (imageProperties["equationColor"] == undefined &&
      imageProperties["equationColor"] == null){
    imageProperties["equationColor"] = "#000000";
  }
  return {
      "objectId": image.getObjectId(),
      "equation":  imageProperties["equation"],
      "equationColor": imageProperties["equationColor"],
      "equationSize": image.getHeight()
  }
}


function test(){
  Logger.log(getSpecificSavedProperties("imageProperties"))
}

function createAltTitle(jsonImageData){
  return "MathEquation,"+ jsonImageData["mathEquationColor"];
}

function getAltTextData(altTextTitle){
  if(altTextTitle.search("MathEquation") == -1){
    throw "Alt Text data doesn't match";
  }
  var splitData = altTextTitle.split(",");
  
  return {
    "equationColor": splitData[1]
  }
  
}
