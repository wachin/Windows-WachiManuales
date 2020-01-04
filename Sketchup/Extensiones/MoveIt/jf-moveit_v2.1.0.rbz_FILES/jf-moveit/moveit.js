var CTRL = false
var ALT = false
var SHIFT = false
// var DIST = ''

function $(id) { return document.getElementById(id); }
function set_version(v) {
   document.getElementById("plugin_version").innerHTML = v;
}
function onKeyDownHandler(e)
{
   //Debug.write("key down");
   //debugger;
   if (!e) var e = window.event;
   //alert(e.type)
   //alert(e.keyCode)
   if (e.keyCode == 18) ALT = true;
   if (e.keyCode == 16) SHIFT = true;
   info(e.keyCode);

   if (e.keyCode == 17 || e.keyCode == 16)
   {
      window.location = 'skp:keyDownHandler@'+e.keyCode;
      CTRL = true;
   }
   else
   {
      keys(e.keyCode)
   }

}

function onKeyUpHandler(e)
{
   if (!e) var e = window.event;
   k = e.keyCode;
   if (k == 18) ALT = false;
   if (e.keyCode == 16) SHIFT = false;
   if (e.keyCode == 17 || e.keyCode == 16)
   {
      window.location = 'skp:keyUpHandler@'+e.keyCode;
      CTRL = false;
   }
   info('?')
}

document.onkeydown = onKeyDownHandler;
document.onkeyup = onKeyUpHandler;
//document.onmouseover = function(e) {
//   if (document.all && !event.fromElement) window.focus();
//}
//document.onmouseout = function(e) {
//window.blur();
//}


function move(dir) { onKeyDownHandler;window.location='skp:move@' + dir }

function find_wall(dir) { window.location='skp:find_wall@' + dir; }
function rotate(dir) { window.location='skp:rotate@' + dir + "," + $('rot_amt').value }
function drop() { window.location='skp:drop@'+CTRL; }
function select_text(id) { document.getElementById(id).select(); }
function clear_text() { document.getElementById("move_amt").value = ''; }
function find_center() { window.location='skp:find_center' }
function align_view() { window.location='skp:align' }
function setAxis(a) { window.location = 'skp:setAxis@' + a }
//function ad(c) {
//   var v = $('move_amt').value;
//   v = v + String.fromCharCode(c);
//   $('move_amt').value = v;
//}

function keys(kc) {
   // window.location='skp:keys@'+e.keyCode
   // var keys = "0123456789"
   // var units = "
   //if (kc >= 48 && kc <= 57) {
   //$('num').innerHTML = kc;
   //ad(kc)
   //return;
   //}
   //if (kc == 8) {
   //var v = $('move_amt').value;

   //}

   switch (kc) {

      case 38:
      case 87:
	 document.getElementById('ypos').click();
	 break;
      case 39:
      case 68:
	 if (SHIFT == true) {
	    rotate('cw');
	 } else {
	    document.getElementById('xpos').click();
	 }
	 break;
      case 37:
      case 65:
	 if (SHIFT == true) {
	    rotate('ccw');
	 } else {
	    document.getElementById('xneg').click();
	 }
	 break;
      case 40:
      case 83:
	 document.getElementById('yneg').click();
	 break;
      case 33:
	 document.getElementById('zpos').click();
	 break;
      case 34:
	 document.getElementById('zneg').click();
	 break;

      default:
	 window.location='skp:keys@'+kc
	    break;
   }
   // if (event.altKey) alert("alt")

}
// document.onkeydown=keys;


function info(k)
{
   document.getElementById('key').innerHTML = k;
}
