################################################################################
#
# IP of your development machine on the LAN
# Always 'make veryclean' before changing this!
#
LOCAL_IP=192.168.0.17
#
# Coordinates of PiBeaconSoilSensor
#
PI_THING_POS=1 1 10
#
# Where you want the release Android apk to be copied
#
RELEASE_TARGET=../net/netmash.net/NetMash.apk
#
################################################################################

tutorial: runtut
	google-chrome 'http://localhost:8081/#http://localhost:8081/o/uid-7081-c95e-1c04-d7a5.json'

examples: runstt
	google-chrome 'http://localhost:8081/#http://localhost:8081/o/uid-f25a-08e1-7d7d-09f8.json'

ide: runide
	google-chrome 'http://localhost:8081/#http://localhost:8081/o/uid-7a34-bcaf-88d5-b63e.json'

iot: androidlan runiot lancat
	google-chrome 'http://localhost:8081/#http://localhost:8081/o/uid-ccb8-43de-df47-29da.json'

mctut: runmct
	google-chrome 'http://localhost:8081/#http://localhost:8081/o/uid-1044-e6e9-125e-e35c.json'

cars: runcars
	google-chrome 'http://localhost:8082/#http://localhost:8082/o/uid-459e-4ba6-0b4b-5786.json'

capweb: runcapw
	google-chrome 'http://localhost:8082/#http://localhost:8082/o/uid-c102-dd84-8284-c360.json'

####################

apk: androidapk lancat

emu: androidemu runemu logcat

lan: androidlan runlan lancat

lan1: androidlan runlan tailtestresults1

lan2: androidlan runlan tailtestresults2

cap: androidemu runcap logcat

####################

tests: json uid cyrus

cyrus: runom tailtestresults2

cyrus1: runom1 tailtestresults2

####################

all: androidemu runall logcat

loc: androidemu        logcat

rem: androidrem

lap: androidlan runlap lancat

sta: androidemu runsta logcat

# -------------------------------------------------------------------

demo: editstaticdb androidemu runquickserver logboth editdynamicfile

quickdyn: editquickdb androidemu runquickserver logboth editdynamicfile

# -------------------------------------------------------------------

httplog1:
	tail -999f src/server/vm1/cyrus.log | egrep '\------|Cache-Notify:|If-None-Match:|ETag:|Content-Type:|Content-Location:|^ +|^{ |^}|HTTP.1.1'

httplog2:
	tail -999f src/server/vm2/cyrus.log | egrep '\------|Cache-Notify:|If-None-Match:|ETag:|Content-Type:|Content-Location:|^ +|^{ |^}|HTTP.1.1'

# -------------------------------------------------------------------

setlanip: veryclean
	vi makefile

editstaticdb:
	vi -o -N src/server/vm1/static.db

editquickdb:
	vi -o -N src/server/vm1/quick.db

editlocaldb:
	vi -o -N src/server/vm1/local.db

editdynamicfile:
	vi -o -N src/server/vm1/functional-hyper.db src/server/vm1/functional-hyperule.db

editlocaldbanddynamicfile:
	vi -o -N src/server/vm1/local.db src/server/vm1/guitest.db

editide:
	vi -o -N src/server/vm1/ideconfig.db src/server/vm2/ideconfig.db

# -------------------------------------------------------------------

androidemu: clean init setappemuconfig setemumapkey
	./gradlew build
	( adb -d uninstall cyrus.gui && adb -d install ./app/build/outputs/apk/app-debug.apk ) &

androidlan: clean init setapplanconfig setremmapkey
	./gradlew build
	( adb -d uninstall cyrus.gui && adb -d install bin/NetMash-release.apk ) &
	cp bin/NetMash-release.apk $(RELEASE_TARGET)

androidapk: clean init setremmapkey
	./gradlew build
	( adb -d uninstall cyrus.gui && adb -d install bin/NetMash-release.apk ) &
	cp bin/NetMash-release.apk $(RELEASE_TARGET)

