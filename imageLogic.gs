function setImage(jsonImageData){
  var imageSlide = undefined;
  var imageProperties = getSpecificSavedProperties("imageProperties");
  var image = createImageFromBlob(jsonImageData["image"]);
  var slide = SlidesApp.getActivePresentation().getSelection().getCurrentPage();
  if(jsonImageData["linkedMathEquation"] != ""){
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
    "equation": jsonImageData["mathEquation"],
    "equationColor": jsonImageData["mathEquationColor"]
  }
  
  savePropertie("imageProperties", imageProperties)
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
  var imageObjectFromImageProperties = imageProperties[image.getObjectId()]
  if(imageObjectFromImageProperties == undefined)
    throw "not a equation"
  var color = "#000000"

  if (imageObjectFromImageProperties["equationColor"] != undefined &&
      imageObjectFromImageProperties["equationColor"] != null){
    color = imageObjectFromImageProperties["equationColor"];
  }

  return {
      "objectId": image.getObjectId(),
      "equation": imageObjectFromImageProperties["equation"],
      "equationColor": color
  }
}


function deleteDeletedEquations(){
  var listSlides = SlidesApp.getActivePresentation().getSlides();
  var savedImagesDict = getSpecificSavedProperties("imageProperties");
  var savedImagesKeys = [];
  for (var key in savedImagesDict) {
    if (savedImagesDict.hasOwnProperty(key)) {
      savedImagesKeys.push(key);
    }
  }
  ///*
  listSlides.forEach(function(slide){
    var listImages = slide.getImages()
    listImages.forEach(function(image){
      savedImagesKeys = savedImagesKeys.filter(function(savedImageKey){
        return savedImageKey != image.getObjectId()
      });
    });
    
  });
  
  // Know savedImages equals all the keys that dont' have
  // a image in the presenttion
  // know go through and delete all the keys inside of savedImagesKeys
  Logger.log(savedImagesKeys)
  savedImagesKeys.forEach(function(key){
    if (savedImagesDict.hasOwnProperty(key)) {
      delete savedImagesDict[key];
    }
  });
  //*/
  Logger.log(savedImagesDict)
  savePropertie("imageProperties", savedImagesDict)
  //savePropertie("imageProperties", {})
}

function test(){
  Logger.log(getSpecificSavedProperties("imageProperties"))
}