// Define all the elements needed
// JavaScript Variables
var minifigure = document.querySelector('.minifigure');
var faces = document.querySelector('.faces');
var upperBody = document.querySelector('.upper-body');
var lowerBody = document.querySelector('.lower-body');
var explode = document.querySelector('.explode');

// Toggle explode state
function explodeMinifigure() {
  minifigure.classList.toggle('explode');
  
  if (minifigure.classList.contains('explode')) {
    explode.innerHTML = 'Rebuild';
  } else {
    explode.innerHTML = 'Explode';
  }
};

// Set expression based on a value between 0 and 5 (index for different faces)
function setExpression(expressionIndex) {
  var expressionVal = expressionIndex * 100; // Map expression to percentage for CSS transform
  faces.style.transform = 'translateX(-' + expressionVal + '%)';
};

// Set colors of the minifigure's upper and lower body
function setColors(upperHue, upperSaturation, upperLightness, lowerHue, lowerSaturation, lowerLightness) {
  upperBody.style.color = `hsl(${upperHue}, ${upperSaturation}%, ${upperLightness}%)`;
  lowerBody.style.color = `hsl(${lowerHue}, ${lowerSaturation}%, ${lowerLightness}%)`;
};

// Randomize expression and colors
function randomizeInputs() {
  var randomExpression = Math.floor(Math.random() * 5); // Random expression index
  var randomUpperHue = Math.random() * 360;
  var randomUpperSaturation = Math.random() * 100;
  var randomUpperLightness = Math.random() * 90;
  var randomLowerHue = Math.random() * 360;
  var randomLowerSaturation = Math.random() * 100;
  var randomLowerLightness = Math.random() * 90;
  
  setExpression(randomExpression);
  setColors(randomUpperHue, randomUpperSaturation, randomUpperLightness, randomLowerHue, randomLowerSaturation, randomLowerLightness);
};

// Expose methods for Flutter to call
window.explodeMinifigure = explodeMinifigure;
window.setExpression = setExpression;
window.setColors = setColors;
window.randomizeInputs = randomizeInputs;