androidrem: clean init setappremconfig setremmapkey
	./gradlew build
	cp bin/NetMash-release.apk $(RELEASE_TARGET)

installemu:
	adb -e install ./app/build/outputs/apk/app-debug.apk

installlan:
	adb -d install bin/NetMash-release.apk

uninstallemu:
	adb -e uninstall cyrus.gui

uninstalllan:
	adb -d uninstall cyrus.gui

reinstallemu: uninstallemu installemu

reinstalllan: uninstalllan installlan

reinstalllog: reinstalllan lancat

runnetmash:
	adb -d shell am start -n cyrus.gui/cyrus.gui.NetMash

# -------------------------------------------------------------------

runlomc: kill clean netconfig usemcdbs setvm1tstconfig run1

runremc: kill clean netconfig usemcdbs setvm1remconfig run1

runall: kill clean netconfig usealldbs setvm3emuconfig run1n2

runemu: kill clean netconfig useworlddb setvm3emuconfig run1n2

runlan: kill clean netconfig useworlddb setvm3lanconfig run1n2

runiot: killroot clean netconfig useiotdb setvm1lanconfig run1

runiotl: killroot clean netconfig useiotdb setvm1lanconfig setvm2iotconfig run1n2root

runiot2: killroot netconfig useiotdb2 setvm2iotconfig2 run1n2root
	google-chrome 'http://localhost:8081/#http://localhost:8081/o/uid-ccb8-43de-df47-29da.json'

runliot: killroot netconfig usenodb  setvm2iotconfig run2root

runrem: kill clean netconfig useworlddb setvm3remconfig run1n2

runom:  kill       omconfig  useomdb    setvm2tstconfig run2

runom1:  kill      om1config  useom1db   setvm2tstconfig run2

runcars: kill clean netconfig usecarsdb setvm3tstconfig run1n2

runcap:  kill clean netconfig useworlddb usecapdb setvm3emuconfig run1n2

runcapw: kill clean netconfig usecapdb setvm2tstconfig run2

runlap:  kill clean netconfig usecapdb setvm2lanconfig run2

runtut: kill       netconfig usetutordb setvm3tstconfig run1n2

runide: kill        ideconfig                           run1n2

runmct: kill clean netconfig usemctutdb setvm1tstconfig run1

runstt: kill clean netconfig usestaticdb setvm1tstconfig run1

runsta: kill clean netconfig usestaticdb setvm1emuconfig run1

runcur: kill clean curconfig usetestdb setvm3tstconfig run1n2

runtst: kill clean tstconfig usetestdb setvm3tstconfig run1n2

runone: kill clean netconfig usetestdb setvm1tstconfig run1

runtwo: kill clean curconfig usetestdb setvm3emuconfig run1n2

# -------------------------------------------------------------------

runode:
	( cd src/js/ ; node js/server.js > cyrus.log 2>&1 & )

# -------------------------------------------------------------------

runon1:
	( cd src/server/vm1 ; java -classpath .:../../../build/cyrus.jar cyrus.NetMash > cyrus.log 2>&1 & )

runon2:
	( cd src/server/vm2 ; java -classpath .:../../../build/cyrus.jar cyrus.NetMash > cyrus.log 2>&1 & )

json: jar
	java -ea -classpath ./build/cyrus.jar cyrus.lib.TestJSON

uid: jar
	java -ea -classpath ./build/cyrus.jar cyrus.forest.UID

run1: jar
	(cd src/server/vm1; ./run.sh)

run2: jar
	(cd src/server/vm2; ./run.sh)

run2root: jar
	(cd src/server/vm2; sudo ./run.sh)

run1g: jar
	(cd src/server/vm1; ./run-g.sh)

run1n2: run1 run2

run1n2root: run1 run2root

# -------------------------------------------------------------------

usemcdbs:
	cp  src/minecraft/helpful-animals.db src/server/vm1/cyrus.db
	cat src/minecraft/copy-n-paste.db >> src/server/vm1/cyrus.db
	cat src/server/vm1/mc-tutorial.db >> src/server/vm1/cyrus.db

