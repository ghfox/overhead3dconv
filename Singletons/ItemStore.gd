extends Node

var res = "res://Spr/Items/"

var s_cal = "cal"
var s_sprite = "sprite"
var s_normal = "normal"
var s_spd = "spd"
var s_dam = "dam"
var s_pen = "pen"


var w = {
	"PeaShooter" : {
		"name" : "PeaShooter",
		"cat" : "pistol",
		s_cal : "9mm",
		"cooldown" : 0.6,
		s_dam : 1,
		"topoff" : false,
		s_spd : 200
	}
}

func getMagSprite(type):
	var sprite = "%s%s" % [res,m[type]["sprite"]]
	return sprite

func getMagNormal(type):
	var normal = "%s%s" % [res,m[type]["normal"]]
	return normal

func getMagCal(type):
	return m[type]["cal"]

func getMagCap(type):
	return m[type]["cap"]

var m = {
	"9mm 10rd Mag" : {
		s_cal : "9mm",
		"cap" : 10,
		s_sprite : "smallMag.png",
		s_normal : "smallMagNormal.png"
	}
}

func getAmmoSprite(cal,subtype):
	var sprite = "%s%s" % [res,b[cal][subtype]["sprite"]]
	return sprite

func getAmmoNormal(cal,subtype):
	var normal = "%s%s" % [res,b[cal][subtype]["normal"]]
	return normal

var b = {
	"9mm" : {
		"fmj" : {
			s_dam : 5.0,
			s_pen : 3.0,
			s_spd : 0,
			s_sprite : "9mmfmjbox.png",
			s_normal : "boxNormal.png"
		}, 
		"hp" : {
			s_dam : 9.0,
			s_pen : 2.0,
			s_spd : 0,
			
			s_normal : "boxNormal.png"
		},
		 "fluted" : {
			s_dam : 7.0,
			s_pen : 4.0,
			s_spd : 0,
			
			s_normal : "boxNormal.png"
		}
	} 
}
