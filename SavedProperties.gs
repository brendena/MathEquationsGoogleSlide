// array for document ids
var nameGlobalProperties = "savedProperties";



function getAllSavedProperties(){
  var savedPropertiesString =  getUserProperties().getProperty(nameGlobalProperties);
  //Logger.log(savedPropertiesString);
  var savedPropertiesJson = JSON.parse(savedPropertiesString)
  if(savedPropertiesJson == null || typeof(savedPropertiesJson) !== "object" ||savedPropertiesJson == 'undefined' || Array.isArray(savedPropertiesJson) === true){ // typeof(savedPropertiesJson) === "Object" ||
    savedPropertiesJson = {};
  }
  return savedPropertiesJson;
}

function getSpecificSavedProperties(properties){
  var savedProperties = getAllSavedProperties();
  var returnProperties = undefined;
  if(Array.isArray(properties)){
    returnProperties = {};
    properties.forEach(function(property){
      returnProperties[property] = checkDefaultValue(properties, savedProperties[property]);
    });
  }
  else{
    returnProperties = checkDefaultValue(properties, savedProperties[properties]);
  }
  return returnProperties;
}

function savePropertie(propertyName, value){
  try {
    var savedProperties = this.getAllSavedProperties();
    savedProperties[propertyName] = value
    saveProperties(savedProperties);
  } catch (f) {
    Logger.log(f.toString());
  }
}

function saveProperties(JsonProperties){
  getUserProperties().setProperty(nameGlobalProperties, JSON.stringify(JsonProperties));
}



function resetProperties() {
  saveProperties({});
}

 

function getUserProperties(){
  return  PropertiesService.getUserProperties();
}

function setSavedPropertiesValues(value){
  savePropertie(nameGlobalPropertiesTypes, value);
}

function checkDefaultValue(propertyName, propertyValue){
  var propertiesTypes = PropertiesTypes();
  if(propertyValue == undefined){
    return propertiesTypes[propertyName];
  }
  return propertyValue;
}