usealldbs: useworlddb
	cat src/server/vm1/static.db >> src/server/vm1/cyrus.db
	cat src/server/vm2/cap.db    >> src/server/vm2/cyrus.db

useworlddb:
	cp  src/server/vm1/world.db    src/server/vm1/cyrus.db
	cp  src/server/vm2/world.db    src/server/vm2/cyrus.db
	cat src/server/vm2/room.db  >> src/server/vm2/cyrus.db

usenodb:
	rm -f src/server/vm1/cyrus.db src/server/vm2/cyrus.db

useiotdb:
	cp src/server/vm1/iot.db src/server/vm1/cyrus.db
	rm -f                    src/server/vm2/cyrus.db

useiotdb2:
	cp  src/server/vm1/iot.db      src/server/vm1/cyrus.db
	cat src/server/vm2/iotnm.db >> src/server/vm1/cyrus.db
	rm -f                          src/server/vm2/cyrus.db

useomdb:
	cp src/server/vm2/om.db src/server/vm2/cyrus.db

useom1db:
	cp src/server/vm2/om1.db src/server/vm2/cyrus.db

usecapdb:
	cp src/server/vm2/cap.db src/server/vm2/cyrus.db

usecarsdb:
	cp src/server/vm1/cars.db src/server/vm1/cyrus.db
	cp src/server/vm2/cars.db src/server/vm2/cyrus.db

usetestdb:
	cp src/server/vm1/test.db src/server/vm1/cyrus.db
	cp src/server/vm2/test.db src/server/vm2/cyrus.db

usetutordb:
	cp src/server/vm1/tutorial.db src/server/vm1/cyrus.db
	cp src/server/vm2/tutorial.db src/server/vm2/cyrus.db

usemctutdb:
	cp src/server/vm1/mc-tutorial.db src/server/vm1/cyrus.db

usestaticdb:
	cp src/server/vm1/static.db src/server/vm1/cyrus.db

setremmapkey:
	sed -i"" -e "s:03Hoq1TEN3zaDOQmSJNHwHM5fRQ3dajOdQYZGbw:03Hoq1TEN3zbEGUSHYbrBqYgXhph-qRQ7g8s3UA:" src/android/cyrus/gui/NetMash.java

setemumapkey:
	sed -i"" -e "s:03Hoq1TEN3zbEGUSHYbrBqYgXhph-qRQ7g8s3UA:03Hoq1TEN3zaDOQmSJNHwHM5fRQ3dajOdQYZGbw:" src/android/cyrus/gui/NetMash.java

setappemuconfig:
	sed -i"" -e "s:the-cyrus.net:10.0.2.2:g" res/raw/cyrusconfig.db
	sed -i"" -e "s:the-cyrus.net:10.0.2.2:g" src/android/cyrus/User.java
	sed -i"" -e   "s:$(LOCAL_IP):10.0.2.2:g" res/raw/cyrusconfig.db
	sed -i"" -e   "s:$(LOCAL_IP):10.0.2.2:g" src/android/cyrus/User.java

setapplanconfig:
	sed -i"" -e "s:the-cyrus.net:$(LOCAL_IP):g" res/raw/cyrusconfig.db
	sed -i"" -e "s:the-cyrus.net:$(LOCAL_IP):g" src/android/cyrus/User.java
	sed -i"" -e      "s:10.0.2.2:$(LOCAL_IP):g" res/raw/cyrusconfig.db
	sed -i"" -e      "s:10.0.2.2:$(LOCAL_IP):g" src/android/cyrus/User.java

setappremconfig:
	sed -i"" -e    "s:10.0.2.2:the-cyrus.net:g" res/raw/cyrusconfig.db
	sed -i"" -e    "s:10.0.2.2:the-cyrus.net:g" src/android/cyrus/User.java
	sed -i"" -e "s:$(LOCAL_IP):the-cyrus.net:g" res/raw/cyrusconfig.db
	sed -i"" -e "s:$(LOCAL_IP):the-cyrus.net:g" src/android/cyrus/User.java

