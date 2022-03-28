extends Node

var pack = {}
var pocket = [Nothing.new(),Nothing.new(),Nothing.new(),Nothing.new()]
var hand = Nothing.new()
var player
var selectedPocket = 0

#arrays for pockets
var weapons	= []
var mags = []
var items = []

var magsCursor = -1
var weaponsCursor = -1
var itemsCursor = -1

#remember all built-in types are passed as value, EXCEPT arrays & dicts

func _ready():
	pack = {
		Weapon.type : [Weapon.new("PeaShooter")],
		Magazine.type : [Magazine.new("9mm 10rd Mag"),Magazine.new("9mm 10rd Mag"),Magazine.new("9mm 10rd Mag")],
		Ammo.type : [Ammo.new("9mm","fmj",25)]
	}
	pack["mag"][0].fillMag(pack["ammo"][0])
	pack["mag"][2].fillMag(pack["ammo"][0])
	pack["mag"][1].fillMag(pack["ammo"][0])
	moveToPocketFromPack(pack["mag"][0],0)
	loadFromPocket(pack["weapon"][0],0)
	moveToPocketFromPack(pack["mag"][0],0)
	moveToPocketFromPack(pack["mag"][0],1)
	equip(pack["weapon"],0)
	

func equip(group, idx):
	hand = group[idx]
	group.remove(idx)
	magsCursor = 0
	buildMagList(hand.cal)

func addToPack(item):
	pack[item.type].push_back(item)

func moveToPocketFromPack(item, pockIdx):
	if(pocket[pockIdx].type != "null"):
		pack[pocket[pockIdx].type].append(pocket[pockIdx])
	pocket[pockIdx] = item
	pack[item.type].remove(pack[item.type].find(item,0))

func moveToPocket(item, pockIdx):
	if(pocket[pockIdx].type != "null"):
		return false
	pocket[pockIdx] = item

func findEmptyPocket():
	var found = -1
	for p in pocket:
		found += 1
		if(p.type == Nothing.type):
			return found
	return -1


#														MAGAZINE RELATED Methods
func buildMagList(cal):
	mags = []
	for p in pocket.size():
		if (pocket[p].type == "mag"):
			if(pocket[p].cal == cal):
				if(pocket[p].store > 0):
					mags.append(p)
	if(mags.size() == 0):
		magsCursor = -1

func changeMag(keepMag):
	if(keepMag):
		swapForNextMag()
		magsCursor += 1	#advance the cursor
	else:
		loadNextMag()	#cursor won't advance since we are disposing of inventory
	findNextMag()

func swapForNextMag():
	var temp = hand.curMag
	loadNextMag()
	moveToPocket(temp,mags[magsCursor])

func loadNextMag():
	return loadFromPocket(hand,mags[magsCursor])

func findNextMag():
	if(magsCursor >= mags.size()):	#if we're outside the list before rebuild wrap
		magsCursor = 0
	buildMagList(hand.cal)
	if(magsCursor > mags.size()):	#if 0 mags, cursor will be -1
		magsCursor = mags.size()

func loadFromPocket(weapon, pockIdx):
	var obj = pocket[pockIdx]
	if(weapon.addMag(obj)):
		pocket[pockIdx] = Nothing.new()
		return true
	return false