setvm1emuconfig:
	sed -i"" -e   "s:localhost:10.0.2.2:g" src/server/vm1/cyrusconfig.db
	sed -i"" -e "s:$(LOCAL_IP):10.0.2.2:g" src/server/vm1/cyrusconfig.db
	sed -i"" -e   "s:localhost:10.0.2.2:g" src/server/vm1/cyrus.db
	sed -i"" -e "s:$(LOCAL_IP):10.0.2.2:g" src/server/vm1/cyrus.db

setvm2emuconfig:
	sed -i"" -e   "s:localhost:10.0.2.2:g" src/server/vm2/cyrusconfig.db
	sed -i"" -e "s:$(LOCAL_IP):10.0.2.2:g" src/server/vm2/cyrusconfig.db
	sed -i"" -e   "s:localhost:10.0.2.2:g" src/server/vm2/cyrus.db
	sed -i"" -e "s:$(LOCAL_IP):10.0.2.2:g" src/server/vm2/cyrus.db

setvm3emuconfig: setvm1emuconfig setvm2emuconfig

setvm3cleanconfig:
	sed -i"" -e    "s:10.0.2.2:localhost:g" src/server/vm1/cyrusconfig.db
	sed -i"" -e "s:$(LOCAL_IP):localhost:g" src/server/vm1/cyrusconfig.db
	sed -i"" -e "s:$(LOCAL_IP):localhost:g"                      src/server/vm2/PiBeaconSoilSensor.java
	sed -i"" -e  "s#position: $(PI_THING_POS)#position: 0 0 0#g" src/server/vm2/PiBeaconSoilSensor.java

setvm1lanconfig:
	sed -i"" -e "s:localhost:$(LOCAL_IP):g" src/server/vm1/cyrusconfig.db
	sed -i"" -e  "s:10.0.2.2:$(LOCAL_IP):g" src/server/vm1/cyrusconfig.db
	sed -i"" -e "s:localhost:$(LOCAL_IP):g" src/server/vm1/cyrus.db
	sed -i"" -e  "s:10.0.2.2:$(LOCAL_IP):g" src/server/vm1/cyrus.db

setvm2lanconfig:
	sed -i"" -e "s:localhost:$(LOCAL_IP):g" src/server/vm2/cyrusconfig.db
	sed -i"" -e  "s:10.0.2.2:$(LOCAL_IP):g" src/server/vm2/cyrusconfig.db
	sed -i"" -e "s:localhost:$(LOCAL_IP):g" src/server/vm2/cyrus.db
	sed -i"" -e  "s:10.0.2.2:$(LOCAL_IP):g" src/server/vm2/cyrus.db

setvm2iotconfig:
	sed -i"" -e  "s#host: localhost##g"                         src/server/vm2/cyrusconfig.db
	sed -i"" -e  "s#preload: ( )#preload: PiBeaconSoilSensor#g" src/server/vm2/cyrusconfig.db
	sed -i"" -e  "s:localhost:$(LOCAL_IP):g"                     src/server/vm2/PiBeaconSoilSensor.java
	sed -i"" -e  "s#position: 0 0 0#position: $(PI_THING_POS)#g" src/server/vm2/PiBeaconSoilSensor.java

setvm2iotconfig2:
	sed -i"" -e  "s#host: localhost##g"                         src/server/vm2/cyrusconfig.db
	sed -i"" -e  "s#preload: ( )#preload: PiBeaconSoilSensor#g" src/server/vm2/cyrusconfig.db
	sed -i"" -e  "s#netmash.net#localhost:8081#g"                src/server/vm2/PiBeaconSoilSensor.java
	sed -i"" -e  "s#position: 0 0 0#position: $(PI_THING_POS)#g" src/server/vm2/PiBeaconSoilSensor.java

setvm3lanconfig: setvm1lanconfig setvm2lanconfig

setvm1tstconfig:
	sed -i"" -e    "s:10.0.2.2:localhost:g" src/server/vm1/cyrusconfig.db
	sed -i"" -e "s:$(LOCAL_IP):localhost:g" src/server/vm1/cyrusconfig.db
	sed -i"" -e    "s:10.0.2.2:localhost:g" src/server/vm1/cyrus.db
	sed -i"" -e "s:$(LOCAL_IP):localhost:g" src/server/vm1/cyrus.db

setvm2tstconfig:
	sed -i"" -e    "s:10.0.2.2:localhost:g" src/server/vm2/cyrusconfig.db
	sed -i"" -e "s:$(LOCAL_IP):localhost:g" src/server/vm2/cyrusconfig.db
	sed -i"" -e    "s:10.0.2.2:localhost:g" src/server/vm2/cyrus.db
	sed -i"" -e "s:$(LOCAL_IP):localhost:g" src/server/vm2/cyrus.db

setvm3tstconfig:
	sed -i"" -e    "s:10.0.2.2:localhost:g" src/server/vm1/cyrusconfig.db
	sed -i"" -e "s:$(LOCAL_IP):localhost:g" src/server/vm1/cyrusconfig.db
	sed -i"" -e    "s:10.0.2.2:localhost:g" src/server/vm1/cyrus.db
	sed -i"" -e "s:$(LOCAL_IP):localhost:g" src/server/vm1/cyrus.db
	sed -i"" -e    "s:10.0.2.2:localhost:g" src/server/vm2/cyrusconfig.db
	sed -i"" -e "s:$(LOCAL_IP):localhost:g" src/server/vm2/cyrusconfig.db
	sed -i"" -e    "s:10.0.2.2:localhost:g" src/server/vm2/cyrus.db
	sed -i"" -e "s:$(LOCAL_IP):localhost:g" src/server/vm2/cyrus.db

setvm1remconfig:
	sed -i"" -e  "s:10.0.2.2:the-cyrus.net:g" src/server/vm1/cyrusconfig.db
	sed -i"" -e  "s:10.0.2.2:the-cyrus.net:g" src/server/vm1/cyrus.db

setvm3remconfig:
	sed -i"" -e  "s:10.0.2.2:the-cyrus.net:g" src/server/vm1/cyrusconfig.db
	sed -i"" -e  "s:10.0.2.2:the-cyrus.net:g" src/server/vm1/cyrus.db
	sed -i"" -e  "s:10.0.2.2:the-cyrus.net:g" src/server/vm2/cyrusconfig.db
	sed -i"" -e  "s:10.0.2.2:the-cyrus.net:g" src/server/vm2/cyrus.db

netconfig:
	cp src/server/vm1/netconfig.db src/server/vm1/cyrusconfig.db
	cp src/server/vm2/netconfig.db src/server/vm2/cyrusconfig.db

setideproject:
	sed -i"" -e "s#db:.*db#db: $(P).db#" src/server/vm1/ideconfig.db
	sed -i"" -e "s#db:.*db#db: $(P).db#" src/server/vm2/ideconfig.db

ideconfig: setideproject
	cp src/server/vm1/ideconfig.db src/server/vm1/cyrusconfig.db
	cp src/server/vm2/ideconfig.db src/server/vm2/cyrusconfig.db

omconfig:
	cp src/server/vm1/netconfig.db src/server/vm1/cyrusconfig.db
	cp src/server/vm2/omconfig.db  src/server/vm2/cyrusconfig.db

om1config:
	cp src/server/vm1/netconfig.db src/server/vm1/cyrusconfig.db
	cp src/server/vm2/om1config.db  src/server/vm2/cyrusconfig.db

curconfig:
	cp src/server/vm1/netconfig.db src/server/vm1/cyrusconfig.db
	cp src/server/vm2/curconfig.db src/server/vm2/cyrusconfig.db

tstconfig:
	cp src/server/vm1/netconfig.db src/server/vm1/cyrusconfig.db
	cp src/server/vm2/allconfig.db src/server/vm2/cyrusconfig.db

# -------------------------------------------------------------------

setup:
	vim -o -N res/raw/cyrusconfig.db src/server/vm1/cyrusconfig.db src/server/vm1/test.db src/server/vm2/curconfig.db src/server/vm2/allconfig.db src/server/vm2/test.db

tailtestresults1:
	tail -f src/server/vm1/cyrus.log | egrep -i 'running rule|scan|failed|error|exception|fired|xxxxx|Running CyrusLanguage on'

tailtestresults2:
	tail -f src/server/vm2/cyrus.log | egrep -i 'running rule|scan|failed|error|exception|fired|xxxxx|Running CyrusLanguage on'

showtestresults1:
	egrep -i 'running rule|scan|failed|error|exception|fired|xxxxx' src/server/vm1/cyrus.log

showtestresults2:
	egrep -i 'running rule|scan|failed|error|exception|fired|xxxxx' src/server/vm2/cyrus.log

whappen:
	vim -o -N src/server/vm1/cyrus.log src/server/vm2/cyrus.log src/server/vm1/cyrus.db src/server/vm2/cyrus.db

logboth:
	xterm -geometry 97x50+0+80 -e make logcat &
	xterm -geometry 97x20+0+80 -e make logout1 &

logthree:
	xterm -geometry 97x50+0+80 -e make logcat &
	xterm -geometry 97x20+0+80 -e make logout1 &
	xterm -geometry 97x20+0+80 -e make logout2 &

logcat:
	adb -e logcat | tee ,logcat | egrep -vi "locapi|\<rpc\>"

lancat:
	adb -d logcat | egrep -vi "locapi|\<rpc\>" | tee ,logcat

logout1:
	tail -9999f src/server/vm1/cyrus.log

logout2:
	tail -9999f src/server/vm2/cyrus.log

# -------------------------------------------------------------------

classes: \
./build/classes/cyrus/NetMash.class \
./build/classes/cyrus/lib/JSON.class \
./build/classes/cyrus/lib/TestJSON.class \
./build/classes/cyrus/lib/Utils.class \
./build/classes/cyrus/forest/WebObject.class \
./build/classes/cyrus/forest/FunctionalObserver.class \
./build/classes/cyrus/forest/CyrusLanguage.class \
./build/classes/cyrus/forest/HTTP.class \
./build/classes/cyrus/forest/UID.class \
./build/classes/cyrus/forest/Persistence.class \
./build/classes/cyrus/forest/BLE.class \
./build/classes/cyrus/types/Time.class \
./build/classes/cyrus/types/PresenceTracker.class \
./build/classes/server/types/UserHome.class \
./build/classes/server/types/DynamicFile.class \


otherclasses: \
./build/classes/server/types/Twitter.class \


LIBOPTIONS= -Xlint:unchecked -classpath ./src -d ./build/classes

./build/classes/%.class: ./src/%.java
	javac $(LIBOPTIONS) $<

./build/classes:
	mkdir -p ./build/classes

jar: ./build/classes classes
	( cd ./build/classes; jar cf ../cyrus.jar . )

# -------------------------------------------------------------------

init:   proguard.cfg local.properties

proguard.cfg:
	android update project -p .

local.properties:
	android update project -p .

kill:
	@-pkill -f 'java -classpath'

killroot:
	@-sudo pkill -f 'java -classpath'
	-sudo hciconfig hci0 noleadv

clean:
	rm -rf ./build/classes/cyrus
	rm -rf ./build/classes/server
	rm -f  ./src/server/vm?/*.class
	rm -f  doc/local/,l*
	mv ,l* doc/local || echo -n
	rm -f  ,*

andclean:
	./gradlew clean


veryclean: killroot clean andclean setappemuconfig netconfig setvm3cleanconfig setremmapkey
	rm -f doc/local/cyrus1.log doc/local/cyrus2.log
	mv    src/server/vm1/cyrus.log doc/local/cyrus1.log || echo -n
	mv    src/server/vm2/cyrus.log doc/local/cyrus2.log || echo -n
	rm -f  src/server/vm[12]/cyrus.db
	rm -f  src/server/vm[12]/cyrusconfig.db

# -------------------------------------------------------------------


